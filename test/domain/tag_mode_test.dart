import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/data/ble/tp_ble_protocol.dart';
import 'package:trackpoint/domain/tag_mode.dart';
import '../helpers.dart';

TagStatus st({bool lost = false, bool sos = false, String mode = 'near'}) => TagStatus(
    batteryPct: 50, modeCode: 1, mode: mode, buzzerOn: false, lostModeOn: lost, sosOn: sos);

void main() {
  const now = 100000000;
  group('TagModeResolver.resolve (T-D7)', () {
    test('BLE status is authoritative while connected', () {
      final r = TagModeResolver.resolve(
          bleConnected: true,
          bleStatus: st(lost: true),
          report: rep(mode: 'away', srv: now),
          nowMs: now);
      expect(r.lostMode, isTrue);
      expect(r.sos, isFalse);
    });
    test('connected status "not lost" beats stale lost report', () {
      final r = TagModeResolver.resolve(
          bleConnected: true,
          bleStatus: st(),
          report: rep(mode: 'lost', srv: now),
          nowMs: now);
      expect(r.lostMode, isFalse);
    });
    test('status mode string also counts', () {
      final r = TagModeResolver.resolve(
          bleConnected: true, bleStatus: st(mode: 'sos'), nowMs: now);
      expect(r.sos, isTrue);
    });
    test('connected but no status falls back to report', () {
      final r = TagModeResolver.resolve(
          bleConnected: true, report: rep(mode: 'lost', srv: now), nowMs: now);
      expect(r.lostMode, isTrue);
    });
    test('SOS from report only while recent (<= 6 h)', () {
      bool sosAt(int ageMs) => TagModeResolver.resolve(
              bleConnected: false,
              report: rep(mode: 'sos', srv: now - ageMs),
              nowMs: now)
          .sos;
      expect(sosAt(TagModeResolver.sosMaxAgeMs), isTrue);
      expect(sosAt(TagModeResolver.sosMaxAgeMs + 1), isFalse);
    });
    test('no report -> nothing active', () {
      final r = TagModeResolver.resolve(bleConnected: false, nowMs: now);
      expect(r.lostMode || r.sos, isFalse);
    });
  });
}
