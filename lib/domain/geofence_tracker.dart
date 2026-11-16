import 'package:trackpoint/core/units.dart';
import 'package:trackpoint/data/models/geofence.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/domain/alert_rules.dart';

enum GeofenceTransition { left, reEntered }

/// Human readable distance: "320 m" / "1.4 km" (or ft / mi when [imperial]).
String formatDistance(double meters, {bool imperial = false}) =>
    Units.distance(meters, imperial: imperial);

/// Current inside/outside state of a tag against its geofence (for the UI).
class GeofenceStatus {
  final Geofence fence;

  /// null while the tag has no GPS position yet.
  final GeofenceEvaluation? evaluation;

  const GeofenceStatus({required this.fence, this.evaluation});

  static GeofenceStatus? compute(Geofence? fence, TagReport? report) {
    if (fence == null) return null;
    if (report == null || !report.hasCoordinates) {
      return GeofenceStatus(fence: fence);
    }
    return GeofenceStatus(
      fence: fence,
      evaluation: AlertRules.evaluateGeofence(
        lat: report.lat!,
        lon: report.lon!,
        geofence: fence,
      ),
    );
  }
}

/// Detects leave / re-enter transitions per tag.
///
/// - The first evaluation (and the first one after the fence is changed,
///   enabled or re-enabled) only sets a silent baseline.
/// - A hysteresis margin avoids repeated alerts from GPS jitter on the edge:
///   leaving needs distance > radius + margin, re-entering needs
///   distance < radius - margin.
/// - Reports without a fresh fix, or already evaluated, are ignored.
class GeofenceTracker {
  GeofenceTracker({this.marginM = 15});

  final double marginM;
  final Map<String, bool> _inside = {};
  final Map<String, String> _fenceKey = {};
  final Map<String, int> _lastSrv = {};

  GeofenceTransition? update({
    required String deviceId,
    required Geofence? fence,
    required TagReport? report,
  }) {
    if (fence == null || !fence.enabled) {
      reset(deviceId);
      return null;
    }

    final key = '${fence.lat},${fence.lon},${fence.radiusM}';
    if (_fenceKey[deviceId] != key) {
      // Fence is new or was edited: forget the old state.
      _inside.remove(deviceId);
      _lastSrv.remove(deviceId);
      _fenceKey[deviceId] = key;
    }

    if (report == null || report.fix != 1 || !report.hasCoordinates) return null;
    if (_lastSrv[deviceId] == report.srv) return null;
    _lastSrv[deviceId] = report.srv;

    final distance = AlertRules.evaluateGeofence(
      lat: report.lat!,
      lon: report.lon!,
      geofence: fence,
    ).distanceToCenterMeters;

    final previous = _inside[deviceId];
    if (previous == null) {
      _inside[deviceId] = distance <= fence.radiusM;
      return null;
    }
    if (previous && distance > fence.radiusM + marginM) {
      _inside[deviceId] = false;
      return GeofenceTransition.left;
    }
    if (!previous && distance < fence.radiusM - marginM) {
      _inside[deviceId] = true;
      return GeofenceTransition.reEntered;
    }
    return null;
  }

  void reset(String deviceId) {
    _inside.remove(deviceId);
    _fenceKey.remove(deviceId);
    _lastSrv.remove(deviceId);
  }
}
