import 'package:trackpoint/core/time_utils.dart';
import 'package:trackpoint/data/models/tag_report.dart';

class DayBounds {
  final int startMs;
  final int endMs;
  const DayBounds(this.startMs, this.endMs);
}

class HistoryDay {
  HistoryDay._();

  /// Strips the time of day (local time).
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Start and end (inclusive) of a local calendar day, as epoch milliseconds.
  static DayBounds bounds(DateTime day) {
    final start = DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59, 999)
        .millisecondsSinceEpoch;
    return DayBounds(start, end);
  }
}

class HistoryPath {
  HistoryPath._();

  /// Reports that have coordinates, oldest first (for the map and replay).
  static List<TagReport> withCoordinates(Iterable<TagReport> reports) {
    final list = reports.where((r) => r.lat != null && r.lon != null).toList()
      ..sort((a, b) => a.srv.compareTo(b.srv));
    return list;
  }
}

class HistoryCsv {
  HistoryCsv._();

  static const String header =
      'date,time,srv_ms,lat,lon,accuracy_m,battery_pct,battery_v,mode,why,fix,speed_kmh,satellites';

  /// Builds a CSV (oldest first). Times are in the phone's local time zone.
  static String build(List<TagReport> reports) {
    final sorted = [...reports]..sort((a, b) => a.srv.compareTo(b.srv));
    final lines = <String>[header];
    for (final r in sorted) {
      lines.add([
        TimeUtils.formatDateOnly(r.srv),
        TimeUtils.formatTimeOnly(r.srv),
        r.srv,
        r.lat?.toStringAsFixed(6),
        r.lon?.toStringAsFixed(6),
        r.acc,
        r.bat,
        r.bv,
        r.mode,
        r.why,
        r.fix,
        r.spd,
        r.sat,
      ].map(_cell).join(','));
    }
    return '${lines.join('\n')}\n';
  }

  static String _cell(Object? value) {
    if (value == null) return '';
    final text = value.toString();
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  /// `trackpoint_<tag>_<yyyymmdd | recent>.csv`
  static String fileName(String tagName, DateTime? day) {
    final safe = tagName.trim().replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
    final part = day == null
        ? 'recent'
        : '${day.year.toString().padLeft(4, '0')}'
            '${day.month.toString().padLeft(2, '0')}'
            '${day.day.toString().padLeft(2, '0')}';
    return 'trackpoint_${safe.isEmpty ? 'tag' : safe}_$part.csv';
  }
}
