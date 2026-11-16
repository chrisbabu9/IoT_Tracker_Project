import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/data/ble/fake_tag_ble_service.dart';
import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/data/ble/tp_ble_protocol.dart';
import '../helpers.dart';

void main() {
  late FakeTagBleService ble;
  setUp(() => ble = FakeTagBleService(autoStartRssi: false));
  tearDown(() => ble.dispose());

  group('FakeTagBleService (T-B2)', () {
    test('linkState emits current value first (-68, connected)', () async {
      final l = await ble.linkState('SIM:x').first;
      expect((l.isConnected, l.rssi), (true, -68));
    });
    test('simulateRssi clamps and emits', () async {
      final seen = <BleLink>[];
      final sub = ble.linkState('SIM:x').listen(seen.add);
      await settle();
      ble.simulateRssi(-20);
      await settle();
      expect(seen.last.rssi, -30);
      await sub.cancel();
    });
    test('disconnect/reconnect', () async {
      final seen = <BleLink>[];
      final sub = ble.linkState('SIM:x').listen(seen.add);
      await settle();
      ble.simulateDisconnect();
      await settle();
      expect((seen.last.isConnected, seen.last.rssi), (false, -100));
      ble.simulateReconnect();
      await settle();
      expect(seen.last.isConnected, isTrue);
      await sub.cancel();
    });
    test('setBuzzer updates status flag', () async {
      final seen = <TagStatus>[];
      final sub = ble.status('SIM:x').listen(seen.add);
      await settle();
      await ble.setBuzzer('SIM:x', true);
      await settle();
      expect(seen.last.buzzerOn, isTrue);
      await sub.cancel();
    });
    test('lost / sos commands change mode, off returns to near', () async {
      await ble.sendCommand('SIM:x', TagBleCommand.lostOn);
      var s = await ble.status('SIM:x').first;
      expect((s.mode, s.lostModeOn), ('lost', true));
      await ble.sendCommand('SIM:x', TagBleCommand.lostOff);
      s = await ble.status('SIM:x').first;
      expect((s.mode, s.lostModeOn), ('near', false));
      await ble.sendCommand('SIM:x', TagBleCommand.sosOn);
      expect((await ble.status('SIM:x').first).sosOn, isTrue);
    });
    test('simulateBattery clamps', () async {
      ble.simulateBattery(150, bleId: 'SIM:x');
      expect((await ble.status('SIM:x').first).batteryPct, 100);
    });
    test('scan returns one fake tag', () async {
      final tags = await ble.scanForPairableTags().first;
      expect(tags.single.name, 'TP-5E60');
    });
    test('pairAndBond returns fake ids', () async {
      final p = await ble.pairAndBond(const ScannedTag(bleId: 'b', name: 'TP-1', rssi: -60));
      expect((p.deviceId, p.bleId, p.name), (ble.fakeDeviceId, 'b', 'TP-1'));
    });
    test('B-02: per-tag state; real (non-SIM) ids are never connected', () async {
      ble.simulateDisconnect(bleId: 'SIM:a');
      expect((await ble.linkState('SIM:a').first).isConnected, isFalse);
      expect((await ble.linkState('SIM:b').first).isConnected, isTrue);
      expect((await ble.linkState('AA:BB:CC').first).isConnected, isFalse);
    });
    test('B-02: no-arg simulate* applies to simulated tags only', () async {
      await ble.linkState('SIM:a').first;
      await ble.linkState('AA:BB').first;
      ble.simulateRssi(-50);
      expect((await ble.linkState('SIM:a').first).rssi, -50);
      expect((await ble.linkState('AA:BB').first).rssi, -100);
    });
    test('sim ids are namespaced', () {
      expect(ble.fakeDeviceId.startsWith('sim_'), isTrue);
      expect(ble.fakeBleId.startsWith('SIM:'), isTrue);
    });
  });
}
