import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/data/firebase/report_repository_base.dart';

class FirebaseReportRepository implements ReportRepository {
  final FirebaseDatabase _db;

  FirebaseReportRepository({FirebaseDatabase? db})
      : _db = db ?? FirebaseDatabase.instance;

  @override
  Stream<TagReport?> watchLatestReport(String deviceId) {
    final query = _db
        .ref('devices/$deviceId/history')
        .orderByKey()
        .limitToLast(1);

    return query.onValue.map((event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) {
        return null;
      }
      final map = snap.value as Map<dynamic, dynamic>;
      if (map.isEmpty) return null;
      final key = map.keys.first.toString();
      final data = map.values.first as Map<dynamic, dynamic>;
      return TagReport.fromJson(data, pushId: key);
    });
  }

  @override
  Future<Result<TagReport?>> getLatestReport(String deviceId) async {
    try {
      final snap = await _db
          .ref('devices/$deviceId/history')
          .orderByKey()
          .limitToLast(1)
          .get();

      if (!snap.exists || snap.value == null) {
        return Result.success(null);
      }
      final map = snap.value as Map<dynamic, dynamic>;
      if (map.isEmpty) return Result.success(null);

      final key = map.keys.first.toString();
      final data = map.values.first as Map<dynamic, dynamic>;
      return Result.success(TagReport.fromJson(data, pushId: key));
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Future<Result<List<TagReport>>> getReportsRange({
    required String deviceId,
    required int startSrv,
    required int endSrv,
    int limit = 500,
  }) async {
    try {
      final snap = await _db
          .ref('devices/$deviceId/history')
          .orderByChild('srv')
          .startAt(startSrv)
          .endAt(endSrv)
          .limitToLast(limit)
          .get();

      if (!snap.exists || snap.value == null) {
        return Result.success(<TagReport>[]);
      }

      final map = snap.value as Map<dynamic, dynamic>;
      final reports = <TagReport>[];

      for (final entry in map.entries) {
        final pushId = entry.key.toString();
        final data = entry.value as Map<dynamic, dynamic>;
        reports.add(TagReport.fromJson(data, pushId: pushId));
      }

      // Sort chronologically ascending
      reports.sort((a, b) => a.srv.compareTo(b.srv));
      return Result.success(reports);
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Future<Result<List<TagReport>>> getPagedHistory({
    required String deviceId,
    int? endBeforeSrv,
    int limit = 25,
  }) async {
    try {
      var query = _db
          .ref('devices/$deviceId/history')
          .orderByChild('srv');

      if (endBeforeSrv != null) {
        query = query.endBefore(endBeforeSrv);
      }

      final snap = await query.limitToLast(limit).get();
      if (!snap.exists || snap.value == null) {
        return Result.success(<TagReport>[]);
      }

      final map = snap.value as Map<dynamic, dynamic>;
      final reports = <TagReport>[];

      for (final entry in map.entries) {
        final pushId = entry.key.toString();
        final data = entry.value as Map<dynamic, dynamic>;
        reports.add(TagReport.fromJson(data, pushId: pushId));
      }

      // Sort newest first for table display
      reports.sort((a, b) => b.srv.compareTo(a.srv));
      return Result.success(reports);
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }

  @override
  Future<Result<int>> deleteDayReports({
    required String deviceId,
    required DateTime day,
  }) async {
    try {
      final startOfDay = DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59, 999).millisecondsSinceEpoch;

      final snap = await _db
          .ref('devices/$deviceId/history')
          .orderByChild('srv')
          .startAt(startOfDay)
          .endAt(endOfDay)
          .get();

      if (!snap.exists || snap.value == null) {
        return Result.success(0);
      }

      final map = snap.value as Map<dynamic, dynamic>;
      final updates = <String, Object?>{};

      for (final key in map.keys) {
        updates['devices/$deviceId/history/$key'] = null;
      }

      if (updates.isNotEmpty) {
        await _db.ref().update(updates);
      }

      return Result.success(updates.length);
    } catch (e) {
      return Result.failure(DeviceException(e.toString()));
    }
  }
}
