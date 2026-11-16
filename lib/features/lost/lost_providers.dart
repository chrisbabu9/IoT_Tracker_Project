import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/domain/tag_mode.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/home/tag_providers.dart';
import 'package:trackpoint/features/lost/lost_mode_controller.dart';

final lostModeControllerProvider = Provider<LostModeController>((ref) {
  return LostModeController(
    ble: ref.watch(bleServiceProvider),
    commands: ref.watch(commandRepositoryProvider),
  );
});

class SosTag {
  final DeviceSummary device;
  final TagReport? report;
  final int? batteryPct;
  const SosTag({required this.device, this.report, this.batteryPct});
}

/// Every tag that is currently in SOS (from BLE STATUS or its latest report).
final sosTagsProvider = Provider<List<SosTag>>((ref) {
  final devices =
      ref.watch(userDevicesProvider).valueOrNull ?? const <DeviceSummary>[];
  final nowMs = DateTime.now().millisecondsSinceEpoch;
  final result = <SosTag>[];

  for (final d in devices) {
    final report = ref.watch(latestReportProvider(d.deviceId)).valueOrNull;
    final hasBle = d.bleId.isNotEmpty;
    final connected = hasBle &&
        (ref.watch(tagLinkProvider(d.bleId)).valueOrNull?.isConnected ?? false);
    final status =
        hasBle ? ref.watch(tagBleStatusProvider(d.bleId)).valueOrNull : null;

    final info = TagModeResolver.resolve(
      bleConnected: connected,
      bleStatus: status,
      report: report,
      nowMs: nowMs,
    );
    if (info.sos) {
      result.add(SosTag(
        device: d,
        report: report,
        batteryPct: connected && status != null ? status.batteryPct : report?.bat,
      ));
    }
  }
  return result;
});
