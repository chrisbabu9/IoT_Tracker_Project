import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/data/ble/tp_ble_protocol.dart';

/// Production implementation of [TagBleService] using `flutter_blue_plus`.
///
/// One connection-state subscription is kept per tag. Every listener of
/// [linkState] / [status] first receives the last known value, then live
/// updates. While connected and listened to, RSSI is refreshed every 3 s.
class FlutterBluePlusTagBleService implements TagBleService {
  static const Duration _rssiPollInterval = Duration(seconds: 3);

  final Map<String, BluetoothDevice> _knownDevices = {};
  final Map<String, StreamSubscription<BluetoothConnectionState>>
      _connectionSubs = {};
  final Map<String, StreamSubscription<List<int>>> _statusSubs = {};
  final Map<String, StreamController<BleLink>> _linkControllers = {};
  final Map<String, StreamController<TagStatus>> _statusControllers = {};
  final Map<String, BluetoothService> _services = {};
  final Map<String, BleLink> _lastLink = {};
  final Map<String, TagStatus> _lastStatus = {};
  final Map<String, Timer> _rssiTimers = {};
  final Set<String> _autoConnecting = {};

  BluetoothDevice _deviceFor(String bleId) => _knownDevices.putIfAbsent(
        bleId,
        () => BluetoothDevice.fromId(bleId),
      );

  StreamController<BleLink> _linkController(String bleId) =>
      _linkControllers.putIfAbsent(
        bleId,
        () => StreamController<BleLink>.broadcast(),
      );

  StreamController<TagStatus> _statusController(String bleId) =>
      _statusControllers.putIfAbsent(
        bleId,
        () => StreamController<TagStatus>.broadcast(),
      );

  // ---------------------------------------------------------------------------
  // Scanning & pairing
  // ---------------------------------------------------------------------------

  @override
  Stream<List<ScannedTag>> scanForPairableTags() async* {
    final serviceGuid = Guid(AppConfig.bleServiceUuid);
    debugPrint('[BLE_SCAN] Starting scan (service=$serviceGuid, namePrefix=TP-)');

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      debugPrint('[BLE_SCAN] startScan error: $e');
      rethrow;
    }

    yield* FlutterBluePlus.scanResults.map((results) {
      final matched = <ScannedTag>[];
      for (final result in results) {
        final platformName = result.device.platformName;
        final advName = result.advertisementData.advName;
        final name = platformName.isNotEmpty ? platformName : advName;
        final hasService =
            result.advertisementData.serviceUuids.contains(serviceGuid);
        final matchesName = name.startsWith('TP-') ||
            name.toLowerCase().contains('trackpoint');

        if (hasService || matchesName) {
          debugPrint(
            '[BLE_SCAN] MATCH: "$name" [${result.device.remoteId.str}] '
            'rssi=${result.rssi} hasService=$hasService',
          );
          _knownDevices[result.device.remoteId.str] = result.device;
          matched.add(ScannedTag(
            bleId: result.device.remoteId.str,
            name: name.isNotEmpty ? name : 'TrackPoint Tag',
            rssi: result.rssi,
            nativeDevice: result.device,
          ));
        }
      }
      return matched;
    });
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  @override
  Future<PairedTag> pairAndBond(ScannedTag tag) async {
    final bleId = tag.bleId;
    debugPrint('[BLE_PAIR] Connecting to bleId=$bleId name="${tag.name}"');
    final device = _knownDevices[bleId] ?? BluetoothDevice.fromId(bleId);
    _knownDevices[bleId] = device;

    try {
      // 1. Connect
      debugPrint('[BLE_PAIR] Step 1: Connecting with 15s timeout...');
      await device.connect(timeout: const Duration(seconds: 15));
      debugPrint('[BLE_PAIR] Step 1: Connect OK. isConnected=${device.isConnected}');

      // 2. Android bonding with short timeout (so headless BlueZ never blocks the app)
      if (!kIsWeb && Platform.isAndroid) {
        try {
          debugPrint('[BLE_PAIR] Step 2: Attempting Android createBond (timeout 4s)...');
          await device.createBond().timeout(const Duration(seconds: 4));
          debugPrint('[BLE_PAIR] Step 2: createBond completed');
        } catch (e) {
          debugPrint('[BLE_PAIR] Step 2: createBond skipped/proceeding without OS bond ($e)');
        }
      }

      // 3. Service discovery
      debugPrint('[BLE_PAIR] Step 3: Discovering services...');
      final service = await _discoverTrackPointService(device);
      _services[bleId] = service;
      debugPrint('[BLE_PAIR] Step 3: Found service ${service.uuid}');

      // 4. Read DEVICE_INFO
      debugPrint('[BLE_PAIR] Step 4: Reading DEVICE_INFO (${AppConfig.bleDeviceInfoUuid})...');
      final infoChar = _findCharacteristic(service, AppConfig.bleDeviceInfoUuid);
      final rawBytes = await infoChar.read();
      debugPrint('[BLE_PAIR] Step 4: Read ${rawBytes.length} bytes: $rawBytes');
      final deviceInfo = TpBleProtocol.decodeDeviceInfo(rawBytes);
      debugPrint('[BLE_PAIR] Step 4: Decoded id="${deviceInfo.id}", fw="${deviceInfo.fw}"');

      // 5. Setup status
      debugPrint('[BLE_PAIR] Step 5: Setting up STATUS subscription...');
      await _setupStatus(bleId, service);
      _attach(bleId);
      debugPrint('[BLE_PAIR] Step 5: Status attached successfully');

      return PairedTag(
        deviceId: deviceInfo.id,
        bleId: bleId,
        name: tag.name,
        fw: deviceInfo.fw,
      );
    } catch (e, st) {
      debugPrint('[BLE_PAIR] Error during pairAndBond: $e');
      debugPrint('[BLE_PAIR] Stack: $st');
      try {
        await device.disconnect();
      } catch (_) {}
      throw DeviceException('Failed to pair with tag: $e', cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Link state, status and auto-reconnect
  // ---------------------------------------------------------------------------

  @override
  Stream<BleLink> linkState(String bleId) {
    if (AppConfig.isSimBleId(bleId)) {
      return Stream.value(BleLink(
          bleId: bleId, status: BleConnectionStatus.disconnected, rssi: -100));
    }
    _attach(bleId);
    return _withInitial<BleLink>(
        _lastLink[bleId], _linkController(bleId).stream);
  }

  @override
  Stream<TagStatus> status(String bleId) {
    if (AppConfig.isSimBleId(bleId)) return const Stream.empty();
    _attach(bleId);
    return _withInitial<TagStatus>(
        _lastStatus[bleId], _statusController(bleId).stream);
  }

  Stream<T> _withInitial<T>(T? initial, Stream<T> rest) async* {
    if (initial != null) yield initial;
    yield* rest;
  }

  @override
  Future<void> connectKnown(String bleId) async {
    if (AppConfig.isSimBleId(bleId)) return; // simulated ghost tag
    final device = _deviceFor(bleId);
    _attach(bleId);
    if (device.isConnected || _autoConnecting.contains(bleId)) return;

    _autoConnecting.add(bleId);
    unawaited(() async {
      try {
        // autoConnect keeps a pending connection that the OS completes
        // whenever the tag is in range. It requires mtu: null.
        await device.connect(autoConnect: true, mtu: null);
      } catch (e) {
        debugPrint('[BLE] autoConnect failed for $bleId: $e');
      } finally {
        _autoConnecting.remove(bleId);
      }
    }());
  }

  /// Listens once per tag to the OS connection state.
  void _attach(String bleId) {
    if (_connectionSubs.containsKey(bleId)) return;
    final device = _deviceFor(bleId);
    _connectionSubs[bleId] = device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.connected) {
        await _onConnected(bleId, device);
      } else {
        _onDisconnected(bleId);
      }
    });
  }

  Future<void> _onConnected(String bleId, BluetoothDevice device) async {
    await _emitLink(bleId, device);
    _startRssiPolling(bleId, device);

    // Already set up (e.g. right after pairing): nothing more to do.
    if (_services.containsKey(bleId) && _statusSubs.containsKey(bleId)) return;

    try {
      final service = await _discoverTrackPointService(device);
      _services[bleId] = service;
      await _setupStatus(bleId, service);
    } catch (e) {
      debugPrint('[BLE] post-connect setup failed for $bleId: $e');
    }
  }

  void _onDisconnected(String bleId) {
    _rssiTimers.remove(bleId)?.cancel();
    _services.remove(bleId);
    _statusSubs.remove(bleId)?.cancel();
    _addLink(
      bleId,
      BleLink(
        bleId: bleId,
        status: BleConnectionStatus.disconnected,
        rssi: -100,
      ),
    );
  }

  Future<void> _emitLink(String bleId, BluetoothDevice device) async {
    // keep the last known RSSI if a read fails (avoids a false "edge of range")
    var rssi = _lastLink[bleId]?.rssi ?? -100;
    try {
      rssi = await device.readRssi();
    } catch (_) {}
    _addLink(
      bleId,
      BleLink(
        bleId: bleId,
        status: BleConnectionStatus.connected,
        rssi: rssi,
      ),
    );
  }

  void _addLink(String bleId, BleLink link) {
    _lastLink[bleId] = link;
    final controller = _linkController(bleId);
    if (!controller.isClosed) controller.add(link);
  }

  void _startRssiPolling(String bleId, BluetoothDevice device) {
    _rssiTimers[bleId]?.cancel();
    _rssiTimers[bleId] = Timer.periodic(_rssiPollInterval, (_) async {
      final controller = _linkControllers[bleId];
      if (controller == null || !controller.hasListener) return;
      if (!device.isConnected) return;
      await _emitLink(bleId, device);
    });
  }

  // ---------------------------------------------------------------------------
  // GATT helpers
  // ---------------------------------------------------------------------------

  Future<BluetoothService> _discoverTrackPointService(
      BluetoothDevice device) async {
    final services = await device.discoverServices();
    return services.firstWhere(
      (s) => s.uuid == Guid(AppConfig.bleServiceUuid),
      orElse: () => throw const DeviceException(
          'TrackPoint BLE service not found on this peripheral.'),
    );
  }

  BluetoothCharacteristic _findCharacteristic(
      BluetoothService service, String uuid) {
    return service.characteristics.firstWhere(
      (c) => c.uuid == Guid(uuid),
      orElse: () =>
          throw DeviceException('BLE characteristic $uuid not found.'),
    );
  }

  Future<BluetoothCharacteristic> _requireCharacteristic(
      String bleId, String uuid) async {
    final device = _deviceFor(bleId);
    if (!device.isConnected) {
      throw const DeviceException('Tag is not connected via BLE');
    }
    var service = _services[bleId];
    if (service == null) {
      service = await _discoverTrackPointService(device);
      _services[bleId] = service;
    }
    return _findCharacteristic(service, uuid);
  }

  Future<void> _setupStatus(String bleId, BluetoothService service) async {
    try {
      final statusChar = _findCharacteristic(service, AppConfig.bleStatusUuid);
      await statusChar.setNotifyValue(true);
      await _statusSubs[bleId]?.cancel();
      _statusSubs[bleId] = statusChar.onValueReceived
          .listen((bytes) => _handleStatus(bleId, bytes));
      try {
        _handleStatus(bleId, await statusChar.read());
      } catch (_) {}
    } catch (e) {
      debugPrint('[BLE] STATUS setup failed for $bleId: $e');
    }
  }

  void _handleStatus(String bleId, List<int> bytes) {
    if (bytes.length < 4) return;
    final decoded = TpBleProtocol.decodeStatus(bytes);
    _lastStatus[bleId] = decoded;
    final controller = _statusController(bleId);
    if (!controller.isClosed) controller.add(decoded);
  }

  // ---------------------------------------------------------------------------
  // Commands
  // ---------------------------------------------------------------------------

  @override
  Future<void> setBuzzer(String bleId, bool on) async {
    final char =
        await _requireCharacteristic(bleId, AppConfig.bleBuzzerUuid);
    await char.write(TpBleProtocol.encodeBuzzer(on), withoutResponse: false);
  }

  @override
  Future<void> sendCommand(String bleId, TagBleCommand c) async {
    final char =
        await _requireCharacteristic(bleId, AppConfig.bleCommandUuid);
    await char.write(TpBleProtocol.encodeCommand(c), withoutResponse: false);
  }

  @override
  Future<void> disconnect(String bleId) async {
    final device = _knownDevices[bleId];
    if (device != null) {
      await device.disconnect();
    }
  }

  @override
  Future<void> removeBond(String bleId) async {
    final device = _deviceFor(bleId);
    try {
      await device.disconnect();
    } catch (_) {}
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await device.removeBond();
      } catch (_) {}
    }
    _rssiTimers.remove(bleId)?.cancel();
    await _connectionSubs.remove(bleId)?.cancel();
    await _statusSubs.remove(bleId)?.cancel();
    _services.remove(bleId);
    _lastLink.remove(bleId);
    _lastStatus.remove(bleId);
    _knownDevices.remove(bleId);
  }

  @override
  void dispose() {
    for (final t in _rssiTimers.values) {
      t.cancel();
    }
    for (final s in _connectionSubs.values) {
      s.cancel();
    }
    for (final s in _statusSubs.values) {
      s.cancel();
    }
    for (final c in _linkControllers.values) {
      c.close();
    }
    for (final c in _statusControllers.values) {
      c.close();
    }
  }
}
