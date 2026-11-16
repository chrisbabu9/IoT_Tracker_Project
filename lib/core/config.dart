import 'dart:io';
import 'package:flutter/foundation.dart';

/// Global application configuration and environment constants.
class AppConfig {
  AppConfig._();

  /// Product information
  static const String appName = 'TrackPoint';
  static const String appVersion = '1.0.0';
  static const String userAgentPackageName = 'com.trackpoint.app';

  /// Firebase Emulator configuration
  /// Toggle this to switch between Firebase Emulator and production Firebase.
  static const bool useEmulator =
      bool.fromEnvironment('USE_EMULATOR', defaultValue: false);

  /// Emulator host - Android emulator uses 10.0.2.2 to reach host machine,
  /// iOS simulator or desktop uses 127.0.0.1.
  static String get emulatorHost {
    if (!kIsWeb && Platform.isAndroid) {
      return '10.0.2.2';
    }
    return '127.0.0.1';
  }

  static const int authEmulatorPort = 9099;
  static const int rtdbEmulatorPort = 9000;

  /// OpenStreetMap Tile URL template (can be swapped for commercial provider)
  static const String osmTileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Esri World Imagery (Satellite) URL template
  static const String esriSatelliteTileUrlTemplate =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  /// OpenStreetMap and Esri Tile Attributions
  static const String osmAttribution = '© OpenStreetMap contributors';
  static const String esriAttribution =
      'Tiles © Esri — Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community';

  /// BLE Service and Characteristic Base UUID
  static const String bleServiceUuid = '7a1c0001-6b1e-4f5a-9c1d-5b7d0e3a9f10';
  static const String bleDeviceInfoUuid =
      '7a1c0002-6b1e-4f5a-9c1d-5b7d0e3a9f10';
  static const String bleBuzzerUuid = '7a1c0003-6b1e-4f5a-9c1d-5b7d0e3a9f10';
  static const String bleStatusUuid = '7a1c0004-6b1e-4f5a-9c1d-5b7d0e3a9f10';
  static const String bleCommandUuid = '7a1c0005-6b1e-4f5a-9c1d-5b7d0e3a9f10';

  /// RSSI Distance Zone Thresholds (dBm)
  static const int rssiRightHereThreshold = -60;
  static const int rssiVeryNearThreshold = -72;
  static const int rssiNearThreshold = -82;
  static const int rssiFarThreshold = -92;

  /// Command expiry duration
  static const Duration commandTimeout = Duration(minutes: 2);

  /// Default tag device settings
  static const int defaultUploadIntervalS = 300;
  static const int defaultPollIntervalS = 60;
  static const int defaultBuzzerMaxS = 30;
  static const int defaultOfflineTimeoutS = 900;
  static const double defaultLowBatteryV = 3.5;

  /// Simulation namespace: simulated tags never collide with real hardware.
  static const String simBlePrefix = 'SIM:';
  static const String simDevicePrefix = 'sim_';
  static bool isSimBleId(String id) => id.startsWith(simBlePrefix);
  static const String prefSimulationMode = 'trackpoint_simulation_mode';
  static const String prefUnits = 'trackpoint_units';

  /// Default geofence radius
  static const double defaultGeofenceRadiusM = 500.0;
  static const double minGeofenceRadiusM = 50.0;
  static const double maxGeofenceRadiusM = 5000.0;
  static const double geofenceStepM = 50.0;
}
