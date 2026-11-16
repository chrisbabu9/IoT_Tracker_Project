import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/data/ble/tp_ble_protocol.dart';
import 'package:trackpoint/data/models/tag_config.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/features/auth/auth_state.dart';

final tagLinkProvider =
    StreamProvider.autoDispose.family<BleLink, String>((ref, bleId) {
  if (bleId.isEmpty) {
    return Stream.value(BleLink(
        bleId: '', status: BleConnectionStatus.disconnected, rssi: -100));
  }
  return ref.watch(bleServiceProvider).linkState(bleId);
});

final tagBleStatusProvider =
    StreamProvider.autoDispose.family<TagStatus, String>((ref, bleId) {
  if (bleId.isEmpty) return const Stream.empty();
  return ref.watch(bleServiceProvider).status(bleId);
});

final latestReportProvider =
    StreamProvider.autoDispose.family<TagReport?, String>((ref, deviceId) {
  return ref.watch(reportRepositoryProvider).watchLatestReport(deviceId);
});

final tagConfigProvider =
    StreamProvider.autoDispose.family<TagConfig, String>((ref, deviceId) {
  return ref.watch(configRepositoryProvider).watchConfig(deviceId);
});

/// Ticks every 30 s so "Away (Live)" / "Last seen X ago" age over time.
final clockTickProvider = StreamProvider.autoDispose<int>(
    (ref) => Stream.periodic(const Duration(seconds: 30), (i) => i));
