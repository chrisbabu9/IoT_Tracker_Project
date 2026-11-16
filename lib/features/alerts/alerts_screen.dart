import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/core/time_utils.dart';
import 'package:trackpoint/domain/alert_rules.dart';
import 'package:trackpoint/features/alerts/alert_bus.dart';
import 'package:trackpoint/features/alerts/alert_store.dart';
import 'package:trackpoint/features/auth/auth_state.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(alertStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.alertsCenterTitle),
        backgroundColor: AppTheme.darkBackground,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showSettings ? Icons.list : Icons.tune,
            ),
            tooltip: _showSettings
                ? AppStrings.alertsCenterTitle
                : AppStrings.alertsSettings,
            onPressed: () => setState(() => _showSettings = !_showSettings),
          ),
          if (!_showSettings)
            storeAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (store) => store.alerts.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.clear_all),
                      tooltip: AppStrings.alertsClearAll,
                      onPressed: () => ref
                          .read(alertStoreProvider.notifier)
                          .clearAll(),
                    ),
            ),
        ],
      ),
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (store) => _showSettings
            ? _SettingsPanel(store: store)
            : _AlertList(store: store),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Alert list
// ---------------------------------------------------------------------------

class _AlertList extends ConsumerWidget {
  const _AlertList({required this.store});
  final AlertStoreState store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (store.alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_none,
                  size: 56, color: AppTheme.darkMuted),
              const SizedBox(height: 16),
              const Text(
                AppStrings.alertsEmpty,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.alertsEmptyHint,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppTheme.darkMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: store.alerts.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 56, endIndent: 16),
      itemBuilder: (context, index) {
        final alert = store.alerts[index];
        return _AlertTile(alert: alert);
      },
    );
  }
}

class _AlertTile extends ConsumerWidget {
  const _AlertTile({required this.alert});
  final PersistedAlert alert;

  IconData get _icon {
    switch (alert.type) {
      case AlertType.tagOffline:
        return Icons.cloud_off;
      case AlertType.tagBackOnline:
        return Icons.cloud_done;
      case AlertType.lowBattery:
        return Icons.battery_alert;
      case AlertType.gpsFixLost:
        return Icons.gps_off;
      case AlertType.geofenceLeft:
        return Icons.fence;
      case AlertType.geofenceReEntered:
        return Icons.fence;
      case AlertType.movementDetected:
        return Icons.directions_run;
      case AlertType.leftBehind:
        return Icons.bluetooth_disabled;
      case AlertType.sosAlert:
        return Icons.sos;
      case AlertType.lostModeUpdate:
        return Icons.location_on;
      case AlertType.batteryCriticalFinal:
        return Icons.battery_0_bar;
    }
  }

  Color get _color {
    switch (alert.type) {
      case AlertType.sosAlert:
      case AlertType.batteryCriticalFinal:
        return AppTheme.statusBad;
      case AlertType.lowBattery:
      case AlertType.tagOffline:
      case AlertType.geofenceLeft:
      case AlertType.leftBehind:
        return AppTheme.statusWarn;
      case AlertType.tagBackOnline:
      case AlertType.geofenceReEntered:
        return AppTheme.statusOk;
      default:
        return AppTheme.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = alertRoute(AlertEvent(
      type: alert.type,
      title: alert.title,
      message: alert.message,
      timestampMs: alert.timestampMs,
      deviceId: alert.deviceId,
    ));

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: _color.withValues(alpha: 0.15),
        child: Icon(_icon, color: _color, size: 20),
      ),
      title: Text(
        alert.title,
        style:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.message,
              style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 2),
          Text(
            TimeUtils.formatTimeAgo(alert.timestampMs),
            style: const TextStyle(
                color: AppTheme.darkMuted, fontSize: 11),
          ),
        ],
      ),
      trailing: Icon(Icons.chevron_right,
          color: AppTheme.darkMuted, size: 18),
      onTap: () {
        if (alert.deviceId.isNotEmpty) {
          ref.read(selectedDeviceOverrideProvider.notifier).state =
              alert.deviceId;
        }
        context.push(route);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Settings panel — per-category toggles
// ---------------------------------------------------------------------------

class _SettingsPanel extends ConsumerWidget {
  const _SettingsPanel({required this.store});
  final AlertStoreState store;

  static const _categories = [
    (AlertType.tagOffline, AppStrings.alertsCatOffline),
    (AlertType.lowBattery, AppStrings.alertsCatBattery),
    (AlertType.gpsFixLost, AppStrings.alertsCatGps),
    (AlertType.geofenceLeft, AppStrings.alertsCatGeofence),
    (AlertType.movementDetected, AppStrings.alertsCatMovement),
    (AlertType.leftBehind, AppStrings.alertsCatLeftBehind),
    (AlertType.sosAlert, AppStrings.alertsCatSos),
    (AlertType.lostModeUpdate, AppStrings.alertsCatLostMode),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppStrings.alertsCategoryHeader,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: _categories.map((cat) {
              final type = cat.$1;
              final label = cat.$2;
              final enabled = store.enabled[type] ?? true;
              return SwitchListTile(
                value: enabled,
                title: Text(label, style: const TextStyle(fontSize: 14)),
                onChanged: (v) =>
                    ref.read(alertStoreProvider.notifier).setEnabled(type, v),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
