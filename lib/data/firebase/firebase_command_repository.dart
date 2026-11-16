import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/models/tag_command.dart';
import 'package:trackpoint/data/firebase/command_repository_base.dart';

class FirebaseCommandRepository implements CommandRepository {
  final FirebaseDatabase _db;

  FirebaseCommandRepository({FirebaseDatabase? db})
      : _db = db ?? FirebaseDatabase.instance;

  @override
  Future<Result<TagCommand>> sendCommand({
    required String deviceId,
    required String type,
  }) async {
    try {
      // 1. Check for existing active command of the same type
      final activeResult = await getActiveCommand(deviceId, type);
      if (activeResult.isSuccess && activeResult.dataOrNull != null) {
        final existing = activeResult.dataOrNull!;
        // If expired by time, mark it expired first
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > existing.expiresAt) {
          await markExpired(deviceId, existing.id);
        } else {
          // Track existing command instead of creating duplicate
          return Result.success(existing);
        }
      }

      // A newer opposite command supersedes a still-pending one (e.g. STOP
      // must cancel a pending BUZZER_ON so the tag does not ring later).
      final opposite = oppositeCommandType(type);
      if (opposite != null) {
        final pending = (await getActiveCommand(deviceId, opposite)).dataOrNull;
        if (pending != null) {
          await _db
              .ref('devices/$deviceId/commands/${pending.id}')
              .update({'status': 'cancelled'});
        }
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final expiresAt = now + AppConfig.commandTimeout.inMilliseconds;

      final commandRef = _db.ref('devices/$deviceId/commands').push();
      final commandId = commandRef.key!;

      final command = TagCommand(
        id: commandId,
        type: type,
        status: 'pending',
        createdAt: now,
        expiresAt: expiresAt,
      );

      await commandRef.set(command.toJson());
      return Result.success(command);
    } catch (e) {
      return Result.failure(CommandException(e.toString()));
    }
  }

  @override
  Future<Result<TagCommand?>> getActiveCommand(String deviceId, String type) async {
    try {
      final snap = await _db
          .ref('devices/$deviceId/commands')
          .orderByChild('status')
          .equalTo('pending')
          .get();

      if (snap.exists && snap.value != null) {
        final map = snap.value as Map<dynamic, dynamic>;
        for (final entry in map.entries) {
          final cmd = TagCommand.fromJson(
            entry.value as Map<dynamic, dynamic>,
            id: entry.key.toString(),
          );
          if (cmd.type == type) return Result.success(cmd);
        }
      }

      final snapSent = await _db
          .ref('devices/$deviceId/commands')
          .orderByChild('status')
          .equalTo('sent')
          .get();

      if (snapSent.exists && snapSent.value != null) {
        final map = snapSent.value as Map<dynamic, dynamic>;
        for (final entry in map.entries) {
          final cmd = TagCommand.fromJson(
            entry.value as Map<dynamic, dynamic>,
            id: entry.key.toString(),
          );
          if (cmd.type == type) return Result.success(cmd);
        }
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(CommandException(e.toString()));
    }
  }

  @override
  Stream<TagCommand?> watchCommand(String deviceId, String commandId) {
    return _db.ref('devices/$deviceId/commands/$commandId').onValue.map((event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) return null;
      return TagCommand.fromJson(
        snap.value as Map<dynamic, dynamic>,
        id: commandId,
      );
    });
  }

  @override
  Stream<List<TagCommand>> watchRecentCommands(String deviceId, {int limit = 20}) {
    return _db
        .ref('devices/$deviceId/commands')
        .orderByKey()
        .limitToLast(limit)
        .onValue
        .map((event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) return <TagCommand>[];
      final map = snap.value as Map<dynamic, dynamic>;
      final list = <TagCommand>[];
      for (final entry in map.entries) {
        list.add(TagCommand.fromJson(
          entry.value as Map<dynamic, dynamic>,
          id: entry.key.toString(),
        ));
      }
      // Newest first
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<Result<void>> markExpired(String deviceId, String commandId) async {
    try {
      await _db.ref('devices/$deviceId/commands/$commandId').update({
        'status': 'expired',
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(CommandException(e.toString()));
    }
  }
}
