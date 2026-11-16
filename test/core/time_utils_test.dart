import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/core/time_utils.dart';

void main() {
  const now = 1000000000;
  group('TimeUtils.formatTimeAgo (T-C4)', () {
    test('null/0 -> never', () {
      expect(TimeUtils.formatTimeAgo(null), 'never');
      expect(TimeUtils.formatTimeAgo(0), 'never');
    });
    test('seconds', () => expect(TimeUtils.formatTimeAgo(now - 12000, nowMs: now), '12s ago'));
    test('minutes', () => expect(TimeUtils.formatTimeAgo(now - 5 * 60000, nowMs: now), '5 min ago'));
    test('hours', () => expect(TimeUtils.formatTimeAgo(now - 2 * 3600000, nowMs: now), '2 h ago'));
    test('days', () => expect(TimeUtils.formatTimeAgo(now - 3 * 86400000, nowMs: now), '3 d ago'));
    test('future -> just now', () => expect(TimeUtils.formatTimeAgo(now + 5000, nowMs: now), 'just now'));
    test('59s/60s boundary', () {
      expect(TimeUtils.formatTimeAgo(now - 59999, nowMs: now), '59s ago');
      expect(TimeUtils.formatTimeAgo(now - 60000, nowMs: now), '1 min ago');
    });
  });
  group('TimeUtils date formats (T-C5)', () {
    final ms = DateTime(2026, 10, 24, 12, 35, 19).millisecondsSinceEpoch;
    test('dateTime', () => expect(TimeUtils.formatDateTime(ms), '2026-10-24 12:35:19'));
    test('dateOnly', () => expect(TimeUtils.formatDateOnly(ms), '2026-10-24'));
    test('timeOnly', () => expect(TimeUtils.formatTimeOnly(ms), '12:35:19'));
    test('null -> dash', () {
      expect(TimeUtils.formatDateTime(null), '—');
      expect(TimeUtils.formatDateOnly(0), '—');
      expect(TimeUtils.formatTimeOnly(-1), '—');
    });
  });
  group('TimeUtils.formatDuration (T-C6)', () {
    test('seconds', () => expect(TimeUtils.formatDuration(45), '45s'));
    test('minutes', () => expect(TimeUtils.formatDuration(600), '10m'));
    test('hours+min', () => expect(TimeUtils.formatDuration(3720), '1h 2m'));
  });
}
