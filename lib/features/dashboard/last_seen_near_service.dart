import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/phone_location.dart';
import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/data/firebase/device_repository.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/features/auth/auth_state.dart';

/// Watches BLE link state for every paired device.
/// On every disconnection event that happens while the phone has a GPS fix,
/// writes `/devices/{deviceId}/lastSeenNear = {lat, lon, ts}`.
///
/// Activate by keeping this provider alive (e.g. in a ProviderScope override or
/// by watching it from a long-lived widget like the root shell).
class LastSeenNearService extends AsyncNotifier<void> {
  final Map<String, StreamSubscription<BleLink>> _subs = {};
  final Map<String, bool> _wasConnected = {};

  @override
  Future<void> build() async {
    final devices = ref.watch(userDevicesProvider).value ?? [];
    final bleService = ref.watch(bleServiceProvider);
    final deviceRepo = ref.watch(deviceRepositoryProvider);

    // Cancel old subscriptions
    for (final sub in _subs.values) {
      await sub.cancel();
    }
    _subs.clear();

    for (final device in devices) {
      final deviceId = device.deviceId;
      final bleId = device.bleId;
      if (bleId.isEmpty) continue;

      _subs[deviceId] = bleService.linkState(bleId).listen((link) async {
        final wasConnected = _wasConnected[deviceId] ?? false;
        final nowConnected = link.isConnected;
        _wasConnected[deviceId] = nowConnected;

        // Transition: connected → disconnected
        if (wasConnected && !nowConnected) {
          await _tryWriteLastSeenNear(deviceId, deviceRepo);
        }
      });
    }

    // Dispose subscriptions when provider is disposed
    ref.onDispose(() async {
      for (final sub in _subs.values) {
        await sub.cancel();
      }
      _subs.clear();
    });
  }

  Future<void> _tryWriteLastSeenNear(
    String deviceId,
    DeviceRepository deviceRepo,
  ) async {
    // No permission prompt here (runs in background); silent when unavailable.
    final pos = await PhoneLocation.current();
    if (pos == null) return;
    await deviceRepo.recordLastSeenNear(
      deviceId: deviceId,
      lat: pos.latitude,
      lon: pos.longitude,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

final lastSeenNearServiceProvider =
    AsyncNotifierProvider<LastSeenNearService, void>(LastSeenNearService.new);

/// Watches last-seen-near for the currently selected device from RTDB.
final selectedDeviceLastSeenNearProvider =
    StreamProvider<LastSeenNear?>((ref) {
  final deviceId = ref.watch(selectedDeviceIdProvider);
  if (deviceId == null) return Stream.value(null);
  return ref.watch(deviceRepositoryProvider).watchLastSeenNear(deviceId);
});
