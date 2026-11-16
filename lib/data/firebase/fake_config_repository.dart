import 'dart:async';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/geofence.dart';
import 'package:trackpoint/data/models/tag_config.dart';
import 'package:trackpoint/data/firebase/config_repository_base.dart';

/// In-memory fake config repository for testing
class FakeConfigRepository implements ConfigRepository {
  final Map<String, TagConfig> _configs = {};
  final StreamController<TagConfig> _controller =
      StreamController<TagConfig>.broadcast();

  @override
  Stream<TagConfig> watchConfig(String deviceId) async* {
    yield _configs[deviceId] ?? const TagConfig();
    yield* _controller.stream;
  }

  @override
  Future<Result<TagConfig>> getConfig(String deviceId) async {
    return Result.success(_configs[deviceId] ?? const TagConfig());
  }

  @override
  Future<Result<void>> updateSettings(String deviceId, TagSettings settings) async {
    final current = _configs[deviceId] ?? const TagConfig();
    final updated = current.copyWith(settings: settings);
    _configs[deviceId] = updated;
    _controller.add(updated);
    return Result.success(null);
  }

  @override
  Future<Result<void>> updateGeofence(String deviceId, Geofence geofence) async {
    final current = _configs[deviceId] ?? const TagConfig();
    final updated = current.copyWith(geofence: geofence);
    _configs[deviceId] = updated;
    _controller.add(updated);
    return Result.success(null);
  }

  @override
  Future<Result<void>> clearGeofence(String deviceId) async {
    final current = _configs[deviceId] ?? const TagConfig();
    final updated = TagConfig(
      lostMode: current.lostMode,
      settings: current.settings,
      geofence: null,
    );
    _configs[deviceId] = updated;
    _controller.add(updated);
    return Result.success(null);
  }

  void dispose() {
    _controller.close();
  }
}
