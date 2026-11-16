import 'dart:async';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/data/firebase/report_repository_base.dart';

/// In-memory fake report repository for testing
class FakeReportRepository implements ReportRepository {
  final Map<String, List<TagReport>> _historyMap = {};
  final StreamController<(String, TagReport)> _latestStream =
      StreamController<(String, TagReport)>.broadcast();

  void addReport(String deviceId, TagReport report) {
    _historyMap.putIfAbsent(deviceId, () => []).add(report);
    _latestStream.add((deviceId, report));
  }

  @override
  Stream<TagReport?> watchLatestReport(String deviceId) async* {
    final list = _historyMap[deviceId];
    yield (list == null || list.isEmpty) ? null : list.last;
    yield* _latestStream.stream.where((e) => e.$1 == deviceId).map((e) => e.$2);
  }

  @override
  Future<Result<TagReport?>> getLatestReport(String deviceId) async {
    final list = _historyMap[deviceId];
    if (list == null || list.isEmpty) {
      return Result.success(null);
    }
    return Result.success(list.last);
  }

  @override
  Future<Result<List<TagReport>>> getReportsRange({
    required String deviceId,
    required int startSrv,
    required int endSrv,
    int limit = 500,
  }) async {
    final list = _historyMap[deviceId] ?? [];
    final filtered = list
        .where((r) => r.srv >= startSrv && r.srv <= endSrv)
        .toList()
      ..sort((a, b) => a.srv.compareTo(b.srv));
    return Result.success(filtered.take(limit).toList());
  }

  @override
  Future<Result<List<TagReport>>> getPagedHistory({
    required String deviceId,
    int? endBeforeSrv,
    int limit = 25,
  }) async {
    final list = _historyMap[deviceId] ?? [];
    var filtered = [...list]; // copy: never sort stored history in place
    if (endBeforeSrv != null) {
      filtered = filtered.where((r) => r.srv < endBeforeSrv).toList();
    }
    filtered.sort((a, b) => b.srv.compareTo(a.srv));
    return Result.success(filtered.take(limit).toList());
  }

  @override
  Future<Result<int>> deleteDayReports({
    required String deviceId,
    required DateTime day,
  }) async {
    final startOfDay = DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59, 999).millisecondsSinceEpoch;

    final list = _historyMap[deviceId] ?? [];
    final initialCount = list.length;
    list.removeWhere((r) => r.srv >= startOfDay && r.srv <= endOfDay);
    return Result.success(initialCount - list.length);
  }

  void dispose() {
    _latestStream.close();
  }
}
