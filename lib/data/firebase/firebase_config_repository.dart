import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/geofence.dart';
import 'package:trackpoint/data/models/tag_config.dart';
import 'package:trackpoint/data/firebase/config_repository_base.dart';

class FirebaseConfigRepository implements ConfigRepository {
  final FirebaseDatabase _db;

  FirebaseConfigRepository({FirebaseDatabase? db})
      : _db = db ?? FirebaseDatabase.instance;

  @override
  Stream<TagConfig> watchConfig(String deviceId) {
    return _db.ref('devices/$deviceId/config').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return const TagConfig();
      }
      return TagConfig.fromJson(
        event.snapshot.value as Map<dynamic, dynamic>,
      );
    });
  }

  @override
  Future<Result<TagConfig>> getConfig(String deviceId) async {
    try {
      final snap = await _db.ref('devices/$deviceId/config').get();
      if (!snap.exists || snap.value == null) {
        return Result.success(const TagConfig());
      }
      return Result.success(TagConfig.fromJson(
        snap.value as Map<dynamic, dynamic>,
      ));
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateSettings(String deviceId, TagSettings settings) async {
    try {
      await _db.ref('devices/$deviceId/config/settings').set(settings.toJson());
      return Result.success(null);
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateGeofence(String deviceId, Geofence geofence) async {
    try {
      await _db.ref('devices/$deviceId/config/geofence').set(geofence.toJson());
      return Result.success(null);
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Future<Result<void>> clearGeofence(String deviceId) async {
    try {
      await _db.ref('devices/$deviceId/config/geofence').remove();
      return Result.success(null);
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }
}
