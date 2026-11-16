import 'dart:convert';

/// BLE Protocol UUIDs, byte encoding and decoding for TrackPoint smart tags.
class TpBleProtocol {
  TpBleProtocol._();

  // UUIDs
  static const String serviceUuid = '7a1c0001-6b1e-4f5a-9c1d-5b7d0e3a9f10';
  static const String charDeviceInfoUuid = '7a1c0002-6b1e-4f5a-9c1d-5b7d0e3a9f10';
  static const String charBuzzerUuid = '7a1c0003-6b1e-4f5a-9c1d-5b7d0e3a9f10';
  static const String charStatusUuid = '7a1c0004-6b1e-4f5a-9c1d-5b7d0e3a9f10';
  static const String charCommandUuid = '7a1c0005-6b1e-4f5a-9c1d-5b7d0e3a9f10';

  // Mode enum
  static const int modeUnpaired = 0;
  static const int modeNear = 1;
  static const int modeAway = 2;
  static const int modeLost = 3;
  static const int modeSos = 4;

  // Status flags bitmask
  static const int flagBuzzerOn = 1 << 0; // bit 0: 0x01
  static const int flagLostModeOn = 1 << 1; // bit 1: 0x02
  static const int flagSosOn = 1 << 2; // bit 2: 0x04

  // Commands byte codes
  static const int cmdLostOn = 0x01;
  static const int cmdLostOff = 0x02;
  static const int cmdSosOn = 0x03;
  static const int cmdSosOff = 0x04;
  static const int cmdReportNow = 0x05;

  /// Decodes DEVICE_INFO UTF-8 JSON payload: `{"id":"tp_...","fw":"0.1.0"}`
  static TpBleDeviceInfo decodeDeviceInfo(List<int> bytes) {
    final jsonStr = utf8.decode(bytes);
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return TpBleDeviceInfo(
      id: map['id']?.toString() ?? '',
      fw: map['fw']?.toString() ?? '0.0.0',
    );
  }

  /// Encodes DEVICE_INFO payload to bytes
  static List<int> encodeDeviceInfo(String id, String fw) {
    return utf8.encode(json.encode({'id': id, 'fw': fw}));
  }

  /// Encodes 1-byte BUZZER command: 0x00 off, 0x01 on
  static List<int> encodeBuzzer(bool on) {
    return [on ? 0x01 : 0x00];
  }

  /// Decodes 1-byte BUZZER state
  static bool decodeBuzzer(List<int> bytes) {
    if (bytes.isEmpty) return false;
    return bytes[0] == 0x01;
  }

  /// Decodes 4-byte STATUS characteristic
  /// [0] battery %, [1] mode enum, [2] flags, [3] reserved
  static TagStatus decodeStatus(List<int> bytes) {
    if (bytes.length < 4) {
      throw FormatException('Invalid STATUS payload length: ${bytes.length}, expected 4');
    }
    final batteryPct = bytes[0].clamp(0, 100);
    final modeCode = bytes[1];
    final flags = bytes[2];

    final modeString = switch (modeCode) {
      modeUnpaired => 'unpaired',
      modeNear => 'near',
      modeAway => 'away',
      modeLost => 'lost',
      modeSos => 'sos',
      _ => 'unknown',
    };

    return TagStatus(
      batteryPct: batteryPct,
      modeCode: modeCode,
      mode: modeString,
      buzzerOn: (flags & flagBuzzerOn) != 0,
      lostModeOn: (flags & flagLostModeOn) != 0,
      sosOn: (flags & flagSosOn) != 0,
    );
  }

  /// Encodes 4-byte STATUS payload
  static List<int> encodeStatus({
    required int batteryPct,
    required int modeCode,
    bool buzzerOn = false,
    bool lostModeOn = false,
    bool sosOn = false,
  }) {
    int flags = 0;
    if (buzzerOn) flags |= flagBuzzerOn;
    if (lostModeOn) flags |= flagLostModeOn;
    if (sosOn) flags |= flagSosOn;

    return [
      batteryPct.clamp(0, 100),
      modeCode.clamp(0, 4),
      flags,
      0x00, // reserved
    ];
  }

  /// Encodes 1-byte command
  static List<int> encodeCommand(TagBleCommand cmd) {
    final byte = switch (cmd) {
      TagBleCommand.lostOn => cmdLostOn,
      TagBleCommand.lostOff => cmdLostOff,
      TagBleCommand.sosOn => cmdSosOn,
      TagBleCommand.sosOff => cmdSosOff,
      TagBleCommand.reportNow => cmdReportNow,
    };
    return [byte];
  }
}

/// Device info read from characteristic `7a1c0002`
class TpBleDeviceInfo {
  final String id;
  final String fw;

  const TpBleDeviceInfo({required this.id, required this.fw});
}

/// Tag status decoded from characteristic `7a1c0004`
class TagStatus {
  final int batteryPct;
  final int modeCode;
  final String mode;
  final bool buzzerOn;
  final bool lostModeOn;
  final bool sosOn;

  const TagStatus({
    required this.batteryPct,
    required this.modeCode,
    required this.mode,
    required this.buzzerOn,
    required this.lostModeOn,
    required this.sosOn,
  });

  @override
  String toString() =>
      'TagStatus(battery: $batteryPct%, mode: $mode, buzzer: $buzzerOn, lost: $lostModeOn, sos: $sosOn)';
}

/// Commands writable to characteristic `7a1c0005`
enum TagBleCommand {
  lostOn,
  lostOff,
  sosOn,
  sosOff,
  reportNow,
}
