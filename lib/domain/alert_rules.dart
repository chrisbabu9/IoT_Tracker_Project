import 'package:trackpoint/core/geo.dart';
import 'package:trackpoint/data/models/geofence.dart';

enum AlertType {
  tagOffline,
  tagBackOnline,
  lowBattery,
  gpsFixLost,
  geofenceLeft,
  geofenceReEntered,
  movementDetected,
  leftBehind,
  sosAlert,
  lostModeUpdate,
  batteryCriticalFinal,
}

/// Settings category an alert type belongs to (so every type is toggleable).
AlertType alertCategory(AlertType t) => switch (t) {
      AlertType.tagBackOnline => AlertType.tagOffline,
      AlertType.geofenceReEntered => AlertType.geofenceLeft,
      AlertType.batteryCriticalFinal => AlertType.lowBattery,
      _ => t,
    };

class AlertEvent {
  final AlertType type;
  final String title;
  final String message;
  final int timestampMs;
  final String deviceId;

  const AlertEvent({
    required this.type,
    required this.title,
    required this.message,
    required this.timestampMs,
    required this.deviceId,
  });
}

class GeofenceEvaluation {
  final bool isInside;
  final double distanceToCenterMeters;
  final double radiusMeters;

  const GeofenceEvaluation({
    required this.isInside,
    required this.distanceToCenterMeters,
    required this.radiusMeters,
  });
}

class AlertRules {
  AlertRules._();

  /// Evaluates whether a location coordinate is inside or outside the geofence.
  static GeofenceEvaluation evaluateGeofence({
    required double lat,
    required double lon,
    required Geofence geofence,
  }) {
    final distance = GeoUtils.haversineDistance(
      lat,
      lon,
      geofence.lat,
      geofence.lon,
    );
    final inside = distance <= geofence.radiusM;

    return GeofenceEvaluation(
      isInside: inside,
      distanceToCenterMeters: distance,
      radiusMeters: geofence.radiusM,
    );
  }
}
