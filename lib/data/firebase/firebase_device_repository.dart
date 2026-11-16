import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/data/firebase/device_repository_base.dart';

class FirebaseDeviceRepository implements DeviceRepository {
  final FirebaseDatabase _db;

  FirebaseDeviceRepository({FirebaseDatabase? db})
      : _db = db ?? FirebaseDatabase.instance;

  @override
  Stream<List<DeviceSummary>> watchUserDevices(String uid) {
    final ref = _db.ref('users/$uid/devices');
    return ref.onValue.asyncMap((event) async {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) {
        return <DeviceSummary>[];
      }
      final rawMap = snap.value as Map<dynamic, dynamic>;
      Map<dynamic, dynamic>? asMap(DataSnapshot x) =>
          x.exists && x.value != null ? x.value as Map<dynamic, dynamic> : null;
      // Fetch meta + lastSeenNear of all tags in parallel (was N+1 sequential).
      return Future.wait(rawMap.entries.map((entry) async {
        final deviceId = entry.key.toString();
        final snaps = await Future.wait([
          _db.ref('devices/$deviceId/meta').get(),
          _db.ref('devices/$deviceId/lastSeenNear').get(),
        ]);
        return DeviceSummary.fromJson(
          entry.value as Map<dynamic, dynamic>,
          deviceId: deviceId,
          metaJson: asMap(snaps[0]),
          lastSeenNearJson: asMap(snaps[1]),
        );
      }));
    });
  }

  @override
  Future<Result<List<DeviceSummary>>> getUserDevices(String uid) async {
    try {
      final snap = await _db.ref('users/$uid/devices').get();
      if (!snap.exists || snap.value == null) {
        return Result.success(<DeviceSummary>[]);
      }
      final rawMap = snap.value as Map<dynamic, dynamic>;
      final list = <DeviceSummary>[];

      for (final entry in rawMap.entries) {
        final deviceId = entry.key.toString();
        final deviceData = entry.value as Map<dynamic, dynamic>;
        final metaSnap = await _db.ref('devices/$deviceId/meta').get();
        final metaMap = metaSnap.exists && metaSnap.value != null
            ? metaSnap.value as Map<dynamic, dynamic>
            : null;

        list.add(DeviceSummary.fromJson(
          deviceData,
          deviceId: deviceId,
          metaJson: metaMap,
        ));
      }
      return Result.success(list);
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Future<Result<DeviceSummary>> claimDevice({
    required String uid,
    required String deviceId,
    required String name,
    required String bleId,
    required String fw,
  }) async {
    debugPrint('[CLAIM] start uid=$uid deviceId=$deviceId bleId=$bleId');
    try {
      // Atomic claim: only succeeds when there is no other owner.
      final tx = await _db
          .ref('devices/$deviceId/meta/owner')
          .runTransaction((current) {
        final existing = current?.toString() ?? '';
        if (existing.isNotEmpty && existing != uid) return Transaction.abort();
        return Transaction.success(uid);
      });
      if (!tx.committed) {
        debugPrint('[CLAIM] already owned by another account');
        return Result.failure(const DeviceException(
          'This tag already belongs to another account.',
          code: 'already-owned',
        ));
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      debugPrint('[CLAIM] writing meta …');
      await _db.ref('devices/$deviceId/meta').update({
        'owner': uid,
        'name': name,
        'fw': fw,
        'createdAt': now,
      });
      debugPrint('[CLAIM] meta write OK');

      debugPrint('[CLAIM] writing users/$uid/devices/$deviceId …');
      await _db.ref('users/$uid/devices/$deviceId').set({
        'name': name,
        'pairedAt': now,
        'bleId': bleId,
      });
      debugPrint('[CLAIM] user index write OK');

      return Result.success(DeviceSummary(
        deviceId: deviceId,
        name: name,
        pairedAt: now,
        bleId: bleId,
        fw: fw,
        owner: uid,
        createdAt: now,
      ));
    } on FirebaseException catch (e, st) {
      debugPrint(
          '[CLAIM] FirebaseException code=${e.code} message=${e.message}');
      debugPrint('[CLAIM] $st');
      return Result.failure(DeviceException(
        'Firebase ${e.code}: ${e.message}',
        code: e.code,
      ));
    } catch (e, st) {
      debugPrint('[CLAIM] error: $e');
      debugPrint('[CLAIM] $st');
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Future<Result<void>> renameDevice({
    required String uid,
    required String deviceId,
    required String newName,
  }) async {
    try {
      await _db.ref().update({
        'users/$uid/devices/$deviceId/name': newName,
        'devices/$deviceId/meta/name': newName,
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Future<Result<void>> removeDevice({
    required String uid,
    required String deviceId,
  }) async {
    try {
      // Atomic: remove from the user's list AND release ownership of the tag.
      await _db.ref().update({
        'users/$uid/devices/$deviceId': null,
        'devices/$deviceId/meta/owner': null,
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Future<Result<void>> recordLastSeenNear({
    required String deviceId,
    required double lat,
    required double lon,
    required int timestampMs,
  }) async {
    try {
      await _db.ref('devices/$deviceId/lastSeenNear').set({
        'lat': lat,
        'lon': lon,
        'ts': timestampMs,
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Stream<LastSeenNear?> watchLastSeenNear(String deviceId) {
    return _db.ref('devices/$deviceId/lastSeenNear').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return null;
      return LastSeenNear.fromJson(
        event.snapshot.value as Map<dynamic, dynamic>,
      );
    });
  }
}
