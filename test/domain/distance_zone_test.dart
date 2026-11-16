import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/domain/distance_zone.dart';

void main() {
  group('DistanceZoneCalculator.getZoneFromRssi (T-D3)', () {
    final cases = {
      -50.0: DistanceZoneType.rightHere,
      -60.0: DistanceZoneType.veryNear, // boundary is exclusive
      -71.9: DistanceZoneType.veryNear,
      -72.0: DistanceZoneType.near,
      -82.0: DistanceZoneType.far,
      -92.0: DistanceZoneType.edgeOfRange,
      -100.0: DistanceZoneType.edgeOfRange,
    };
    cases.forEach((rssi, zone) => test('$rssi -> $zone', () {
          expect(DistanceZoneCalculator.getZoneFromRssi(rssi), zone);
        }));
  });
  test('getZoneLabel covers all zones (T-D4)', () {
    for (final z in DistanceZoneType.values) {
      expect(DistanceZoneCalculator.getZoneLabel(z), isNotEmpty);
    }
    expect(DistanceZoneCalculator.getZoneLabel(DistanceZoneType.rightHere), 'Right here');
  });
  group('DistanceZoneCalculator.addSample (T-D5)', () {
    test('first sample: smoothed == raw, steady', () {
      final r = DistanceZoneCalculator().addSample(-70);
      expect(r.smoothedRssi, -70.0);
      expect(r.trend, SignalTrend.steady);
    });
    test('median of two then EMA', () {
      final c = DistanceZoneCalculator();
      c.addSample(-70);
      final r = c.addSample(-80); // median -75, ema .35*-75+.65*-70
      expect(r.smoothedRssi, closeTo(-71.75, 0.001));
    });
    test('constant signal stays steady', () {
      final c = DistanceZoneCalculator();
      late DistanceZoneResult r;
      for (var i = 0; i < 10; i++) {
        r = c.addSample(-65);
      }
      expect(r.trend, SignalTrend.steady);
      expect(r.zone, DistanceZoneType.veryNear);
    });
    test('median filter ignores a single spike', () {
      final c = DistanceZoneCalculator();
      for (var i = 0; i < 7; i++) {
        c.addSample(-80);
      }
      final r = c.addSample(-30);
      expect(r.smoothedRssi, closeTo(-80, 0.001));
    });
    test('getting closer -> warmer', () {
      final c = DistanceZoneCalculator();
      for (var i = 0; i < 7; i++) {
        c.addSample(-90);
      }
      late DistanceZoneResult r;
      for (var i = 0; i < 4; i++) {
        r = c.addSample(-40);
      }
      expect(r.trend, SignalTrend.warmer);
    });
    test('getting farther -> colder', () {
      final c = DistanceZoneCalculator();
      for (var i = 0; i < 7; i++) {
        c.addSample(-50);
      }
      late DistanceZoneResult r;
      for (var i = 0; i < 4; i++) {
        r = c.addSample(-95);
      }
      expect(r.trend, SignalTrend.colder);
    });
    test('reset clears history', () {
      final c = DistanceZoneCalculator();
      for (var i = 0; i < 5; i++) {
        c.addSample(-50);
      }
      c.reset();
      expect(c.addSample(-90).smoothedRssi, -90.0);
    });
  });
}
