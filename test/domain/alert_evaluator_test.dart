import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/domain/alert_evaluator.dart';
import 'package:trackpoint/domain/alert_rules.dart';
import '../helpers.dart';

const now = 100000000;
late DeviceAlertState st;

List<AlertEvent> rpt(dynamic r, {int at = now, int timeout = 900}) =>
    AlertEvaluator.onReport(
        st: st, deviceId: 'd', tagName: 'Keys', report: r, nowMs: at, offlineTimeoutS: timeout);
List<AlertEvent> tick(int at, {int timeout = 900}) => AlertEvaluator.onTick(
    st: st, deviceId: 'd', tagName: 'Keys', nowMs: at, offlineTimeoutS: timeout);
Iterable<AlertType> types(List<AlertEvent> e) => e.map((x) => x.type);

void main() {
  setUp(() => st = DeviceAlertState());

  group('AlertEvaluator.onReport (T-E1)', () {
    test('first report is a silent baseline, even for SOS/final (B-06)', () {
      expect(rpt(rep(mode: 'sos', why: 'final', srv: now)), isEmpty);
    });
    test('same srv again is ignored', () {
      rpt(rep(srv: now));
      expect(rpt(rep(mode: 'sos', srv: now)), isEmpty);
    });
    test('SOS fires once on entry, not on every report', () {
      rpt(rep(srv: now));
      expect(types(rpt(rep(mode: 'sos', srv: now + 1000))), [AlertType.sosAlert]);
      expect(rpt(rep(mode: 'sos', srv: now + 2000)), isEmpty);
      expect(rpt(rep(mode: 'sos', srv: now + 3000)), isEmpty);
    });
    test('Lost update fires on entry with a fix only', () {
      rpt(rep(srv: now));
      expect(types(rpt(rep(mode: 'lost', srv: now + 1000))), [AlertType.lostModeUpdate]);
      expect(rpt(rep(mode: 'lost', srv: now + 2000)), isEmpty);
    });
    test('low battery on crossing 20 %, not while staying below', () {
      rpt(rep(bat: 25, srv: now));
      expect(types(rpt(rep(bat: 19, srv: now + 1))), [AlertType.lowBattery]);
      expect(rpt(rep(bat: 18, srv: now + 2)), isEmpty);
    });
    test('final report / movement / gps lost', () {
      rpt(rep(srv: now));
      expect(types(rpt(rep(why: 'final', srv: now + 1))), [AlertType.batteryCriticalFinal]);
      expect(types(rpt(rep(why: 'movement', srv: now + 2))), [AlertType.movementDetected]);
      expect(types(rpt(rep(fix: 0, srv: now + 3))), [AlertType.gpsFixLost]);
    });
    test('back online after offline', () {
      rpt(rep(srv: now - 5000000), at: now); // stale baseline -> offline
      final e = rpt(rep(srv: now), at: now);
      expect(types(e), [AlertType.tagBackOnline]);
    });
    test('rebuild-safety: state object keeps baseline, nothing re-fires', () {
      rpt(rep(srv: now));
      rpt(rep(mode: 'sos', srv: now + 1000));
      // provider rebuild re-subscribes and re-delivers the latest report
      expect(rpt(rep(mode: 'sos', srv: now + 1000)), isEmpty);
    });
  });

  group('AlertEvaluator.onTick (T-E2)', () {
    test('offline fires by time, once (B-05)', () {
      rpt(rep(mode: 'away', srv: now), at: now);
      expect(tick(now + 899000), isEmpty);
      expect(types(tick(now + 901000)), [AlertType.tagOffline]);
      expect(tick(now + 960000), isEmpty);
    });
    test('uses per-tag offline timeout', () {
      rpt(rep(mode: 'away', srv: now), at: now, timeout: 30);
      // away base window 900 s dominates timeout 30
      expect(tick(now + 100000, timeout: 30), isEmpty);
    });
    test('never offline while BLE connected', () {
      rpt(rep(srv: now), at: now);
      st.setBle(true, now);
      expect(tick(now + 5000000), isEmpty);
    });
    test('grace window after BLE drop', () {
      rpt(rep(srv: now), at: now);
      st.setBle(true, now);
      st.setBle(false, now + 4000000); // drop 4000 s after last report
      expect(tick(now + 4100000), isEmpty); // inside grace
      expect(types(tick(now + 4000000 + 901000)), [AlertType.tagOffline]);
    });
    test('no report -> nothing', () => expect(tick(now), isEmpty));
  });

  group('AlertEvaluator.onBleDrop / setBle (T-E4, B-08)', () {
    List<AlertEvent> drop(int at) => AlertEvaluator.onBleDrop(
        st: st, deviceId: 'd', tagName: 'Keys', nowMs: at);
    test('setBle reports only connected -> disconnected', () {
      expect(st.setBle(false, 1), isFalse);
      expect(st.setBle(true, 2), isFalse);
      expect(st.setBle(false, 3), isTrue);
    });
    test('left-behind alert, then 10 min cooldown', () {
      expect(types(drop(now)), [AlertType.leftBehind]);
      expect(drop(now + 5 * 60000), isEmpty);
      expect(types(drop(now + 11 * 60000)), [AlertType.leftBehind]);
    });
    test('no alert when the tag is already in Lost/SOS mode', () {
      rpt(rep(mode: 'lost', srv: now));
      expect(drop(now + 1000), isEmpty);
    });
  });

  test('alertCategory maps related types to a toggle (B-07) (T-E3)', () {
    expect(alertCategory(AlertType.tagBackOnline), AlertType.tagOffline);
    expect(alertCategory(AlertType.geofenceReEntered), AlertType.geofenceLeft);
    expect(alertCategory(AlertType.batteryCriticalFinal), AlertType.lowBattery);
    expect(alertCategory(AlertType.sosAlert), AlertType.sosAlert);
  });
}
