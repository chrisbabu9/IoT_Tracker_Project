import 'package:trackpoint/core/config.dart';

enum DistanceZoneType {
  rightHere, // > -60 dBm
  veryNear, // -60 .. -72 dBm
  near, // -72 .. -82 dBm
  far, // -82 .. -92 dBm
  edgeOfRange, // <= -92 dBm
}

enum SignalTrend {
  warmer, // Signal getting stronger (closer)
  colder, // Signal getting weaker (farther)
  steady, // No significant change
}

class DistanceZoneResult {
  final DistanceZoneType zone;
  final String label;
  final double smoothedRssi;
  final SignalTrend trend;

  const DistanceZoneResult({
    required this.zone,
    required this.label,
    required this.smoothedRssi,
    required this.trend,
  });
}

/// Distance zone calculator with rolling median of last 7 samples and exponential smoothing.
class DistanceZoneCalculator {
  final List<int> _window = [];
  double? _lastSmoothedRssi;
  double? _prevSmoothedRssi;

  /// Window size for median filter
  final int windowSize;

  /// Exponential smoothing factor alpha (0.0 < alpha <= 1.0)
  final double alpha;

  DistanceZoneCalculator({
    this.windowSize = 7,
    this.alpha = 0.35,
  });

  /// Feeds a new raw RSSI sample and returns smoothed zone and trend.
  DistanceZoneResult addSample(int rawRssi) {
    _window.add(rawRssi);
    if (_window.length > windowSize) {
      _window.removeAt(0);
    }

    // 1. Median filter of window samples
    final medianRssi = _calculateMedian(_window);

    // 2. Exponential moving average (EMA)
    _prevSmoothedRssi = _lastSmoothedRssi;
    if (_lastSmoothedRssi == null) {
      _lastSmoothedRssi = medianRssi.toDouble();
    } else {
      _lastSmoothedRssi = (alpha * medianRssi) + ((1.0 - alpha) * _lastSmoothedRssi!);
    }

    final smoothed = _lastSmoothedRssi!;

    // 3. Determine trend
    SignalTrend trend = SignalTrend.steady;
    if (_prevSmoothedRssi != null) {
      final diff = smoothed - _prevSmoothedRssi!;
      if (diff > 1.2) {
        trend = SignalTrend.warmer; // RSSI higher = closer
      } else if (diff < -1.2) {
        trend = SignalTrend.colder; // RSSI lower = farther
      }
    }

    // 4. Determine zone
    final zone = getZoneFromRssi(smoothed);
    final label = getZoneLabel(zone);

    return DistanceZoneResult(
      zone: zone,
      label: label,
      smoothedRssi: smoothed,
      trend: trend,
    );
  }

  static DistanceZoneType getZoneFromRssi(double rssi) {
    if (rssi > AppConfig.rssiRightHereThreshold) {
      return DistanceZoneType.rightHere;
    } else if (rssi > AppConfig.rssiVeryNearThreshold) {
      return DistanceZoneType.veryNear;
    } else if (rssi > AppConfig.rssiNearThreshold) {
      return DistanceZoneType.near;
    } else if (rssi > AppConfig.rssiFarThreshold) {
      return DistanceZoneType.far;
    } else {
      return DistanceZoneType.edgeOfRange;
    }
  }

  static String getZoneLabel(DistanceZoneType zone) {
    return switch (zone) {
      DistanceZoneType.rightHere => 'Right here',
      DistanceZoneType.veryNear => 'Very near',
      DistanceZoneType.near => 'Near',
      DistanceZoneType.far => 'Far',
      DistanceZoneType.edgeOfRange => 'Edge of range',
    };
  }

  static double _calculateMedian(List<int> list) {
    if (list.isEmpty) return -100.0;
    final sorted = List<int>.from(list)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) {
      return sorted[middle].toDouble();
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2.0;
    }
  }

  void reset() {
    _window.clear();
    _lastSmoothedRssi = null;
    _prevSmoothedRssi = null;
  }
}
