import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/domain/alert_rules.dart';
import 'package:trackpoint/domain/geofence_tracker.dart';
import 'package:trackpoint/features/alerts/alert_bus.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/home/tag_providers.dart';

/// Tests set this to false so no map tiles are requested.
final geofenceMapEnabledProvider = Provider<bool>((ref) => true);

final geofenceTrackerProvider = Provider<GeofenceTracker>((ref) => GeofenceTracker());

/// Inside/outside state of the selected tag (null when it has no geofence).
final geofenceStatusProvider = Provider<GeofenceStatus?>((ref) {
  final id = ref.watch(selectedDeviceIdProvider);
  if (id == null) return null;
  final fence = ref.watch(tagConfigProvider(id)).valueOrNull?.geofence;
  final report = ref.watch(latestReportProvider(id)).valueOrNull;
  return GeofenceStatus.compute(fence, report);
});

/// While the app is open: evaluates every new report of every tag against its
/// geofence and raises an alert when the tag leaves or re-enters it.
/// Watch it once at app level while signed in.
final geofenceMonitorProvider = Provider<void>((ref) {
  final devices =
      ref.watch(userDevicesProvider).valueOrNull ?? const <DeviceSummary>[];
  final tracker = ref.read(geofenceTrackerProvider);
  final bus = ref.read(alertBusProvider);

  for (final d in devices) {
    void evaluate() {
      final fence = ref.read(tagConfigProvider(d.deviceId)).valueOrNull?.geofence;
      final report = ref.read(latestReportProvider(d.deviceId)).valueOrNull;
      final transition =
          tracker.update(deviceId: d.deviceId, fence: fence, report: report);
      if (transition == null) return;

      final left = transition == GeofenceTransition.left;
      bus.emit(AlertEvent(
        type: left ? AlertType.geofenceLeft : AlertType.geofenceReEntered,
        title: left
            ? AppStrings.alertGeofenceLeftTitle
            : AppStrings.alertGeofenceBackTitle,
        message: '${d.name} ${left ? AppStrings.alertGeofenceLeftBody : AppStrings.alertGeofenceBackBody}',
        timestampMs: DateTime.now().millisecondsSinceEpoch,
        deviceId: d.deviceId,
      ));
    }

    ref.listen(tagConfigProvider(d.deviceId), (_, __) => evaluate(),
        fireImmediately: true);
    ref.listen(latestReportProvider(d.deviceId), (_, __) => evaluate(),
        fireImmediately: true);
  }
});
