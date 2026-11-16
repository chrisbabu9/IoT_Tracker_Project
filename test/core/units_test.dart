import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/core/units.dart';

void main() {
  group('Units.distance (T-C8)', () {
    test('metric', () {
      expect(Units.distance(320.4), '320 m');
      expect(Units.distance(1400), '1.4 km');
      expect(Units.distance(999.4), '999 m');
    });
    test('imperial: feet under 0.1 mi, miles above', () {
      expect(Units.distance(100, imperial: true), '328 ft');
      expect(Units.distance(1609.344, imperial: true), '1.0 mi');
      expect(Units.distance(160.9, imperial: true), '528 ft'); // just under 0.1 mi
    });
  });
  group('Units.speed (T-C9)', () {
    test('metric', () => expect(Units.speed(36), '36.0 km/h'));
    test('imperial', () => expect(Units.speed(100, imperial: true), '62.1 mph'));
  });
}
