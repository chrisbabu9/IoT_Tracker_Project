import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/domain/lost_policy.dart';
import 'package:trackpoint/domain/tag_mode.dart';
import 'package:trackpoint/features/common/command_status_card.dart';
import 'package:trackpoint/features/find/find_providers.dart';
import 'package:trackpoint/features/home/tag_providers.dart';
import 'package:trackpoint/features/lost/lost_mode_controller.dart';
import 'package:trackpoint/features/lost/lost_providers.dart';

/// Lost Mode: explanation, toggle, battery-based interval table and a
/// "Request location now" button. The toggle never flips optimistically: it
/// shows "Waiting for tag..." until a BLE status or report confirms the mode.
class LostModeScreen extends ConsumerStatefulWidget {
  const LostModeScreen({super.key});

  @override
  ConsumerState<LostModeScreen> createState() => _LostModeScreenState();
}

class _LostModeScreenState extends ConsumerState<LostModeScreen> {
  bool? _pendingTarget; // state we asked for, while waiting for confirmation
  String? _commandId; // cloud command of the toggle request
  String? _locationCommandId; // cloud REPORT_NOW command
  Timer? _bleTimer;
  bool _clearScheduled = false;

  @override
  void dispose() {
    _bleTimer?.cancel();
    super.dispose();
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _clearPending() {
    _bleTimer?.cancel();
    _bleTimer = null;
    _clearScheduled = false;
    if (mounted) setState(() => _pendingTarget = null);
  }

  Future<void> _onToggle(DeviceSummary tag, bool target, bool connected) async {
    if (target) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(AppStrings.lostModeConfirmTitle),
          content: const Text(AppStrings.lostModeConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(AppStrings.lostModeConfirmAction),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() {
      _pendingTarget = target;
      _commandId = null;
    });

    final outcome = await ref.read(lostModeControllerProvider).setLostMode(
          deviceId: tag.deviceId,
          bleId: tag.bleId,
          on: target,
          bleConnected: connected,
        );
    if (!mounted) return;

    if (!outcome.ok) {
      _clearPending();
      _snack(outcome.error ?? AppStrings.lostModeFailed);
      return;
    }

    if (outcome.route == LostRoute.cloud) {
      setState(() => _commandId = outcome.commandId);
    } else if (_pendingTarget != null) {
      // BLE write accepted: wait for the STATUS notification, but not forever.
      _bleTimer?.cancel();
      _bleTimer = Timer(const Duration(seconds: 10), () {
        if (!mounted || _pendingTarget == null) return;
        _clearPending();
        _snack(AppStrings.lostModeBleNoConfirm);
      });
    }
  }

  Future<void> _requestNow(DeviceSummary tag, bool connected) async {
    final outcome = await ref.read(lostModeControllerProvider).requestLocationNow(
          deviceId: tag.deviceId,
          bleId: tag.bleId,
          bleConnected: connected,
        );
    if (!mounted) return;
    if (!outcome.ok) {
      _snack(outcome.error ?? AppStrings.lostModeFailed);
      return;
    }
    setState(() {
      _locationCommandId =
          outcome.route == LostRoute.cloud ? outcome.commandId : null;
    });
    if (outcome.route == LostRoute.ble) _snack(AppStrings.commandSent);
  }

  @override
  Widget build(BuildContext context) {
    final tag = ref.watch(selectedTagProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.lostModeTitle)),
      body: SafeArea(
        child: tag == null ? _buildNoTag(context) : _buildBody(context, tag),
      ),
    );
  }

  Widget _buildNoTag(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.findNoTag,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.darkMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/pair'),
              child: const Text(AppStrings.addYourFirstTag),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DeviceSummary tag) {
    final hasBle = tag.bleId.isNotEmpty;
    final connected = hasBle &&
        (ref.watch(tagLinkProvider(tag.bleId)).valueOrNull?.isConnected ??
            false);
    final status =
        hasBle ? ref.watch(tagBleStatusProvider(tag.bleId)).valueOrNull : null;
    final report = ref.watch(latestReportProvider(tag.deviceId)).valueOrNull;

    final info = TagModeResolver.resolve(
      bleConnected: connected,
      bleStatus: status,
      report: report,
      nowMs: DateTime.now().millisecondsSinceEpoch,
    );
    final lost = info.lostMode;
    final waiting = _pendingTarget != null;
    final battery = connected && status != null ? status.batteryPct : report?.bat;

    // A status/report now shows the requested mode: stop waiting.
    if (_pendingTarget != null && lost == _pendingTarget && !_clearScheduled) {
      _clearScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _clearPending();
      });
    }

    // The cloud command died without the tag confirming: stop waiting.
    final cid = _commandId;
    if (waiting && cid != null) {
      final cmd = ref
          .watch(commandStatusProvider(
              (deviceId: tag.deviceId, commandId: cid)))
          .valueOrNull;
      if (cmd != null &&
          (cmd.isFailed || cmd.isExpired || cmd.isCancelled) &&
          !_clearScheduled) {
        _clearScheduled = true;
        final message = cmd.isExpired
            ? AppStrings.commandExpired
            : (cmd.isFailed ? AppStrings.commandFailed : AppStrings.commandCancelled);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _clearPending();
          _snack(message);
        });
      }
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              AppStrings.lostModeDesc,
              style: TextStyle(color: AppTheme.darkMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            _buildToggleCard(tag, lost: lost, waiting: waiting, connected: connected),
            if (waiting)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _clearPending,
                  child: const Text(AppStrings.lostModeStopWaiting),
                ),
              ),
            if (_commandId != null) ...[
              const SizedBox(height: 8),
              CommandStatusCard(
                key: ValueKey('toggle_$_commandId'),
                deviceId: tag.deviceId,
                commandId: _commandId!,
              ),
            ],
            if (lost) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _requestNow(tag, connected),
                icon: const Icon(Icons.my_location),
                label: const Text(AppStrings.lostModeRequestNow),
              ),
            ],
            if (_locationCommandId != null) ...[
              const SizedBox(height: 8),
              CommandStatusCard(
                key: ValueKey('locate_$_locationCommandId'),
                deviceId: tag.deviceId,
                commandId: _locationCommandId!,
              ),
            ],
            const SizedBox(height: 20),
            _buildIntervalTable(battery),
            const SizedBox(height: 16),
            _buildWarning(),
            const SizedBox(height: 12),
            const Text(
              AppStrings.lostModeButtonNote,
              style: TextStyle(color: AppTheme.darkMuted, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard(
    DeviceSummary tag, {
    required bool lost,
    required bool waiting,
    required bool connected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: lost ? AppTheme.statusWarn : AppTheme.darkLine,
          width: lost ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lost ? AppStrings.lostModeOn : AppStrings.lostModeOff,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: lost ? AppTheme.statusWarn : null,
                  ),
                ),
                const SizedBox(height: 6),
                if (waiting)
                  const Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          AppStrings.lostModeWaiting,
                          style: TextStyle(color: AppTheme.accentCyan),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    tag.name,
                    style: const TextStyle(color: AppTheme.darkMuted, fontSize: 13),
                  ),
              ],
            ),
          ),
          Switch(
            value: lost,
            onChanged: waiting ? null : (v) => _onToggle(tag, v, connected),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalTable(int? battery) {
    final current = battery == null ? -1 : LostPolicy.getMatchingRowIndex(battery);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.lostModeTableTitle,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < LostPolicy.rows.length; i++)
            _buildPolicyRow(LostPolicy.rows[i], highlighted: i == current),
          if (battery == null)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                AppStrings.lostModeBatteryUnknown,
                style: TextStyle(color: AppTheme.darkMuted, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(LostPolicyRow row, {required bool highlighted}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlighted
            ? AppTheme.accentCyan.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted ? AppTheme.accentCyan : AppTheme.darkLine,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.batteryRange,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  row.description,
                  style: const TextStyle(color: AppTheme.darkMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(row.intervalText),
              if (highlighted)
                const Text(
                  AppStrings.lostModeCurrent,
                  style: TextStyle(
                    color: AppTheme.accentCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.statusWarn.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.statusWarn.withValues(alpha: 0.5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.battery_alert, color: AppTheme.statusWarn, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.lostModeWarning,
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
