import 'package:trackpoint/core/geo.dart';

class TripPoint {
  final double lat;
  final double lon;
  final int timestampMs;

  const TripPoint({
    required this.lat,
    required this.lon,
    required this.timestampMs,
  });
}

class TripStats {
  final int totalFixes;
  final double distanceMeters;
  final int movingTimeSeconds;
  final double avgMovingSpeedKmh;
  final double topSpeedKmh;
  final int? firstFixTimestampMs;
  final int? lastFixTimestampMs;

  const TripStats({
    required this.totalFixes,
    required this.distanceMeters,
    required this.movingTimeSeconds,
    required this.avgMovingSpeedKmh,
    required this.topSpeedKmh,
    this.firstFixTimestampMs,
    this.lastFixTimestampMs,
  });

  double get distanceKm => distanceMeters / 1000.0;

  /// Pure function calculating trip statistics across a chronologically sorted sequence of fixes.
  /// Rule: Ignore a step shorter than 15 m or implying more than 250 km/h.
  static TripStats calculate(List<TripPoint> points) {
    if (points.isEmpty) {
      return const TripStats(
        totalFixes: 0,
        distanceMeters: 0,
        movingTimeSeconds: 0,
        avgMovingSpeedKmh: 0,
        topSpeedKmh: 0,
      );
    }

    double totalDist = 0.0;
    int totalMovingSec = 0;
    double maxSpeed = 0.0;

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];

      final dist = GeoUtils.haversineDistance(
        prev.lat,
        prev.lon,
        curr.lat,
        curr.lon,
      );
      final sec = ((curr.timestampMs - prev.timestampMs) / 1000.0);

      if (dist >= 15.0 && sec > 0) {
        final speedKmh = (dist / sec) * 3.6;
        if (speedKmh < 250.0) {
          totalDist += dist;
          totalMovingSec += sec.round();
          if (speedKmh > maxSpeed) {
            maxSpeed = speedKmh;
          }
        }
      }
    }

    final avgSpeed = totalMovingSec > 0
        ? (totalDist / totalMovingSec) * 3.6
        : 0.0;

    return TripStats(
      totalFixes: points.length,
      distanceMeters: totalDist,
      movingTimeSeconds: totalMovingSec,
      avgMovingSpeedKmh: avgSpeed,
      topSpeedKmh: maxSpeed,
      firstFixTimestampMs: points.first.timestampMs,
      lastFixTimestampMs: points.last.timestampMs,
    );
  }
}
