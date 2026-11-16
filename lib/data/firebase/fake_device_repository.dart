import 'dart:async';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/data/firebase/device_repository_base.dart';

/// In-memory fake device repository for tests
class FakeDeviceRepository implements DeviceRepository {
  final Map<String, Map<String, DeviceSummary>> _userDevices = {};
  final Map<String, LastSeenNear> _lastSeenNearMap = {};
  final Map<String, String> _deviceOwners = {};
  final StreamController<List<DeviceSummary>> _streamController =
      StreamController<List<DeviceSummary>>.broadcast();

  @override
  Stream<List<DeviceSummary>> watchUserDevices(String uid) async* {
    yield _userDevices[uid]?.values.toList() ?? <DeviceSummary>[];
    yield* _streamController.stream;
  }

  @override
  Future<Result<List<DeviceSummary>>> getUserDevices(String uid) async {
    final list = _userDevices[uid]?.values.toList() ?? [];
    return Result.success(list);
  }

  @override
  Future<Result<DeviceSummary>> claimDevice({
    required String uid,
    required String deviceId,
    required String name,
    required String bleId,
    required String fw,
  }) async {
    final owner = _deviceOwners[deviceId];
    if (owner != null && owner != uid) {
      return Result.failure(const DeviceException(
        'This tag already belongs to another account.',
        code: 'already-owned',
      ));
    }

    final summary = DeviceSummary(
      deviceId: deviceId,
      name: name,
      pairedAt: DateTime.now().millisecondsSinceEpoch,
      bleId: bleId,
      fw: fw,
      owner: uid,
    );

    _deviceOwners[deviceId] = uid;
    _userDevices.putIfAbsent(uid, () => {})[deviceId] = summary;
    _streamController.add(_userDevices[uid]!.values.toList());

    return Result.success(summary);
  }

  @override
  Future<Result<void>> renameDevice({
    required String uid,
    required String deviceId,
    required String newName,
  }) async {
    final current = _userDevices[uid]?[deviceId];
    if (current == null) {
      return Result.failure(const DeviceException('Device not found'));
    }
    _userDevices[uid]![deviceId] = current.copyWith(name: newName);
    _streamController.add(_userDevices[uid]!.values.toList());
    return Result.success(null);
  }

  @override
  Future<Result<void>> removeDevice({
    required String uid,
    required String deviceId,
  }) async {
    _userDevices[uid]?.remove(deviceId);
    _streamController.add(_userDevices[uid]?.values.toList() ?? []);
    return Result.success(null);
  }

  @override
  Future<Result<void>> recordLastSeenNear({
    required String deviceId,
    required double lat,
    required double lon,
    required int timestampMs,
  }) async {
    _lastSeenNearMap[deviceId] =
        LastSeenNear(lat: lat, lon: lon, ts: timestampMs);
    return Result.success(null);
  }

  @override
  Stream<LastSeenNear?> watchLastSeenNear(String deviceId) async* {
    yield _lastSeenNearMap[deviceId];
  }

  void dispose() {
    _streamController.close();
  }
}
