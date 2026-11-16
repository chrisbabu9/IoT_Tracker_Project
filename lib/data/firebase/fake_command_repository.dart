import 'dart:async';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/tag_command.dart';
import 'package:trackpoint/data/firebase/command_repository_base.dart';

/// In-memory fake command repository for testing
class FakeCommandRepository implements CommandRepository {
  final Map<String, Map<String, TagCommand>> _commands = {};
  final StreamController<TagCommand> _commandStream =
      StreamController<TagCommand>.broadcast();

  @override
  Future<Result<TagCommand>> sendCommand({
    required String deviceId,
    required String type,
  }) async {
    // Check active
    final active = await getActiveCommand(deviceId, type);
    if (active.dataOrNull != null) {
      return Result.success(active.dataOrNull!);
    }

    final opposite = oppositeCommandType(type);
    final superseded =
        opposite == null ? null : (await getActiveCommand(deviceId, opposite)).dataOrNull;
    if (superseded != null) {
      final c = superseded.copyWith(status: 'cancelled');
      _commands[deviceId]![superseded.id] = c;
      _commandStream.add(c);
    }

    final id = 'cmd_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now().millisecondsSinceEpoch;
    final cmd = TagCommand(
      id: id,
      type: type,
      status: 'pending',
      createdAt: now,
      expiresAt: now + AppConfig.commandTimeout.inMilliseconds,
    );

    _commands.putIfAbsent(deviceId, () => {})[id] = cmd;
    _commandStream.add(cmd);
    return Result.success(cmd);
  }

  @override
  Future<Result<TagCommand?>> getActiveCommand(String deviceId, String type) async {
    final list = _commands[deviceId]?.values ?? [];
    for (final cmd in list) {
      if (cmd.type == type && cmd.isActive) {
        return Result.success(cmd);
      }
    }
    return Result.success(null);
  }

  @override
  Stream<TagCommand?> watchCommand(String deviceId, String commandId) async* {
    yield _commands[deviceId]?[commandId];
    yield* _commandStream.stream.where((c) => c.id == commandId);
  }

  @override
  Stream<List<TagCommand>> watchRecentCommands(String deviceId, {int limit = 20}) async* {
    final list = _commands[deviceId]?.values.toList() ?? [];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    yield list.take(limit).toList();
  }

  @override
  Future<Result<void>> markExpired(String deviceId, String commandId) async {
    final cmd = _commands[deviceId]?[commandId];
    if (cmd != null) {
      final updated = cmd.copyWith(status: 'expired');
      _commands[deviceId]![commandId] = updated;
      _commandStream.add(updated);
    }
    return Result.success(null);
  }

  void updateCommandStatus(String deviceId, String commandId, String status) {
    final cmd = _commands[deviceId]?[commandId];
    if (cmd != null) {
      final updated = cmd.copyWith(status: status, ackedAt: DateTime.now().millisecondsSinceEpoch);
      _commands[deviceId]![commandId] = updated;
      _commandStream.add(updated);
    }
  }

  void dispose() {
    _commandStream.close();
  }
}
