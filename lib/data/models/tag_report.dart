/// Report model written by the tag to `/devices/{deviceId}/history/{pushId}`.
class TagReport {
  final String? pushId;
  final int fix; // 1 = fresh GPS fix, 0 = no fresh fix
  final double? lat;
  final double? lon;
  final int? acc; // Estimated accuracy in meters (HDOP * 5)
  final double? spd; // km/h
  final double? crs; // Course degrees (0..360)
  final double? alt; // Altitude in meters
  final int? sat; // Satellites count
  final int age; // Seconds since position was real (0 if fresh fix)
  final String? gts; // GPS UTC time (e.g. 2026-10-24T12:35:19Z)
  final double bv; // Battery voltage in Volts (e.g. 3.91)
  final int bat; // Battery percent 0..100
  final int csq; // Cellular signal quality: 0..31, 99 = unknown
  final String mode; // 'unpaired', 'near', 'away', 'lost', 'sos'
  final String why; // 'periodic', 'away', 'lost_on', 'sos', 'movement', 'final'
  final int srv; // Server timestamp in milliseconds epoch

  const TagReport({
    this.pushId,
    required this.fix,
    this.lat,
    this.lon,
    this.acc,
    this.spd,
    this.crs,
    this.alt,
    this.sat,
    this.age = 0,
    this.gts,
    required this.bv,
    required this.bat,
    required this.csq,
    required this.mode,
    required this.why,
    required this.srv,
  });

  bool get isFreshFix => fix == 1;
  bool get hasCoordinates => lat != null && lon != null;

  /// Cellular signal in dBm: dBm = -113 + 2*csq (for csq 0..31). 99 = unknown.
  int? get signalDbm {
    if (csq >= 0 && csq <= 31) {
      return -113 + 2 * csq;
    }
    return null;
  }

  factory TagReport.fromJson(Map<dynamic, dynamic> json, {String? pushId}) {
    return TagReport(
      pushId: pushId ?? json['pushId']?.toString(),
      fix: (json['fix'] as num?)?.toInt() ?? 0,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      acc: (json['acc'] as num?)?.toInt(),
      spd: (json['spd'] as num?)?.toDouble(),
      crs: (json['crs'] as num?)?.toDouble(),
      alt: (json['alt'] as num?)?.toDouble(),
      sat: (json['sat'] as num?)?.toInt(),
      age: (json['age'] as num?)?.toInt() ?? 0,
      gts: json['gts']?.toString(),
      bv: (json['bv'] as num?)?.toDouble() ?? 0.0,
      bat: (json['bat'] as num?)?.toInt() ?? 0,
      csq: (json['csq'] as num?)?.toInt() ?? 99,
      mode: json['mode']?.toString() ?? 'unknown',
      why: json['why']?.toString() ?? 'unknown',
      srv: (json['srv'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fix': fix,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (acc != null) 'acc': acc,
      if (spd != null) 'spd': spd,
      if (crs != null) 'crs': crs,
      if (alt != null) 'alt': alt,
      if (sat != null) 'sat': sat,
      'age': age,
      if (gts != null) 'gts': gts,
      'bv': bv,
      'bat': bat,
      'csq': csq,
      'mode': mode,
      'why': why,
      'srv': srv,
    };
  }

  TagReport copyWith({
    String? pushId,
    int? fix,
    double? lat,
    double? lon,
    int? acc,
    double? spd,
    double? crs,
    double? alt,
    int? sat,
    int? age,
    String? gts,
    double? bv,
    int? bat,
    int? csq,
    String? mode,
    String? why,
    int? srv,
  }) {
    return TagReport(
      pushId: pushId ?? this.pushId,
      fix: fix ?? this.fix,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      acc: acc ?? this.acc,
      spd: spd ?? this.spd,
      crs: crs ?? this.crs,
      alt: alt ?? this.alt,
      sat: sat ?? this.sat,
      age: age ?? this.age,
      gts: gts ?? this.gts,
      bv: bv ?? this.bv,
      bat: bat ?? this.bat,
      csq: csq ?? this.csq,
      mode: mode ?? this.mode,
      why: why ?? this.why,
      srv: srv ?? this.srv,
    );
  }
}
