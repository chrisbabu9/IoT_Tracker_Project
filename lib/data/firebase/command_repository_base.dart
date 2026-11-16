import 'dart:async';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/tag_command.dart';

/// The command that cancels [type] (BUZZER_ON <-> BUZZER_OFF, LOST_ON <-> LOST_OFF).
String? oppositeCommandType(String type) => switch (type) {
      'BUZZER_ON' => 'BUZZER_OFF',
      'BUZZER_OFF' => 'BUZZER_ON',
      'LOST_ON' => 'LOST_OFF',
      'LOST_OFF' => 'LOST_ON',
      _ => null,
    };

abstract class CommandRepository {
  Future<Result<TagCommand>> sendCommand({
    required String deviceId,
    required String type,
  });

  Stream<TagCommand?> watchCommand(String deviceId, String commandId);
  Stream<List<TagCommand>> watchRecentCommands(String deviceId, {int limit = 20});
  Future<Result<void>> markExpired(String deviceId, String commandId);
  Future<Result<TagCommand?>> getActiveCommand(String deviceId, String type);
}
