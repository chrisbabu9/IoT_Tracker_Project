import 'package:trackpoint/core/config.dart';

/// Geofence configuration model stored at `/devices/{deviceId}/config/geofence`.
class Geofence {
  final bool enabled;
  final double lat;
  final double lon;
  final double radiusM;

  const Geofence({
    required this.enabled,
    required this.lat,
    required this.lon,
    this.radiusM = AppConfig.defaultGeofenceRadiusM,
  });

  factory Geofence.fromJson(Map<dynamic, dynamic> json) {
    return Geofence(
      enabled: json['enabled'] == true,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      radiusM: (json['radiusM'] as num?)?.toDouble() ?? AppConfig.defaultGeofenceRadiusM,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'lat': lat,
      'lon': lon,
      'radiusM': radiusM,
    };
  }

  Geofence copyWith({
    bool? enabled,
    double? lat,
    double? lon,
    double? radiusM,
  }) {
    return Geofence(
      enabled: enabled ?? this.enabled,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      radiusM: radiusM ?? this.radiusM,
    );
  }
}
