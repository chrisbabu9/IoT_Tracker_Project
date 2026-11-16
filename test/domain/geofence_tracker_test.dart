import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/data/models/geofence.dart';
import 'package:trackpoint/domain/alert_rules.dart';
import 'package:trackpoint/domain/geofence_tracker.dart';
import '../helpers.dart';

// 1 deg latitude ~ 111195 m  => 0.0005 deg ~ 56 m, 0.002 deg ~ 222 m
const fence = Geofence(enabled: true, lat: 0, lon: 0, radiusM: 100);
const d = 'dev';

void main() {
  group('GeofenceTracker.update (T-D8)', () {
    late GeofenceTracker t;
    setUp(() => t = GeofenceTracker());

    GeofenceTransition? u(double lat, int srv, {Geofence? f = fence, int fix = 1}) =>
        t.update(deviceId: d, fence: f, report: rep(lat: lat, lon: 0, srv: srv, fix: fix));

    test('first report is a silent baseline', () => expect(u(0.0005, 1), isNull));
    test('inside -> outside = left, then re-entered', () {
      u(0.0005, 1);
      expect(u(0.002, 2), GeofenceTransition.left);
      expect(u(0.0005, 3), GeofenceTransition.reEntered);
    });
    test('same srv is ignored', () {
      u(0.0005, 1);
      expect(u(0.002, 2), GeofenceTransition.left);
      expect(u(0.0005, 2), isNull);
    });
    test('hysteresis: 110 m (< 100+15) does not leave', () {
      u(0.0005, 1);
      expect(u(0.00099, 2), isNull);
      expect(u(0.0011, 3), GeofenceTransition.left); // ~122 m
    });
    test('reports without fresh fix are ignored', () {
      u(0.0005, 1);
      expect(u(0.002, 2, fix: 0), isNull);
    });
    test('disabled fence resets baseline', () {
      u(0.0005, 1);
      expect(u(0.002, 2, f: fence.copyWith(enabled: false)), isNull);
      expect(u(0.002, 3), isNull); // new baseline (outside), no alert
    });
    test('editing the fence resets state', () {
      u(0.0005, 1);
      expect(u(0.002, 2, f: fence.copyWith(radiusM: 500)), isNull);
    });
    test('null fence / null report -> null', () {
      expect(t.update(deviceId: d, fence: null, report: null), isNull);
      expect(t.update(deviceId: d, fence: fence, report: null), isNull);
    });
  });
  group('formatDistance (T-D9)', () {
    test('metres', () => expect(formatDistance(320.4), '320 m'));
    test('km', () => expect(formatDistance(1400), '1.4 km'));
  });
  group('GeofenceStatus.compute / AlertRules.evaluateGeofence (T-D10)', () {
    test('null fence -> null', () => expect(GeofenceStatus.compute(null, rep()), isNull));
    test('no coords -> no evaluation', () {
      expect(GeofenceStatus.compute(fence, rep())!.evaluation, isNull);
    });
    test('inside / outside', () {
      final inside = GeofenceStatus.compute(fence, rep(lat: 0.0005, lon: 0))!.evaluation!;
      final out = GeofenceStatus.compute(fence, rep(lat: 0.002, lon: 0))!.evaluation!;
      expect(inside.isInside, isTrue);
      expect(out.isInside, isFalse);
      expect(out.distanceToCenterMeters, closeTo(222, 2));
    });
    test('evaluateGeofence exact radius counts as inside', () {
      final e = AlertRules.evaluateGeofence(lat: 0, lon: 0, geofence: fence);
      expect(e.isInside, isTrue);
      expect(e.radiusMeters, 100);
    });
  });
}
