import 'dart:math' as math;

/// Pure geographic calculations and validations.
class GeoUtils {
  GeoUtils._();

  /// Earth radius in meters
  static const double earthRadiusMeters = 6371000.0;

  /// Pure Haversine formula calculation returning distance in meters.
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(lat1Rad) *
            math.cos(lat2Rad);

    final c = 2 * math.asin(math.sqrt(a));
    return earthRadiusMeters * c;
  }

  /// Validates whether latitude and longitude are within standard coordinates bounds.
  static bool isValidCoordinate(double? lat, double? lon) {
    if (lat == null || lon == null) return false;
    return lat >= -90.0 && lat <= 90.0 && lon >= -180.0 && lon <= 180.0;
  }

  /// Converts degrees to radians.
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Calculates speed in km/h given distance in meters and time delta in seconds.
  static double calculateSpeedKmh(double distanceMeters, double timeDeltaSeconds) {
    if (timeDeltaSeconds <= 0) return 0.0;
    return (distanceMeters / timeDeltaSeconds) * 3.6;
  }
}
