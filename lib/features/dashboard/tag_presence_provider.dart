import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/domain/tag_presence.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/home/tag_providers.dart';

/// Latest cloud report for the selected tag.
final selectedDeviceReportProvider = StreamProvider<TagReport?>((ref) {
  final deviceId = ref.watch(selectedDeviceIdProvider);
  if (deviceId == null) return Stream.value(null);
  return ref.watch(reportRepositoryProvider).watchLatestReport(deviceId);
});

/// BLE link state for the selected tag.
final selectedDeviceBleProvider = StreamProvider<BleLink?>((ref) {
  final devices = ref.watch(userDevicesProvider).value ?? [];
  final deviceId = ref.watch(selectedDeviceIdProvider);
  if (deviceId == null) return Stream.value(null);
  final summary = devices.where((d) => d.deviceId == deviceId).firstOrNull;
  if (summary == null || summary.bleId.isEmpty) return Stream.value(null);
  return ref.watch(bleServiceProvider).linkState(summary.bleId);
});

/// Presence of the selected tag. Recomputed every 30 s by the clock tick and
/// uses the tag's own offline timeout when its config is available.
final tagPresenceProvider = Provider<TagPresenceInfo>((ref) {
  ref.watch(clockTickProvider);
  final deviceId = ref.watch(selectedDeviceIdProvider);
  final bleLink = ref.watch(selectedDeviceBleProvider).value;
  final report = ref.watch(selectedDeviceReportProvider).value;
  final timeout = deviceId == null
      ? AppConfig.defaultOfflineTimeoutS
      : ref
              .watch(tagConfigProvider(deviceId))
              .valueOrNull
              ?.settings
              .offlineTimeoutS ??
          AppConfig.defaultOfflineTimeoutS;

  return TagPresence.compute(
    isBleConnected: bleLink?.isConnected ?? false,
    latestReport: report,
    offlineTimeoutSeconds: timeout,
  );
});
