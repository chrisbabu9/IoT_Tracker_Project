import 'package:intl/intl.dart';

/// Pure time formatting utilities using server timestamp (srv).
class TimeUtils {
  TimeUtils._();

  /// Human readable relative time: '12s ago', '5 min ago', '2 h ago', '3 d ago'.
  static String formatTimeAgo(int? timestampMs, {int? nowMs}) {
    if (timestampMs == null || timestampMs <= 0) return 'never';
    final current = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final diffMs = current - timestampMs;
    if (diffMs < 0) return 'just now';

    final seconds = (diffMs / 1000).floor();
    if (seconds < 60) {
      return '${seconds}s ago';
    }
    final minutes = (seconds / 60).floor();
    if (minutes < 60) {
      return '$minutes min ago';
    }
    final hours = (minutes / 60).floor();
    if (hours < 24) {
      return '$hours h ago';
    }
    final days = (hours / 24).floor();
    return '$days d ago';
  }

  /// Formats server timestamp to human date and time string.
  static String formatDateTime(int? timestampMs, {String? timezone}) {
    if (timestampMs == null || timestampMs <= 0) return '—';
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs, isUtc: false);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// Formats server timestamp to date string (yyyy-MM-dd).
  static String formatDateOnly(int? timestampMs) {
    if (timestampMs == null || timestampMs <= 0) return '—';
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Formats server timestamp to time string (HH:mm:ss).
  static String formatTimeOnly(int? timestampMs) {
    if (timestampMs == null || timestampMs <= 0) return '—';
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return DateFormat('HH:mm:ss').format(date);
  }

  /// Formats duration seconds into 'Xh Ym' or 'Xs'.
  static String formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }
}
