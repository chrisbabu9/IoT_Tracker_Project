/// Representation of a paired device from user's index `/users/{uid}/devices/{deviceId}`
/// and device meta `/devices/{deviceId}/meta`.
class DeviceSummary {
  final String deviceId;
  final String name;
  final int pairedAt;
  final String bleId;
  final String? fw;
  final String? owner;
  final int? createdAt;
  final LastSeenNear? lastSeenNear;

  const DeviceSummary({
    required this.deviceId,
    required this.name,
    required this.pairedAt,
    required this.bleId,
    this.fw,
    this.owner,
    this.createdAt,
    this.lastSeenNear,
  });

  factory DeviceSummary.fromJson(
    Map<dynamic, dynamic> userDeviceJson, {
    required String deviceId,
    Map<dynamic, dynamic>? metaJson,
    Map<dynamic, dynamic>? lastSeenNearJson,
  }) {
    return DeviceSummary(
      deviceId: deviceId,
      name: userDeviceJson['name']?.toString() ?? 'TrackPoint Tag',
      pairedAt: (userDeviceJson['pairedAt'] as num?)?.toInt() ?? 0,
      bleId: userDeviceJson['bleId']?.toString() ?? '',
      fw: metaJson?['fw']?.toString(),
      owner: metaJson?['owner']?.toString(),
      createdAt: (metaJson?['createdAt'] as num?)?.toInt(),
      lastSeenNear: lastSeenNearJson != null
          ? LastSeenNear.fromJson(lastSeenNearJson)
          : null,
    );
  }

  Map<String, dynamic> toUserDeviceJson() {
    return {
      'name': name,
      'pairedAt': pairedAt,
      'bleId': bleId,
    };
  }

  DeviceSummary copyWith({
    String? deviceId,
    String? name,
    int? pairedAt,
    String? bleId,
    String? fw,
    String? owner,
    int? createdAt,
    LastSeenNear? lastSeenNear,
  }) {
    return DeviceSummary(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      pairedAt: pairedAt ?? this.pairedAt,
      bleId: bleId ?? this.bleId,
      fw: fw ?? this.fw,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      lastSeenNear: lastSeenNear ?? this.lastSeenNear,
    );
  }
}

/// Fallback position recorded by phone when BLE disconnects: `/devices/{deviceId}/lastSeenNear`.
class LastSeenNear {
  final double lat;
  final double lon;
  final int ts; // epoch ms

  const LastSeenNear({
    required this.lat,
    required this.lon,
    required this.ts,
  });

  factory LastSeenNear.fromJson(Map<dynamic, dynamic> json) {
    return LastSeenNear(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      ts: (json['ts'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
      'ts': ts,
    };
  }
}
