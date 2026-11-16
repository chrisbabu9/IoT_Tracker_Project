import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/core/time_utils.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/domain/history_utils.dart';
import 'package:trackpoint/features/dashboard/stats_provider.dart';
import 'package:trackpoint/features/find/find_providers.dart';
import 'package:trackpoint/features/history/history_path_map.dart';
import 'package:trackpoint/features/history/history_providers.dart';
import 'package:trackpoint/features/settings/app_settings_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _mapController = MapController();
  Timer? _replayTimer;
  int _replayIdx = 0;
  bool _playing = false;

  void _snack(String t) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _export(String deviceId, DateTime? day) async {
    try {
      final List<TagReport> reports;
      if (day != null) {
        reports = await ref.read(historyDayReportsProvider(day).future);
      } else {
        final r = await ref
            .read(reportRepositoryProvider)
            .getPagedHistory(deviceId: deviceId, limit: kHistoryExportLimit);
        reports = r.fold(onSuccess: (d) => d, onFailure: (e) => throw e);
      }
      if (reports.isEmpty) return _snack(AppStrings.historyNothingToExport);
      final tag = ref.read(selectedTagProvider)?.name ?? 'tag';
      await ref.read(csvExporterProvider).share(
          fileName: HistoryCsv.fileName(tag, day), csv: HistoryCsv.build(reports));
    } catch (_) {
      _snack(AppStrings.historyExportFailed);
    }
  }

  Future<void> _deleteDay(String deviceId, DateTime day) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.historyDeleteTitle),
        content: const Text(AppStrings.historyDeleteBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(AppStrings.cancel)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusBad),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(AppStrings.delete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final res = await ref
        .read(reportRepositoryProvider)
        .deleteDayReports(deviceId: deviceId, day: day);
    res.fold(
      onSuccess: (n) {
        ref.invalidate(historyDayReportsProvider(day));
        ref.invalidate(historyPageProvider);
        ref.invalidate(historyPathProvider);
        ref.invalidate(reports24hProvider);
        _snack('${AppStrings.historyDeleted} $n');
      },
      onFailure: (_) => _snack(AppStrings.historyDeleteFailed),
    );
  }

  void _toggleReplay(List<TagReport> pts) {
    if (_playing) {
      _replayTimer?.cancel();
      setState(() => _playing = false);
      return;
    }
    if (_replayIdx >= pts.length - 1) _replayIdx = 0;
    setState(() => _playing = true);
    _replayTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (!mounted || _replayIdx >= pts.length - 1) {
        t.cancel();
        if (mounted) setState(() => _playing = false);
        return;
      }
      setState(() => _replayIdx++);
      try {
        _mapController.move(
            HistoryPathMap.toLatLng(pts[_replayIdx]), _mapController.camera.zoom);
      } catch (_) {} // map not ready
    });
  }

  Widget _replayBar(List<TagReport> pts) {
    final i = _replayIdx.clamp(0, pts.length - 1);
    return Row(
      children: [
        IconButton(
          tooltip: _playing ? AppStrings.historyPause : AppStrings.historyPlay,
          icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
          onPressed: () => _toggleReplay(pts),
        ),
        Expanded(
          child: Slider(
            value: i.toDouble(),
            max: (pts.length - 1).toDouble(),
            onChanged: (v) => setState(() => _replayIdx = v.round()),
          ),
        ),
        Text(TimeUtils.formatTimeOnly(pts[i].srv),
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  void dispose() {
    _replayTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceId = ref.watch(selectedDeviceIdProvider);
    final day = ref.watch(historyDayProvider);
    final pageAsync = ref.watch(historyPageProvider);
    final pathAsync = ref.watch(historyPathProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Pick day',
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: day ?? now,
                firstDate: now.subtract(const Duration(days: 90)),
                lastDate: now,
              );
              if (picked != null) {
                HistoryNav.setDay(ref, picked);
              }
            },
          ),
          IconButton(
            tooltip: AppStrings.historyExportCsv,
            icon: const Icon(Icons.ios_share),
            onPressed: deviceId == null ? null : () => _export(deviceId, day),
          ),
          if (day != null)
            IconButton(
              tooltip: AppStrings.historyDeleteDay,
              icon: const Icon(Icons.delete_outline),
              onPressed: deviceId == null ? null : () => _deleteDay(deviceId, day),
            ),
          if (day != null)
            IconButton(
              tooltip: 'Clear day filter',
              icon: const Icon(Icons.clear),
              onPressed: () => HistoryNav.setDay(ref, null),
            ),
        ],
      ),
      body: deviceId == null
          ? const Center(child: Text('No tag selected'))
          : Column(
              children: [
                if (day != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: InputChip(
                        label: Text(DateFormat('yyyy-MM-dd').format(day)),
                        onDeleted: () => HistoryNav.setDay(ref, null),
                      ),
                    ),
                  ),
                SizedBox(
                  height: 220,
                  child: pathAsync.when(
                    data: (points) => !ref.watch(historyMapEnabledProvider)
                        ? const SizedBox.shrink()
                        : HistoryPathMap(
                            // new key => map re-centres when the day/data changes
                            key: ValueKey(
                                '${points.length}_${points.isEmpty ? 0 : points.last.srv}'),
                            tileUrl: ref.watch(activeTileUrlProvider),
                            points: points,
                            controller: _mapController,
                            replay: _replayIdx > 0 || _playing
                                ? points[_replayIdx.clamp(0, points.length - 1)]
                                : null,
                            onReady: () {},
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Map error: $e')),
                  ),
                ),
                if ((pathAsync.valueOrNull?.length ?? 0) > 1)
                  _replayBar(pathAsync.valueOrNull!),
                const Divider(height: 1),
                Expanded(
                  child: pageAsync.when(
                    data: (page) {
                      if (page.rows.isEmpty) {
                        return const Center(child: Text('No history yet'));
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemCount: page.rows.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) {
                                return _HistoryRow(report: page.rows[i]);
                              },
                            ),
                          ),
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: page.hasPrev
                                        ? () => HistoryNav.previous(ref, page)
                                        : null,
                                    child: const Text('Previous'),
                                  ),
                                  Text(
                                    page.total != null
                                        ? 'Page ${page.pageIndex + 1} · ${page.total} total'
                                        : 'Page ${page.pageIndex + 1}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  TextButton(
                                    onPressed: page.hasNext
                                        ? () => HistoryNav.next(ref, page)
                                        : null,
                                    child: const Text('Next'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.report});

  final TagReport report;

  @override
  Widget build(BuildContext context) {
    final time = TimeUtils.formatDateTime(report.srv);
    final hasGps = report.lat != null && report.lon != null;
    final bat = report.bat;

    return ListTile(
      dense: true,
      leading: Icon(
        hasGps ? Icons.location_on : Icons.location_off,
        color: hasGps ? AppTheme.accentBlue : Colors.grey,
      ),
      title: Text(time),
      subtitle: Text(
        hasGps
            ? '${report.lat!.toStringAsFixed(5)}, ${report.lon!.toStringAsFixed(5)}'
            : 'No GPS fix',
      ),
      trailing: Text(
        '$bat%',
        style: TextStyle(
          color: bat < 20 ? AppTheme.statusBad : null,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
