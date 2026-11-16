import 'dart:async';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/geofence.dart';
import 'package:trackpoint/data/models/tag_config.dart';

abstract class ConfigRepository {
  Stream<TagConfig> watchConfig(String deviceId);
  Future<Result<TagConfig>> getConfig(String deviceId);
  Future<Result<void>> updateSettings(String deviceId, TagSettings settings);
  Future<Result<void>> updateGeofence(String deviceId, Geofence geofence);
  Future<Result<void>> clearGeofence(String deviceId);
}
