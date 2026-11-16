import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/data/firebase/command_repository.dart';

enum BuzzerRoute { ble, cloud }

class BuzzerOutcome {
  final BuzzerRoute? route;
  final String? commandId;
  final String? error;

  const BuzzerOutcome.ble()
      : route = BuzzerRoute.ble,
        commandId = null,
        error = null;

  const BuzzerOutcome.cloud(this.commandId)
      : route = BuzzerRoute.cloud,
        error = null;

  const BuzzerOutcome.failed(this.error)
      : route = null,
        commandId = null;

  bool get ok => error == null;
}

/// Rings / silences the tag: instantly over BLE when connected, otherwise
/// (or if the BLE write fails) through a cloud command.
class BuzzerController {
  BuzzerController({required this.ble, required this.commands});

  final TagBleService ble;
  final CommandRepository commands;

  Future<BuzzerOutcome> set({
    required String deviceId,
    required String bleId,
    required bool on,
    required bool bleConnected,
  }) async {
    if (bleConnected && bleId.isNotEmpty) {
      try {
        await ble.setBuzzer(bleId, on);
        return const BuzzerOutcome.ble();
      } catch (_) {
        // Fall through to the cloud route.
      }
    }

    final result = await commands.sendCommand(
      deviceId: deviceId,
      type: on ? 'BUZZER_ON' : 'BUZZER_OFF',
    );
    return result.fold(
      onSuccess: (cmd) => BuzzerOutcome.cloud(cmd.id),
      onFailure: (e) => BuzzerOutcome.failed(e.message),
    );
  }
}
