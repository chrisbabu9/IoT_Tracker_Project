import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/domain/lost_policy.dart';

/// Connection state categories for a TrackPoint smart tag.
enum PresenceState {
  near, // BLE connected. Tag's GPS and modem are OFF.
  away, // Cloud live: BLE lost, reporting on away schedule.
  lost, // Cloud live: Lost Mode active.
  sos, // Cloud live: SOS reporting active.
  offline, // Not connected, report older than expected window.
  neverConnected, // No reports and never connected.
}

/// Result of evaluating tag presence.
class TagPresenceInfo {
  final PresenceState state;
  final String label;
  final int expectedWindowSeconds;
  final int? lastCommunicationMs;
  final String? lastSeenText;

  const TagPresenceInfo({
    required this.state,
    required this.label,
    required this.expectedWindowSeconds,
    this.lastCommunicationMs,
    this.lastSeenText,
  });

  bool get isNear => state == PresenceState.near;
  bool get isLive =>
      state == PresenceState.near ||
      state == PresenceState.away ||
      state == PresenceState.lost ||
      state == PresenceState.sos;
  bool get isOffline => state == PresenceState.offline;
  bool get isNeverConnected => state == PresenceState.neverConnected;
}

/// Pure, unit-tested calculation of tag presence state.
class TagPresence {
  TagPresence._();

  /// Computes tag presence state given BLE connection, latest report, and offline timeout setting.
  ///
  /// Rules:
  /// 1. BLE connected -> NEAR (never offline while BLE is connected).
  /// 2. Not connected, latest cloud report mode in {away, lost, sos} and report age < expected-offline window -> AWAY / LOST / SOS "live".
  /// 3. Not connected and report older than the window -> OFFLINE ("last seen X ago").
  /// 4. No reports and never connected -> NEVER CONNECTED.
  static TagPresenceInfo compute({
    required bool isBleConnected,
    required TagReport? latestReport,
    required int offlineTimeoutSeconds,
    int? currentTimestampMs,
  }) {
    final now = currentTimestampMs ?? DateTime.now().millisecondsSinceEpoch;

    // Rule 1: BLE connected -> NEAR
    if (isBleConnected) {
      return TagPresenceInfo(
        state: PresenceState.near,
        label: 'Near (BLE)',
        expectedWindowSeconds: offlineTimeoutSeconds,
        lastCommunicationMs: now,
      );
    }

    // Rule 4: No reports ever and not connected -> NEVER CONNECTED
    if (latestReport == null || latestReport.srv <= 0) {
      return const TagPresenceInfo(
        state: PresenceState.neverConnected,
        label: 'Never connected',
        expectedWindowSeconds: 0,
        lastCommunicationMs: null,
      );
    }

    // Compute expected-offline window in seconds
    final mode = latestReport.mode.toLowerCase();
    int baseIntervalSeconds;

    if (mode == 'lost') {
      // 3x battery-table interval + 60s
      final interval = LostPolicy.getReportingIntervalSeconds(latestReport.bat);
      baseIntervalSeconds = (3 * interval) + 60;
    } else if (mode == 'sos') {
      // 3 min
      baseIntervalSeconds = 180;
    } else if (mode == 'away') {
      // 3x 5 min = 15 min
      baseIntervalSeconds = 15 * 60;
    } else {
      // default fallback
      baseIntervalSeconds = 15 * 60;
    }

    final expectedWindowSeconds = baseIntervalSeconds > offlineTimeoutSeconds
        ? baseIntervalSeconds
        : offlineTimeoutSeconds;

    final ageSeconds = ((now - latestReport.srv) / 1000).floor();

    // Rule 2 & 3: Check if within expected window
    if (ageSeconds < expectedWindowSeconds) {
      if (mode == 'lost') {
        return TagPresenceInfo(
          state: PresenceState.lost,
          label: 'Lost Mode',
          expectedWindowSeconds: expectedWindowSeconds,
          lastCommunicationMs: latestReport.srv,
        );
      } else if (mode == 'sos') {
        return TagPresenceInfo(
          state: PresenceState.sos,
          label: 'SOS Active',
          expectedWindowSeconds: expectedWindowSeconds,
          lastCommunicationMs: latestReport.srv,
        );
      } else {
        return TagPresenceInfo(
          state: PresenceState.away,
          label: 'Away (Live)',
          expectedWindowSeconds: expectedWindowSeconds,
          lastCommunicationMs: latestReport.srv,
        );
      }
    } else {
      // Rule 3: Report older than expected window -> OFFLINE
      return TagPresenceInfo(
        state: PresenceState.offline,
        label: 'Offline',
        expectedWindowSeconds: expectedWindowSeconds,
        lastCommunicationMs: latestReport.srv,
      );
    }
  }
}
