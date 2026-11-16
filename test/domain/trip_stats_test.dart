import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/domain/trip_stats.dart';

TripPoint p(double lat, int ms) => TripPoint(lat: lat, lon: 0, timestampMs: ms);

void main() {
  group('TripStats.calculate (T-D11)', () {
    test('empty', () {
      final s = TripStats.calculate([]);
      expect(s.totalFixes, 0);
      expect(s.distanceMeters, 0);
      expect(s.firstFixTimestampMs, isNull);
    });
    test('100 m in 10 s = 36 km/h', () {
      final s = TripStats.calculate([p(0, 0), p(0.0009, 10000)]);
      expect(s.totalFixes, 2);
      expect(s.distanceMeters, closeTo(100, 1));
      expect(s.movingTimeSeconds, 10);
      expect(s.avgMovingSpeedKmh, closeTo(36, 0.5));
      expect(s.topSpeedKmh, closeTo(36, 0.5));
      expect(s.distanceKm, closeTo(0.1, 0.001));
      expect(s.firstFixTimestampMs, 0);
      expect(s.lastFixTimestampMs, 10000);
    });
    test('GPS jitter (<15 m) ignored', () {
      final s = TripStats.calculate([p(0, 0), p(0.00005, 10000)]);
      expect(s.distanceMeters, 0);
      expect(s.movingTimeSeconds, 0);
      expect(s.avgMovingSpeedKmh, 0);
    });
    test('teleport (>250 km/h) ignored', () {
      final s = TripStats.calculate([p(0, 0), p(0.1, 10000)]);
      expect(s.distanceMeters, 0);
      expect(s.topSpeedKmh, 0);
    });
    test('identical timestamps do not divide by zero', () {
      final s = TripStats.calculate([p(0, 5), p(0.001, 5)]);
      expect(s.distanceMeters, 0);
    });
  });
}
