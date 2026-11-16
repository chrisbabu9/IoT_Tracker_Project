import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/domain/trip_stats.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/dashboard/tag_presence_provider.dart';

/// 1-min Lost-mode reporting = 1440 points/day; keep headroom.
const int kReports24hLimit = 1500;

/// Holds the 24 h reports fetched for battery chart and stats.
final reports24hProvider = FutureProvider.autoDispose<List<TagReport>>((ref) async {
  final deviceId = ref.watch(selectedDeviceIdProvider);
  // Refetch when a newer report arrives (stats/chart/path stay current).
  ref.watch(selectedDeviceReportProvider.select((r) => r.valueOrNull?.srv));
  if (deviceId == null) return [];
  final repo = ref.watch(reportRepositoryProvider);
  final nowMs = DateTime.now().millisecondsSinceEpoch;
  final startMs = nowMs - const Duration(hours: 24).inMilliseconds;
  final result = await repo.getReportsRange(
    deviceId: deviceId,
    startSrv: startMs,
    endSrv: nowMs,
    limit: kReports24hLimit,
  );
  return result.dataOrNull ?? [];
});

/// Derived TripStats from 24 h GPS fixes (fix == 1, has coordinates).
final tripStats24hProvider = Provider<TripStats?>((ref) {
  final reportsAsync = ref.watch(reports24hProvider);
  final reports = reportsAsync.value;
  if (reports == null || reports.isEmpty) return null;

  final sorted = [...reports]..sort((a, b) => a.srv.compareTo(b.srv));
  final points = sorted
      .where((r) => r.fix == 1 && r.hasCoordinates)
      .map((r) => TripPoint(
            lat: r.lat!,
            lon: r.lon!,
            timestampMs: r.srv,
          ))
      .toList();

  if (points.isEmpty) return null;
  return TripStats.calculate(points);
});
