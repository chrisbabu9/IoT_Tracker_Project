import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/data/models/geofence.dart';

/// Tag device settings model.
class TagSettings {
  final int uploadIntervalS; // 5..3600 s
  final int pollIntervalS; // 5..300 s
  final int buzzerMaxS; // 5..600 s
  final int offlineTimeoutS; // 30..86400 s
  final double lowBatteryV; // 3.0..4.0 V step 0.05

  const TagSettings({
    this.uploadIntervalS = AppConfig.defaultUploadIntervalS,
    this.pollIntervalS = AppConfig.defaultPollIntervalS,
    this.buzzerMaxS = AppConfig.defaultBuzzerMaxS,
    this.offlineTimeoutS = AppConfig.defaultOfflineTimeoutS,
    this.lowBatteryV = AppConfig.defaultLowBatteryV,
  });

  factory TagSettings.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return const TagSettings();
    return TagSettings(
      uploadIntervalS: (json['uploadIntervalS'] as num?)?.toInt() ??
          (json['upload_interval_s'] as num?)?.toInt() ??
          AppConfig.defaultUploadIntervalS,
      pollIntervalS: (json['pollIntervalS'] as num?)?.toInt() ??
          (json['poll_interval_s'] as num?)?.toInt() ??
          AppConfig.defaultPollIntervalS,
      buzzerMaxS: (json['buzzerMaxS'] as num?)?.toInt() ??
          (json['buzzer_max_s'] as num?)?.toInt() ??
          AppConfig.defaultBuzzerMaxS,
      offlineTimeoutS: (json['offlineTimeoutS'] as num?)?.toInt() ??
          (json['offline_timeout_s'] as num?)?.toInt() ??
          AppConfig.defaultOfflineTimeoutS,
      lowBatteryV: (json['lowBatteryV'] as num?)?.toDouble() ??
          (json['low_battery_v'] as num?)?.toDouble() ??
          AppConfig.defaultLowBatteryV,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uploadIntervalS': uploadIntervalS,
      'pollIntervalS': pollIntervalS,
      'buzzerMaxS': buzzerMaxS,
      'offlineTimeoutS': offlineTimeoutS,
      'lowBatteryV': lowBatteryV,
    };
  }

  TagSettings copyWith({
    int? uploadIntervalS,
    int? pollIntervalS,
    int? buzzerMaxS,
    int? offlineTimeoutS,
    double? lowBatteryV,
  }) {
    return TagSettings(
      uploadIntervalS: uploadIntervalS ?? this.uploadIntervalS,
      pollIntervalS: pollIntervalS ?? this.pollIntervalS,
      buzzerMaxS: buzzerMaxS ?? this.buzzerMaxS,
      offlineTimeoutS: offlineTimeoutS ?? this.offlineTimeoutS,
      lowBatteryV: lowBatteryV ?? this.lowBatteryV,
    );
  }
}

/// Tag configuration model stored at `/devices/{deviceId}/config`.
class TagConfig {
  final bool? lostMode;
  final TagSettings settings;
  final Geofence? geofence;

  const TagConfig({
    this.lostMode,
    this.settings = const TagSettings(),
    this.geofence,
  });

  factory TagConfig.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return const TagConfig();
    return TagConfig(
      lostMode: json['lostMode'] as bool?,
      settings: TagSettings.fromJson(json['settings'] as Map<dynamic, dynamic>?),
      geofence: json['geofence'] != null
          ? Geofence.fromJson(json['geofence'] as Map<dynamic, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (lostMode != null) 'lostMode': lostMode,
      'settings': settings.toJson(),
      if (geofence != null) 'geofence': geofence!.toJson(),
    };
  }

  TagConfig copyWith({
    bool? lostMode,
    TagSettings? settings,
    Geofence? geofence,
  }) {
    return TagConfig(
      lostMode: lostMode ?? this.lostMode,
      settings: settings ?? this.settings,
      geofence: geofence ?? this.geofence,
    );
  }
}
