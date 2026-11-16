import 'dart:async';
import 'dart:math';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/data/ble/tp_ble_protocol.dart';

/// Simulated state of one fake tag. Only ids starting with
/// [AppConfig.simBlePrefix] are "connected"; real tag ids stay disconnected.
class _Sim {
  _Sim(this.connected);
  int rssi = -68;
  int battery = 85;
  int mode = TpBleProtocol.modeNear;
  bool buzzer = false, lost = false, sos = false;
  bool connected;
}

/// Scripted mock BLE service for development, widget tests, and simulation mode.
class FakeTagBleService implements TagBleService {
  final String fakeDeviceId;
  final String fakeBleId;
  final String fakeName;
  final String fakeFw;

  final StreamController<List<ScannedTag>> _scanController =
      StreamController<List<ScannedTag>>.broadcast();
  final Map<String, StreamController<BleLink>> _linkControllers = {};
  final Map<String, StreamController<TagStatus>> _statusControllers = {};
  final Map<String, _Sim> _sims = {};

  Timer? _rssiWalkTimer;
  Timer? _scanTimer;

  FakeTagBleService({
    this.fakeDeviceId = '${AppConfig.simDevicePrefix}9f3a7c21b4d85e60',
    this.fakeBleId = '${AppConfig.simBlePrefix}00:11:22:33:44:55',
    this.fakeName = 'TP-5E60',
    this.fakeFw = '0.1.0',
    bool autoStartRssi = true,
  }) {
    if (autoStartRssi) _startRssiSimulation();
  }

  _Sim _s(String bleId) =>
      _sims.putIfAbsent(bleId, () => _Sim(AppConfig.isSimBleId(bleId)));

  /// Ids a no-argument simulate*() call applies to: all known simulated tags.
  Iterable<String> _targets(String? bleId) => bleId != null
      ? [bleId]
      : {..._linkControllers.keys, ..._statusControllers.keys, ..._sims.keys}
          .where(AppConfig.isSimBleId);

  void _startRssiSimulation() {
    final random = Random();
    _rssiWalkTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      for (final id in _linkControllers.keys.toList()) {
        final s = _s(id);
        if (!s.connected) continue;
        s.rssi = (s.rssi + random.nextInt(7) - 3).clamp(-95, -45); // random walk
        _emitLink(id);
      }
    });
  }

  BleLink _currentLink(String id) {
    final s = _s(id);
    return BleLink(
      bleId: id,
      status: s.connected
          ? BleConnectionStatus.connected
          : BleConnectionStatus.disconnected,
      rssi: s.connected ? s.rssi : -100,
    );
  }

  TagStatus _currentStatus(String id) {
    final s = _s(id);
    return TagStatus(
      batteryPct: s.battery,
      modeCode: s.mode,
      mode: switch (s.mode) {
        TpBleProtocol.modeNear => 'near',
        TpBleProtocol.modeAway => 'away',
        TpBleProtocol.modeLost => 'lost',
        TpBleProtocol.modeSos => 'sos',
        _ => 'unpaired',
      },
      buzzerOn: s.buzzer,
      lostModeOn: s.lost,
      sosOn: s.sos,
    );
  }

  void _emitLink(String id) {
    final c = _linkControllers[id];
    if (c != null && !c.isClosed) c.add(_currentLink(id));
  }

  void _emitStatus(String id) {
    final c = _statusControllers[id];
    if (c != null && !c.isClosed) c.add(_currentStatus(id));
  }

  @override
  Stream<List<ScannedTag>> scanForPairableTags() {
    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_scanController.isClosed) {
        _scanController
            .add([ScannedTag(bleId: fakeBleId, name: fakeName, rssi: -62)]);
      }
    });
    return _scanController.stream;
  }

  @override
  Future<void> stopScan() async => _scanTimer?.cancel();

  @override
  Future<PairedTag> pairAndBond(ScannedTag tag) async {
    await Future.delayed(const Duration(milliseconds: 800)); // bonding delay
    final s = _s(tag.bleId)
      ..connected = true
      ..mode = TpBleProtocol.modeNear;
    s.rssi = -68;
    _emitLink(tag.bleId);
    _emitStatus(tag.bleId);
    return PairedTag(
        deviceId: fakeDeviceId, bleId: tag.bleId, name: tag.name, fw: fakeFw);
  }

  // Every subscriber first receives the current state, then live updates.
  @override
  Stream<BleLink> linkState(String bleId) async* {
    final c = _linkControllers.putIfAbsent(
        bleId, () => StreamController<BleLink>.broadcast());
    yield _currentLink(bleId);
    yield* c.stream;
  }

  @override
  Stream<TagStatus> status(String bleId) async* {
    final c = _statusControllers.putIfAbsent(
        bleId, () => StreamController<TagStatus>.broadcast());
    yield _currentStatus(bleId);
    yield* c.stream;
  }

  @override
  Future<void> setBuzzer(String bleId, bool on) async {
    _s(bleId).buzzer = on;
    _emitStatus(bleId);
  }

  @override
  Future<void> sendCommand(String bleId, TagBleCommand c) async {
    final s = _s(bleId);
    final idle = s.connected ? TpBleProtocol.modeNear : TpBleProtocol.modeAway;
    switch (c) {
      case TagBleCommand.lostOn:
        s.lost = true;
        s.mode = TpBleProtocol.modeLost;
      case TagBleCommand.lostOff:
        s.lost = false;
        s.mode = idle;
      case TagBleCommand.sosOn:
        s.sos = true;
        s.mode = TpBleProtocol.modeSos;
      case TagBleCommand.sosOff:
        s.sos = false;
        s.mode = idle;
      case TagBleCommand.reportNow:
        break;
    }
    _emitStatus(bleId);
  }

  @override
  Future<void> disconnect(String bleId) async => simulateDisconnect(bleId: bleId);

  @override
  Future<void> removeBond(String bleId) async {
    await disconnect(bleId);
    _sims.remove(bleId);
  }

  @override
  Future<void> connectKnown(String bleId) async => _emitLink(bleId);

  // ---- Simulation / test helpers (bleId == null -> all simulated tags) ----

  void simulateRssi(int rssi, {String? bleId}) {
    for (final id in _targets(bleId)) {
      _s(id).rssi = rssi.clamp(-100, -30);
      _emitLink(id);
    }
  }

  void simulateDisconnect({String? bleId}) {
    for (final id in _targets(bleId)) {
      final s = _s(id);
      s.connected = false;
      if (s.mode == TpBleProtocol.modeNear) s.mode = TpBleProtocol.modeAway;
      _emitLink(id);
      _emitStatus(id);
    }
  }

  void simulateReconnect({String? bleId}) {
    for (final id in _targets(bleId)) {
      final s = _s(id);
      s.connected = true;
      if (s.mode == TpBleProtocol.modeAway) s.mode = TpBleProtocol.modeNear;
      _emitLink(id);
      _emitStatus(id);
    }
  }

  void simulateBattery(int pct, {String? bleId}) {
    for (final id in _targets(bleId)) {
      _s(id).battery = pct.clamp(0, 100);
      _emitStatus(id);
    }
  }

  @override
  void dispose() {
    _rssiWalkTimer?.cancel();
    _scanTimer?.cancel();
    _scanController.close();
    for (final c in _linkControllers.values) {
      c.close();
    }
    for (final c in _statusControllers.values) {
      c.close();
    }
  }
}
