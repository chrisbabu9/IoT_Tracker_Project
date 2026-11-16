import 'dart:async';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/device_summary.dart';

abstract class DeviceRepository {
  Stream<List<DeviceSummary>> watchUserDevices(String uid);
  Future<Result<List<DeviceSummary>>> getUserDevices(String uid);
  Future<Result<DeviceSummary>> claimDevice({
    required String uid,
    required String deviceId,
    required String name,
    required String bleId,
    required String fw,
  });
  Future<Result<void>> renameDevice({
    required String uid,
    required String deviceId,
    required String newName,
  });
  Future<Result<void>> removeDevice({
    required String uid,
    required String deviceId,
  });
  Future<Result<void>> recordLastSeenNear({
    required String deviceId,
    required double lat,
    required double lon,
    required int timestampMs,
  });
  Stream<LastSeenNear?> watchLastSeenNear(String deviceId);
}
