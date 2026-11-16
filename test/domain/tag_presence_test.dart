import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/domain/tag_presence.dart';
import '../helpers.dart';

const now = 10000000;
TagPresenceInfo c({TagReport? r, bool ble = false, int timeout = 900}) =>
    TagPresence.compute(
        isBleConnected: ble,
        latestReport: r,
        offlineTimeoutSeconds: timeout,
        currentTimestampMs: now);
TagReport at(String mode, int ageS, {int bat = 80}) =>
    rep(mode: mode, srv: now - ageS * 1000, bat: bat);

void main() {
  group('TagPresence.compute (T-D6)', () {
    test('BLE connected -> near even without report', () {
      final p = c(ble: true);
      expect(p.state, PresenceState.near);
      expect(p.isNear && p.isLive, isTrue);
      expect(p.lastCommunicationMs, now);
    });
    test('no report -> neverConnected', () {
      expect(c().state, PresenceState.neverConnected);
      expect(c(r: rep(srv: 0)).isNeverConnected, isTrue);
    });
    test('away live then offline at window edge (900 s)', () {
      expect(c(r: at('away', 899)).state, PresenceState.away);
      expect(c(r: at('away', 900)).state, PresenceState.offline);
    });
    test('lost window = 3x interval + 60 (timeout low)', () {
      expect(c(r: at('lost', 239), timeout: 30).state, PresenceState.lost);
      expect(c(r: at('lost', 241), timeout: 30).state, PresenceState.offline);
    });
    test('lost with bat<5 uses 60 s window', () {
      expect(c(r: at('lost', 59, bat: 3), timeout: 30).state, PresenceState.lost);
      expect(c(r: at('lost', 61, bat: 3), timeout: 30).state, PresenceState.offline);
    });
    test('sos window 180 s', () {
      expect(c(r: at('sos', 179), timeout: 30).state, PresenceState.sos);
      expect(c(r: at('sos', 181), timeout: 30).state, PresenceState.offline);
    });
    test('window is max(base, offlineTimeout)', () {
      expect(c(r: at('sos', 500), timeout: 900).state, PresenceState.sos);
    });
    test('mode is case-insensitive; unknown mode -> away', () {
      expect(c(r: at('LOST', 10)).state, PresenceState.lost);
      expect(c(r: at('weird', 10)).state, PresenceState.away);
    });
    test('labels', () {
      expect(c(ble: true).label, 'Near (BLE)');
      expect(c(r: at('away', 1)).label, 'Away (Live)');
      expect(c(r: at('away', 5000)).label, 'Offline');
    });
  });
}
