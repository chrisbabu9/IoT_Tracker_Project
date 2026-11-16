import 'package:geolocator/geolocator.dart';

/// Single place for phone-location access (permission + current fix).
class PhoneLocation {
  PhoneLocation._();

  /// Returns the phone position or null when unavailable. Only asks the user
  /// for permission when [requestPermission] is true (e.g. the map screen).
  static Future<Position?> current({bool requestPermission = false}) async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied && requestPermission) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null; // services off / timeout: callers treat as "unknown"
    }
  }
}
