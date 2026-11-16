import 'dart:async';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/tag_report.dart';

abstract class ReportRepository {
  Stream<TagReport?> watchLatestReport(String deviceId);
  Future<Result<TagReport?>> getLatestReport(String deviceId);
  Future<Result<List<TagReport>>> getReportsRange({
    required String deviceId,
    required int startSrv,
    required int endSrv,
    int limit = 500,
  });
  Future<Result<List<TagReport>>> getPagedHistory({
    required String deviceId,
    int? endBeforeSrv,
    int limit = 25,
  });
  Future<Result<int>> deleteDayReports({
    required String deviceId,
    required DateTime day,
  });
}
