import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/features/auth/auth_state.dart';

/// Keeps an auto-reconnecting BLE link open to every paired tag.
/// Watch it once at app level while a user is signed in.
final tagConnectionManagerProvider = Provider<void>((ref) {
  final devices =
      ref.watch(userDevicesProvider).valueOrNull ?? const <DeviceSummary>[];
  final ble = ref.watch(bleServiceProvider);
  for (final device in devices) {
    if (device.bleId.isNotEmpty) {
      unawaited(ble.connectKnown(device.bleId));
    }
  }
});
