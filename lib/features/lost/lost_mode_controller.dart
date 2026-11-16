import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/data/ble/tp_ble_protocol.dart';
import 'package:trackpoint/data/firebase/command_repository.dart';

enum LostRoute { ble, cloud }

class LostRequestOutcome {
  final LostRoute? route;
  final String? commandId;
  final String? error;

  const LostRequestOutcome.ble()
      : route = LostRoute.ble,
        commandId = null,
        error = null;

  const LostRequestOutcome.cloud(this.commandId)
      : route = LostRoute.cloud,
        error = null;

  const LostRequestOutcome.failed(this.error)
      : route = null,
        commandId = null;

  bool get ok => error == null;
}

/// Sends Lost Mode / REPORT_NOW requests: over BLE when connected (falling
/// back to the cloud if the write fails), otherwise as a cloud command.
class LostModeController {
  LostModeController({required this.ble, required this.commands});

  final TagBleService ble;
  final CommandRepository commands;

  Future<LostRequestOutcome> setLostMode({
    required String deviceId,
    required String bleId,
    required bool on,
    required bool bleConnected,
  }) {
    return _send(
      deviceId: deviceId,
      bleId: bleId,
      bleConnected: bleConnected,
      bleCommand: on ? TagBleCommand.lostOn : TagBleCommand.lostOff,
      cloudType: on ? 'LOST_ON' : 'LOST_OFF',
    );
  }

  Future<LostRequestOutcome> requestLocationNow({
    required String deviceId,
    required String bleId,
    required bool bleConnected,
  }) {
    return _send(
      deviceId: deviceId,
      bleId: bleId,
      bleConnected: bleConnected,
      bleCommand: TagBleCommand.reportNow,
      cloudType: 'REPORT_NOW',
    );
  }

  Future<LostRequestOutcome> _send({
    required String deviceId,
    required String bleId,
    required bool bleConnected,
    required TagBleCommand bleCommand,
    required String cloudType,
  }) async {
    if (bleConnected && bleId.isNotEmpty) {
      try {
        await ble.sendCommand(bleId, bleCommand);
        return const LostRequestOutcome.ble();
      } catch (_) {
        // Fall through to the cloud route.
      }
    }
    final result =
        await commands.sendCommand(deviceId: deviceId, type: cloudType);
    return result.fold(
      onSuccess: (cmd) => LostRequestOutcome.cloud(cmd.id),
      onFailure: (e) => LostRequestOutcome.failed(e.message),
    );
  }
}
