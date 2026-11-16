import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/domain/lost_policy.dart';

void main() {
  group('LostPolicy.getReportingIntervalSeconds (T-D1)', () {
    const cases = {100: 60, 61: 60, 60: 120, 30: 120, 29: 180, 15: 180, 14: 300, 5: 300, 4: 0, 0: 0};
    cases.forEach((bat, s) => test('bat $bat -> ${s}s', () {
          expect(LostPolicy.getReportingIntervalSeconds(bat), s);
        }));
  });
  group('LostPolicy.getMatchingRowIndex (T-D2)', () {
    const cases = {100: 0, 61: 0, 60: 1, 30: 1, 29: 2, 15: 2, 14: 3, 5: 3, 4: 4, 0: 4};
    cases.forEach((bat, i) => test('bat $bat -> row $i', () {
          expect(LostPolicy.getMatchingRowIndex(bat), i);
        }));
    test('row table agrees with interval function', () {
      for (var b = 0; b <= 100; b++) {
        final row = LostPolicy.rows[LostPolicy.getMatchingRowIndex(b)];
        expect(row.intervalSeconds, LostPolicy.getReportingIntervalSeconds(b), reason: 'bat=$b');
        expect(b >= row.minBat && b <= row.maxBat, isTrue, reason: 'bat=$b');
      }
    });
  });
}
