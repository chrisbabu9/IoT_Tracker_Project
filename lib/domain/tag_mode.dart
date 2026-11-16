import 'package:trackpoint/data/ble/tp_ble_protocol.dart';
import 'package:trackpoint/data/models/tag_report.dart';

class TagModeInfo {
  final bool lostMode;
  final bool sos;
  const TagModeInfo({required this.lostMode, required this.sos});
}

/// Works out whether a tag is in Lost Mode / SOS.
/// BLE STATUS is authoritative while connected; otherwise the latest cloud
/// report is trusted (SOS only while that report is recent).
class TagModeResolver {
  TagModeResolver._();

  static const int sosMaxAgeMs = 6 * 60 * 60 * 1000;

  static TagModeInfo resolve({
    required bool bleConnected,
    TagStatus? bleStatus,
    TagReport? report,
    required int nowMs,
  }) {
    if (bleConnected && bleStatus != null) {
      return TagModeInfo(
        lostMode: bleStatus.lostModeOn || bleStatus.mode == 'lost',
        sos: bleStatus.sosOn || bleStatus.mode == 'sos',
      );
    }
    final mode = report?.mode;
    final ageMs = report == null ? null : nowMs - report.srv;
    return TagModeInfo(
      lostMode: mode == 'lost',
      sos: mode == 'sos' && ageMs != null && ageMs <= sosMaxAgeMs,
    );
  }
}
