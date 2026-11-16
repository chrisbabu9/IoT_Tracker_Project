import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/domain/history_utils.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/dashboard/stats_provider.dart';
import 'package:trackpoint/features/history/csv_exporter.dart';

const int kHistoryPageSize = 25;
const int kHistoryExportLimit = 500;
const int kHistoryDayLimit = 5000;

final csvExporterProvider =
    Provider<CsvExporter>((ref) => const ShareCsvExporter());

/// Tests set this to false so no map tiles are requested.
final historyMapEnabledProvider = Provider<bool>((ref) => true);

/// Selected day (local date). null = all history.
final historyDayProvider = StateProvider.autoDispose<DateTime?>((ref) => null);

/// "All" mode paging: cursors[i] is the `endBefore` timestamp of page i.
final historyCursorsProvider =
    StateProvider.autoDispose<List<int?>>((ref) => const <int?>[null]);

/// Single-day mode paging (the whole day is loaded, then sliced).
final historyDayPageProvider = StateProvider.autoDispose<int>((ref) => 0);

class HistoryPage {
  final List<TagReport> rows;
  final int pageIndex;
  final bool hasNext;
  final bool hasPrev;

  /// Total records, known only when a single day is selected.
  final int? total;

  const HistoryPage({
    required this.rows,
    required this.pageIndex,
    required this.hasNext,
    required this.hasPrev,
    this.total,
  });

  static const HistoryPage empty = HistoryPage(
    rows: <TagReport>[],
    pageIndex: 0,
    hasNext: false,
    hasPrev: false,
    total: 0,
  );
}

/// All reports of one day, oldest first.
final historyDayReportsProvider = FutureProvider.autoDispose
    .family<List<TagReport>, DateTime>((ref, day) async {
  final deviceId = ref.watch(selectedDeviceIdProvider);
  if (deviceId == null) return const <TagReport>[];
  final bounds = HistoryDay.bounds(day);
  final result = await ref.watch(reportRepositoryProvider).getReportsRange(
        deviceId: deviceId,
        startSrv: bounds.startMs,
        endSrv: bounds.endMs,
        limit: kHistoryDayLimit,
      );
  return result.fold(onSuccess: (d) => d, onFailure: (e) => throw e);
});

/// The table page, newest first.
final historyPageProvider = FutureProvider.autoDispose<HistoryPage>((ref) async {
  final deviceId = ref.watch(selectedDeviceIdProvider);
  if (deviceId == null) return HistoryPage.empty;
  final day = ref.watch(historyDayProvider);

  if (day == null) {
    final cursors = ref.watch(historyCursorsProvider);
    // Ask for one extra record to know whether a next page exists.
    final result = await ref.watch(reportRepositoryProvider).getPagedHistory(
          deviceId: deviceId,
          endBeforeSrv: cursors.last,
          limit: kHistoryPageSize + 1,
        );
    final fetched = result.fold(onSuccess: (d) => d, onFailure: (e) => throw e);
    return HistoryPage(
      rows: fetched.take(kHistoryPageSize).toList(),
      pageIndex: cursors.length - 1,
      hasNext: fetched.length > kHistoryPageSize,
      hasPrev: cursors.length > 1,
    );
  }

  final all = await ref.watch(historyDayReportsProvider(day).future);
  final newestFirst = [...all]..sort((a, b) => b.srv.compareTo(a.srv));
  final lastPage =
      newestFirst.isEmpty ? 0 : (newestFirst.length - 1) ~/ kHistoryPageSize;
  var page = ref.watch(historyDayPageProvider);
  if (page > lastPage) page = lastPage;
  if (page < 0) page = 0;
  final start = page * kHistoryPageSize;
  final rows = newestFirst.skip(start).take(kHistoryPageSize).toList();
  return HistoryPage(
    rows: rows,
    pageIndex: page,
    hasNext: start + rows.length < newestFirst.length,
    hasPrev: page > 0,
    total: newestFirst.length,
  );
});

/// Points for the path map and the replay (oldest first, with coordinates):
/// the selected day, or the last 24 hours when no day is selected.
final historyPathProvider = FutureProvider.autoDispose<List<TagReport>>((ref) async {
  final day = ref.watch(historyDayProvider);
  final List<TagReport> source = day == null
      ? await ref.watch(reports24hProvider.future)
      : await ref.watch(historyDayReportsProvider(day).future);
  return HistoryPath.withCoordinates(source);
});

class HistoryNav {
  HistoryNav._();

  static void setDay(WidgetRef ref, DateTime? day) {
    ref.read(historyDayProvider.notifier).state =
        day == null ? null : HistoryDay.dateOnly(day);
    ref.read(historyCursorsProvider.notifier).state = const <int?>[null];
    ref.read(historyDayPageProvider.notifier).state = 0;
  }

  static void next(WidgetRef ref, HistoryPage page) {
    if (!page.hasNext) return;
    if (ref.read(historyDayProvider) != null) {
      ref.read(historyDayPageProvider.notifier).state = page.pageIndex + 1;
    } else if (page.rows.isNotEmpty) {
      final cursors = ref.read(historyCursorsProvider);
      ref.read(historyCursorsProvider.notifier).state = [
        ...cursors,
        page.rows.last.srv,
      ];
    }
  }

  static void previous(WidgetRef ref, HistoryPage page) {
    if (!page.hasPrev) return;
    if (ref.read(historyDayProvider) != null) {
      ref.read(historyDayPageProvider.notifier).state = page.pageIndex - 1;
    } else {
      final cursors = ref.read(historyCursorsProvider);
      if (cursors.length > 1) {
        ref.read(historyCursorsProvider.notifier).state =
            cursors.sublist(0, cursors.length - 1);
      }
    }
  }
}
