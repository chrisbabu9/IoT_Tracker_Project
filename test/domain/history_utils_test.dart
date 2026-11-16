import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/domain/history_utils.dart';
import '../helpers.dart';

void main() {
  group('HistoryDay (T-D12)', () {
    test('dateOnly strips time', () {
      expect(HistoryDay.dateOnly(DateTime(2026, 10, 24, 15, 30)), DateTime(2026, 10, 24));
    });
    test('bounds are start-of-day .. 23:59:59.999 local', () {
      final b = HistoryDay.bounds(DateTime(2026, 10, 24, 15));
      expect(b.startMs, DateTime(2026, 10, 24).millisecondsSinceEpoch);
      expect(b.endMs, DateTime(2026, 10, 24, 23, 59, 59, 999).millisecondsSinceEpoch);
      expect(b.endMs > b.startMs, isTrue);
    });
  });
  group('HistoryPath.withCoordinates (T-D13)', () {
    test('filters coordinate-less reports and sorts oldest first', () {
      final out = HistoryPath.withCoordinates([
        rep(lat: 1, lon: 1, srv: 30),
        rep(srv: 20),
        rep(lat: 2, lon: 2, srv: 10),
      ]);
      expect(out.map((r) => r.srv), [10, 30]);
    });
  });
  group('HistoryCsv (T-D14)', () {
    test('header + rows oldest first + trailing newline', () {
      final csv = HistoryCsv.build([
        rep(lat: 1.5, lon: 2.5, srv: 2000),
        rep(lat: 1.0, lon: 2.0, srv: 1000),
      ]);
      final lines = csv.trimRight().split('\n');
      expect(lines.first, HistoryCsv.header);
      expect(lines.length, 3);
      expect(lines[1].split(',')[2], '1000');
      expect(lines[1], contains('1.000000,2.000000'));
      expect(csv.endsWith('\n'), isTrue);
    });
    test('cells with comma/quote are quoted & escaped', () {
      final csv = HistoryCsv.build([rep(mode: 'a,b', why: 'say "hi"', srv: 5)]);
      expect(csv, contains('"a,b"'));
      expect(csv, contains('"say ""hi"""'));
    });
    test('null lat/lon -> empty cells', () {
      final line = HistoryCsv.build([rep(srv: 5)]).split('\n')[1];
      expect(line.split(',')[3], '');
    });
    test('fileName sanitises and handles empty names', () {
      expect(HistoryCsv.fileName('My Keys!', null), 'trackpoint_My_Keys__recent.csv');
      expect(HistoryCsv.fileName('  ', DateTime(2026, 1, 5)), 'trackpoint_tag_20260105.csv');
    });
  });
}
