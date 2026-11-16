import 'dart:async';
import 'package:trackpoint/data/ble/tp_ble_protocol.dart';

/// Connection state of a BLE link with a tag
enum BleConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

/// Snapshot of the BLE connection and signal strength
class BleLink {
  final String bleId;
  final BleConnectionStatus status;
  final int rssi; // dBm

  const BleLink({
    required this.bleId,
    required this.status,
    required this.rssi,
  });

  bool get isConnected => status == BleConnectionStatus.connected;
}

/// A tag found during BLE scan
class ScannedTag {
  final String bleId;
  final String name; // e.g. TP-5E60
  final int rssi;
  final dynamic nativeDevice;

  const ScannedTag({
    required this.bleId,
    required this.name,
    required this.rssi,
    this.nativeDevice,
  });
}

/// Result of a successful pairing and bonding procedure
class PairedTag {
  final String deviceId; // e.g. tp_9f3a7c21b4d85e60
  final String bleId; // MAC address or iOS UUID
  final String name;
  final String fw;

  const PairedTag({
    required this.deviceId,
    required this.bleId,
    required this.name,
    required this.fw,
  });
}

/// Interface for Bluetooth Low Energy operations with TrackPoint tags.
abstract class TagBleService {
  /// Scans for nearby tags advertising the TrackPoint service UUID.
  Stream<List<ScannedTag>> scanForPairableTags();

  /// Stops an active scan.
  Future<void> stopScan();

  /// Connects, bonds, and reads the DEVICE_INFO characteristic.
  Future<PairedTag> pairAndBond(ScannedTag tag);

  /// Monitors link state and RSSI for a given tag.
  Stream<BleLink> linkState(String bleId);

  /// Listens to decoded STATUS characteristic notifications.
  Stream<TagStatus> status(String bleId);

  /// Writes to BUZZER characteristic (0x01 = on, 0x00 = off).
  Future<void> setBuzzer(String bleId, bool on);

  /// Writes a command to COMMAND characteristic.
  Future<void> sendCommand(String bleId, TagBleCommand c);

  /// Manually disconnects from a tag.
  Future<void> disconnect(String bleId);

  /// Unbonds and disconnects from a tag.
  Future<void> removeBond(String bleId);

  /// Start (or keep alive) an auto-reconnecting link to an already bonded tag.
  /// Returns immediately; link changes arrive through [linkState].
  Future<void> connectKnown(String bleId);

  /// Releases streams/timers. Called when the provider is disposed.
  void dispose();
}
