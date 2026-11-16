import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/core/geo.dart';

void main() {
  group('GeoUtils.haversineDistance (T-C1)', () {
    test('same point is 0', () {
      expect(GeoUtils.haversineDistance(10, 20, 10, 20), 0);
    });
    test('1 degree latitude ~ 111.2 km', () {
      expect(GeoUtils.haversineDistance(0, 0, 1, 0), closeTo(111195, 200));
    });
    test('is symmetric', () {
      final a = GeoUtils.haversineDistance(10.5, 76.2, 11.0, 76.9);
      final b = GeoUtils.haversineDistance(11.0, 76.9, 10.5, 76.2);
      expect(a, closeTo(b, 1e-6));
    });
  });
  group('GeoUtils.isValidCoordinate (T-C2)', () {
    test('accepts bounds', () => expect(GeoUtils.isValidCoordinate(90, 180), isTrue));
    test('rejects out of range', () {
      expect(GeoUtils.isValidCoordinate(90.1, 0), isFalse);
      expect(GeoUtils.isValidCoordinate(0, -180.1), isFalse);
    });
    test('rejects null', () => expect(GeoUtils.isValidCoordinate(null, 1), isFalse));
  });
  group('GeoUtils.calculateSpeedKmh (T-C3)', () {
    test('1000 m in 100 s = 36 km/h', () => expect(GeoUtils.calculateSpeedKmh(1000, 100), 36));
    test('zero/negative delta -> 0', () {
      expect(GeoUtils.calculateSpeedKmh(100, 0), 0);
      expect(GeoUtils.calculateSpeedKmh(100, -5), 0);
    });
  });
}
