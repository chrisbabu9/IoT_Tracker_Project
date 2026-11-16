import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/data/ble/fake_tag_ble_service.dart';
import 'package:trackpoint/data/ble/flutter_blue_plus_service.dart';
import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/data/firebase/auth_repository.dart';
import 'package:trackpoint/data/firebase/command_repository.dart';
import 'package:trackpoint/data/firebase/config_repository.dart';
import 'package:trackpoint/data/firebase/device_repository.dart';
import 'package:trackpoint/data/firebase/report_repository.dart';
import 'package:trackpoint/data/models/device_summary.dart';

/// Simulation mode toggle (real BLE vs FakeTagBleService). Defaults to OFF in
/// release builds; main() overrides it with the persisted user choice.
final simulationModeProvider = StateProvider<bool>((ref) => !kReleaseMode);

/// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return FirebaseDeviceRepository();
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return FirebaseReportRepository();
});

final commandRepositoryProvider = Provider<CommandRepository>((ref) {
  return FirebaseCommandRepository();
});

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return FirebaseConfigRepository();
});

/// BLE Service Provider - dynamically switches based on simulationModeProvider
final bleServiceProvider = Provider<TagBleService>((ref) {
  final isSimulation = ref.watch(simulationModeProvider);
  final TagBleService service =
      isSimulation ? FakeTagBleService() : FlutterBluePlusTagBleService();
  ref.onDispose(service.dispose);
  return service;
});

/// Auth state stream provider
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Current signed in user
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// User display timezone preference provider
final userTimezoneProvider = StateProvider<String>((ref) {
  return DateTime.now().timeZoneName;
});

/// Theme mode provider (default: dark)
final themeModeProvider = StateProvider<bool>((ref) => true); // true = dark, false = light

/// User's device list provider
final userDevicesProvider = StreamProvider<List<DeviceSummary>>((ref) {
  final user = ref.watch(currentUserProvider);
  final sim = ref.watch(simulationModeProvider);
  if (user == null) return Stream.value([]);
  // Simulated (sim_*) and real tags are kept apart so ghost tags never leak
  // between modes.
  return ref.watch(deviceRepositoryProvider).watchUserDevices(user.uid).map(
      (l) => l
          .where((d) => d.deviceId.startsWith(AppConfig.simDevicePrefix) == sim)
          .toList());
});

/// The tag the user explicitly picked (null = none picked yet).
final selectedDeviceOverrideProvider = StateProvider<String?>((ref) => null);

/// Currently selected tag for dashboard & map. Derived: keeps the user's pick
/// while it still exists, otherwise falls back to the first tag.
final selectedDeviceIdProvider = Provider<String?>((ref) {
  final devices = ref.watch(userDevicesProvider).valueOrNull ?? const [];
  final picked = ref.watch(selectedDeviceOverrideProvider);
  if (picked != null && devices.any((d) => d.deviceId == picked)) {
    return picked;
  }
  return devices.isEmpty ? null : devices.first.deviceId;
});
