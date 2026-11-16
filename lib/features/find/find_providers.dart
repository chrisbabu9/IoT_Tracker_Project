import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/data/models/tag_command.dart';
import 'package:trackpoint/domain/distance_zone.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/find/buzzer_controller.dart';

/// The currently selected tag (null when the user has no tags).
final selectedTagProvider = Provider<DeviceSummary?>((ref) {
  final id = ref.watch(selectedDeviceIdProvider);
  final devices =
      ref.watch(userDevicesProvider).valueOrNull ?? const <DeviceSummary>[];
  for (final d in devices) {
    if (d.deviceId == id) return d;
  }
  return null;
});

/// Smoothed distance zone of the selected tag (null when not connected).
/// RSSI -> median of last 7 -> exponential average, see [DistanceZoneCalculator].
final findZoneProvider = StreamProvider.autoDispose<DistanceZoneResult?>((ref) {
  final bleId = ref.watch(selectedTagProvider.select((t) => t?.bleId));
  if (bleId == null || bleId.isEmpty) return Stream.value(null);

  final calculator = DistanceZoneCalculator();
  return ref
      .watch(bleServiceProvider)
      .linkState(bleId)
      .map<DistanceZoneResult?>((link) {
    if (!link.isConnected) {
      calculator.reset();
      return null;
    }
    return calculator.addSample(link.rssi);
  });
});

typedef CommandKey = ({String deviceId, String commandId});

/// Live status of one cloud command (BUZZER_ON / BUZZER_OFF).
final commandStatusProvider =
    StreamProvider.autoDispose.family<TagCommand?, CommandKey>((ref, key) {
  return ref
      .watch(commandRepositoryProvider)
      .watchCommand(key.deviceId, key.commandId);
});

final buzzerControllerProvider = Provider<BuzzerController>((ref) {
  return BuzzerController(
    ble: ref.watch(bleServiceProvider),
    commands: ref.watch(commandRepositoryProvider),
  );
});
