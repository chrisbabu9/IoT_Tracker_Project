import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/domain/alert_rules.dart';
import 'package:trackpoint/domain/tag_presence.dart';

/// Mutable per-tag memory used to turn a stream of reports into alerts.
/// Survives provider rebuilds so nothing is re-fired (B-06).
class DeviceAlertState {
  int? lastSrv;
  TagReport? lastReport;
  PresenceState? lastPresence;
  bool lastHasFix = false;
  String? lastMode;
  bool bleConnected = false;
  int? bleDroppedAtMs;
  int? lastLeftBehindMs;

  /// Returns true when the link just dropped (connected -> disconnected).
  bool setBle(bool connected, int nowMs) {
    final dropped = bleConnected && !connected;
    if (dropped) bleDroppedAtMs = nowMs;
    if (connected) bleDroppedAtMs = null;
    bleConnected = connected;
    return dropped;
  }
}

/// Pure alert decision logic (no Flutter/Firebase). See tests/alert_evaluator_test.
class AlertEvaluator {
  AlertEvaluator._();

  static AlertEvent _e(AlertType t, String title, String msg, int ts, String id) =>
      AlertEvent(type: t, title: title, message: msg, timestampMs: ts, deviceId: id);

  static bool _wasOffline(PresenceState? s) =>
      s == PresenceState.offline || s == PresenceState.neverConnected;

  /// New cloud report. The first report seen only sets a silent baseline;
  /// repeated reports (same srv) are ignored.
  static List<AlertEvent> onReport({
    required DeviceAlertState st,
    required String deviceId,
    required String tagName,
    required TagReport? report,
    required int nowMs,
    int offlineTimeoutS = 900,
  }) {
    if (report == null || report.srv == st.lastSrv) return const [];
    final prev = st.lastReport;
    final first = st.lastSrv == null;
    final wasOffline = _wasOffline(st.lastPresence);
    final prevMode = st.lastMode;
    final prevFix = st.lastHasFix;

    final presence = TagPresence.compute(
      isBleConnected: st.bleConnected,
      latestReport: report,
      offlineTimeoutSeconds: offlineTimeoutS,
      currentTimestampMs: nowMs,
    ).state;
    st
      ..lastSrv = report.srv
      ..lastReport = report
      ..lastPresence = presence
      ..lastMode = report.mode
      ..lastHasFix = report.fix == 1;
    if (first) return const [];

    final ts = report.srv;
    final out = <AlertEvent>[];
    if (wasOffline && !_wasOffline(presence)) {
      out.add(_e(AlertType.tagBackOnline, AppStrings.alertTitleOnline,
          '$tagName is reporting again.', ts, deviceId));
    }
    if (prev != null && prev.bat >= 20 && report.bat < 20) {
      out.add(_e(AlertType.lowBattery, AppStrings.alertTitleLowBattery,
          '$tagName battery at ${report.bat}%.', ts, deviceId));
    }
    if (report.why == 'final') {
      out.add(_e(AlertType.batteryCriticalFinal, AppStrings.alertTitleCritical,
          '$tagName sent a final battery report (${report.bat}%).', ts, deviceId));
    }
    if (prevFix && report.fix != 1) {
      out.add(_e(AlertType.gpsFixLost, AppStrings.alertTitleGpsLost,
          '$tagName lost GPS fix.', ts, deviceId));
    }
    if (report.why == 'movement') {
      out.add(_e(AlertType.movementDetected, AppStrings.alertTitleMovement,
          '$tagName detected movement.', ts, deviceId));
    }
    if (report.mode == 'sos' && prevMode != 'sos') {
      out.add(_e(AlertType.sosAlert, AppStrings.alertTitleSos,
          '$tagName is in SOS mode!', ts, deviceId));
    }
    if (report.mode == 'lost' && report.fix == 1 && (prevMode != 'lost' || !prevFix)) {
      out.add(_e(AlertType.lostModeUpdate, AppStrings.alertTitleLostUpdate,
          '$tagName sent a Lost Mode location update.', ts, deviceId));
    }
    return out;
  }

  static const int leftBehindCooldownMs = 10 * 60 * 1000;

  /// BLE link just dropped: "did you leave it behind?". Skipped when the tag is
  /// already in Lost/SOS mode (the user knows) and rate-limited per tag.
  /// Works while the app process is alive (no background service).
  static List<AlertEvent> onBleDrop({
    required DeviceAlertState st,
    required String deviceId,
    required String tagName,
    required int nowMs,
  }) {
    if (st.lastMode == 'lost' || st.lastMode == 'sos') return const [];
    final last = st.lastLeftBehindMs;
    if (last != null && nowMs - last < leftBehindCooldownMs) return const [];
    st.lastLeftBehindMs = nowMs;
    return [
      _e(AlertType.leftBehind, AppStrings.alertTitleLeftBehind,
          '$tagName disconnected from your phone. Did you leave it behind?', nowMs, deviceId)
    ];
  }

  /// Periodic check: a tag that went silent never produces a new report, so
  /// "offline" must be detected by time. Never fires while BLE is connected, and
  /// waits a full window after a BLE drop (the tag needs time to start reporting).
  static List<AlertEvent> onTick({
    required DeviceAlertState st,
    required String deviceId,
    required String tagName,
    required int nowMs,
    int offlineTimeoutS = 900,
  }) {
    final r = st.lastReport;
    if (r == null) return const [];
    final info = TagPresence.compute(
      isBleConnected: st.bleConnected,
      latestReport: r,
      offlineTimeoutSeconds: offlineTimeoutS,
      currentTimestampMs: nowMs,
    );
    if (info.state == PresenceState.offline &&
        st.bleDroppedAtMs != null &&
        nowMs < st.bleDroppedAtMs! + info.expectedWindowSeconds * 1000) {
      return const []; // grace period after BLE drop
    }
    final wasLive = !_wasOffline(st.lastPresence);
    st.lastPresence = info.state;
    if (info.state == PresenceState.offline && wasLive) {
      return [
        _e(AlertType.tagOffline, AppStrings.alertTitleOffline,
            '$tagName stopped reporting.', nowMs, deviceId)
      ];
    }
    return const [];
  }
}
