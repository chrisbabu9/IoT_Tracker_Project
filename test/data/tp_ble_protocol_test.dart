import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/data/ble/tp_ble_protocol.dart';

void main() {
  group('TpBleProtocol (T-B1..)', () {
    test('buzzer encode/decode', () {
      expect(TpBleProtocol.encodeBuzzer(true), [1]);
      expect(TpBleProtocol.encodeBuzzer(false), [0]);
      expect(TpBleProtocol.decodeBuzzer([1]), isTrue);
      expect(TpBleProtocol.decodeBuzzer([0]), isFalse);
      expect(TpBleProtocol.decodeBuzzer([]), isFalse);
    });
    test('decodeStatus parses battery, mode, flags', () {
      final s = TpBleProtocol.decodeStatus([85, 2, 0x05, 0]);
      expect(s.batteryPct, 85);
      expect(s.mode, 'away');
      expect(s.buzzerOn, isTrue);
      expect(s.lostModeOn, isFalse);
      expect(s.sosOn, isTrue);
    });
    test('decodeStatus clamps battery and maps unknown mode', () {
      final s = TpBleProtocol.decodeStatus([250, 9, 0, 0]);
      expect(s.batteryPct, 100);
      expect(s.mode, 'unknown');
    });
    test('decodeStatus rejects short payload', () {
      expect(() => TpBleProtocol.decodeStatus([1, 2, 3]), throwsFormatException);
    });
    test('encodeStatus <-> decodeStatus round trip', () {
      final bytes = TpBleProtocol.encodeStatus(
          batteryPct: 42, modeCode: TpBleProtocol.modeLost, lostModeOn: true, buzzerOn: true);
      expect(bytes.length, 4);
      final s = TpBleProtocol.decodeStatus(bytes);
      expect((s.batteryPct, s.mode, s.lostModeOn, s.buzzerOn, s.sosOn),
          (42, 'lost', true, true, false));
    });
    test('encodeStatus clamps inputs', () {
      final b = TpBleProtocol.encodeStatus(batteryPct: 500, modeCode: 99);
      expect(b[0], 100);
      expect(b[1], 4);
    });
    test('device info round trip + defaults', () {
      final info = TpBleProtocol.decodeDeviceInfo(TpBleProtocol.encodeDeviceInfo('tp_1', '0.2.0'));
      expect((info.id, info.fw), ('tp_1', '0.2.0'));
      final empty = TpBleProtocol.decodeDeviceInfo('{}'.codeUnits);
      expect((empty.id, empty.fw), ('', '0.0.0'));
    });
    test('invalid device info JSON throws', () {
      expect(() => TpBleProtocol.decodeDeviceInfo('nope'.codeUnits), throwsFormatException);
    });
    test('encodeCommand codes', () {
      expect(TagBleCommand.values.map((c) => TpBleProtocol.encodeCommand(c).single).toList(),
          [1, 2, 3, 4, 5]);
    });
    test('TagStatus.toString mentions battery', () {
      expect(TpBleProtocol.decodeStatus([7, 1, 0, 0]).toString(), contains('7%'));
    });
  });
}
