import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/core/time_utils.dart';
import 'package:trackpoint/core/units.dart';
import 'package:trackpoint/features/settings/app_settings_providers.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/domain/tag_presence.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/dashboard/stats_provider.dart';
import 'package:trackpoint/features/dashboard/tag_presence_provider.dart';
import 'package:trackpoint/features/geofence/geofence_card.dart';
import 'package:trackpoint/features/home/tag_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(clockTickProvider);
    final devices = ref.watch(userDevicesProvider).value ?? [];
    final selectedId = ref.watch(selectedDeviceIdProvider);

    if (selectedId == null || devices.isEmpty) {
      return const Scaffold(
        body: Center(child: Text(AppStrings.noTagSelected)),
      );
    }

    final summary = devices.where((d) => d.deviceId == selectedId).firstOrNull;
    final presence = ref.watch(tagPresenceProvider);
    final reportAsync = ref.watch(selectedDeviceReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(summary?.name ?? AppStrings.dashboardTitle),
        backgroundColor: AppTheme.darkBackground,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: AppStrings.deviceSettingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/device-settings'),
          ),
          IconButton(
            tooltip: AppStrings.mapTitle,
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push('/map'),
          ),
        ],
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (report) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusCard(presence: presence, report: report),
            const SizedBox(height: 12),
            const _QuickActionsCard(),
            const SizedBox(height: 12),
            const GeofenceCard(),
            const SizedBox(height: 12),
            if (report != null) _LocationCard(report: report),
            const SizedBox(height: 12),
            const _BatteryChartCard(),
            const SizedBox(height: 12),
            const _Stats24hCard(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status Card
// ---------------------------------------------------------------------------

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.presence, required this.report});

  final TagPresenceInfo presence;
  final TagReport? report;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastComm = presence.lastCommunicationMs;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.statusCard,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                _PresencePill(presence: presence),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: AppStrings.lastCommunication,
              value: TimeUtils.formatTimeAgo(lastComm, nowMs: now),
            ),
            const Divider(height: 20),
            if (report != null) ...[
              _InfoRow(
                label: AppStrings.gpsFix,
                value: report!.fix == 1
                    ? AppStrings.gpsFixYes
                    : AppStrings.gpsFixNo,
                valueColor:
                    report!.fix == 1 ? AppTheme.statusOk : AppTheme.statusWarn,
              ),
              if (report!.sat != null)
                _InfoRow(
                  label: AppStrings.satellites,
                  value: '${report!.sat}',
                ),
              _InfoRow(
                label: AppStrings.batteryVoltage,
                value: '${report!.bv.toStringAsFixed(2)} V  ·  ${report!.bat}%',
                valueColor: report!.bat < 20
                    ? AppTheme.statusBad
                    : report!.bat < 40
                        ? AppTheme.statusWarn
                        : AppTheme.statusOk,
              ),
              _InfoRow(
                label: AppStrings.cellularSignal,
                value: report!.signalDbm != null
                    ? '${report!.signalDbm} dBm  (csq ${report!.csq})'
                    : AppStrings.cellularUnknown,
                valueColor:
                    report!.signalDbm == null ? AppTheme.statusMuted : null,
              ),
            ],
            const Divider(height: 20),
            // Alert pills
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _buildAlertPills(report),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAlertPills(TagReport? report) {
    final pills = <Widget>[];
    if (report == null) return pills;

    if (report.bat < 20) {
      pills.add(_AlertPill(
          label: AppStrings.alertLowBattery, color: AppTheme.statusBad));
    }
    if (presence.isOffline) {
      pills.add(_AlertPill(
          label: AppStrings.alertNotReporting, color: AppTheme.statusWarn));
    }
    if (report.signalDbm == null) {
      pills.add(_AlertPill(
          label: AppStrings.alertNoCellular, color: AppTheme.statusMuted));
    }

    return pills;
  }
}

// ---------------------------------------------------------------------------
// Location Card
// ---------------------------------------------------------------------------

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.report});

  final TagReport report;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hasCoords = report.hasCoordinates;
    final gpsAge = report.age; // seconds since position was real

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.locationCard,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (!hasCoords) ...[
              Text(
                AppStrings.noLocationAvailable,
                style: TextStyle(color: AppTheme.statusMuted),
              ),
            ] else ...[
              _InfoRow(
                label: AppStrings.latitude,
                value: report.lat!.toStringAsFixed(6),
              ),
              _InfoRow(
                label: AppStrings.longitude,
                value: report.lon!.toStringAsFixed(6),
              ),
              if (report.acc != null)
                _InfoRow(
                  label: AppStrings.estimatedAccuracy,
                  value: '~${report.acc} m',
                ),
              _InfoRow(
                label: AppStrings.lastGpsUpdate,
                value: report.fix == 1
                    ? TimeUtils.formatTimeAgo(report.srv, nowMs: now)
                    : '${TimeUtils.formatTimeAgo(report.srv, nowMs: now)} (${gpsAge}s old fix)',
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/map'),
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Show on Live Map'),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyCoordinates(context),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text(AppStrings.copyCoordinates),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openInMaps(),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text(AppStrings.openInMaps),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyCoordinates(BuildContext context) {
    if (!report.hasCoordinates) return;
    Clipboard.setData(ClipboardData(
      text:
          '${report.lat!.toStringAsFixed(6)}, ${report.lon!.toStringAsFixed(6)}',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.coordinatesCopied)),
    );
  }

  Future<void> _openInMaps() async {
    if (!report.hasCoordinates) return;
    final lat = report.lat!;
    final lon = report.lon!;
    final uri = Uri.parse('geo:$lat,$lon?q=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final fallback = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lon');
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.darkMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresencePill extends StatelessWidget {
  const _PresencePill({required this.presence});

  final TagPresenceInfo presence;

  Color get _color {
    return switch (presence.state) {
      PresenceState.near => AppTheme.accentCyan,
      PresenceState.away => AppTheme.accentBlue,
      PresenceState.lost => AppTheme.statusWarn,
      PresenceState.sos => AppTheme.statusBad,
      PresenceState.offline => AppTheme.statusMuted,
      PresenceState.neverConnected => AppTheme.statusMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(
        presence.label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AlertPill extends StatelessWidget {
  const _AlertPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Battery Chart Card
// ---------------------------------------------------------------------------

class _BatteryChartCard extends ConsumerWidget {
  const _BatteryChartCard();

  static const double _lowBatteryPct = 20.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reports24hProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.batteryChart,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            reportsAsync.when(
              loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('$e'),
              data: (reports) {
                if (reports.isEmpty) {
                  return const SizedBox(
                    height: 80,
                    child: Center(child: Text(AppStrings.noStats24h)),
                  );
                }
                final sorted = [...reports]
                  ..sort((a, b) => a.srv.compareTo(b.srv));
                final spots = <FlSpot>[];
                for (int i = 0; i < sorted.length; i++) {
                  spots.add(FlSpot(i.toDouble(), sorted[i].bat.toDouble()));
                }
                return SizedBox(
                  height: 140,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppTheme.accentBlue,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.accentBlue.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: _lowBatteryPct,
                            color: AppTheme.statusBad.withValues(alpha: 0.7),
                            strokeWidth: 1,
                            dashArray: [6, 4],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              style: const TextStyle(
                                color: AppTheme.statusBad,
                                fontSize: 10,
                              ),
                              labelResolver: (_) =>
                                  AppStrings.lowBatteryThreshold,
                            ),
                          ),
                        ],
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 25,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 24 h Stats Card
// ---------------------------------------------------------------------------

class _Stats24hCard extends ConsumerWidget {
  const _Stats24hCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(tripStats24hProvider);
    final reportsAsync = ref.watch(reports24hProvider);
    final imperial = ref.watch(unitSystemProvider) == UnitSystem.imperial;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.stats24h,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (reportsAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (stats == null || stats.totalFixes == 0)
              const Text(AppStrings.noStats24h,
                  style: TextStyle(color: AppTheme.darkMuted))
            else ...[
              _InfoRow(
                label: AppStrings.statFixes,
                value: '${stats.totalFixes}',
              ),
              _InfoRow(
                label: AppStrings.statDistance,
                value: Units.distance(stats.distanceMeters, imperial: imperial),
              ),
              _InfoRow(
                label: AppStrings.statMovingTime,
                value: TimeUtils.formatDuration(stats.movingTimeSeconds),
              ),
              _InfoRow(
                label: AppStrings.statAvgSpeed,
                value: Units.speed(stats.avgMovingSpeedKmh, imperial: imperial),
              ),
              _InfoRow(
                label: AppStrings.statTopSpeed,
                value: Units.speed(stats.topSpeedKmh, imperial: imperial),
              ),
              if (stats.firstFixTimestampMs != null)
                _InfoRow(
                  label: AppStrings.statFirstFix,
                  value: TimeUtils.formatTimeOnly(stats.firstFixTimestampMs),
                ),
              if (stats.lastFixTimestampMs != null)
                _InfoRow(
                  label: AppStrings.statLastFix,
                  value: TimeUtils.formatTimeOnly(stats.lastFixTimestampMs),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.darkCard,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.darkLine),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.report_problem_outlined,
                color: AppTheme.statusWarn),
            title: const Text(AppStrings.lostModeTitle),
            subtitle: const Text(AppStrings.quickLostModeSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/lost'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.history, color: AppTheme.accentCyan),
            title: const Text(AppStrings.historyTitle),
            subtitle: const Text(AppStrings.quickHistorySubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/history'),
          ),
          const Divider(height: 1),
          ListTile(
            leading:
                const Icon(Icons.tune_outlined, color: AppTheme.accentBlue),
            title: const Text(AppStrings.deviceSettingsTitle),
            subtitle: const Text('Reporting intervals, buzzer, thresholds'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/device-settings'),
          ),
        ],
      ),
    );
  }
}
