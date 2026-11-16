/// Pure unit formatting (metric / imperial) for distances and speeds.
class Units {
  Units._();

  static const double metersPerMile = 1609.344;
  static const double feetPerMeter = 3.28084;
  static const double mphPerKmh = 0.621371;

  /// "320 m" / "1.4 km"  or  "980 ft" / "0.6 mi".
  static String distance(double meters, {bool imperial = false}) {
    if (!imperial) {
      return meters >= 1000
          ? '${(meters / 1000).toStringAsFixed(1)} km'
          : '${meters.round()} m';
    }
    final miles = meters / metersPerMile;
    return miles >= 0.1
        ? '${miles.toStringAsFixed(1)} mi'
        : '${(meters * feetPerMeter).round()} ft';
  }

  /// "36.0 km/h" or "22.4 mph".
  static String speed(double kmh, {bool imperial = false}) => imperial
      ? '${(kmh * mphPerKmh).toStringAsFixed(1)} mph'
      : '${kmh.toStringAsFixed(1)} km/h';
}
