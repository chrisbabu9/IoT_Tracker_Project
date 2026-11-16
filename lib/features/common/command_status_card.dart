import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/models/tag_command.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/find/find_providers.dart';

/// Live status of a cloud command, with a countdown to expiry.
class CommandStatusCard extends ConsumerStatefulWidget {
  const CommandStatusCard({
    super.key,
    required this.deviceId,
    required this.commandId,
  });

  final String deviceId;
  final String commandId;

  @override
  ConsumerState<CommandStatusCard> createState() => _CommandStatusCardState();
}

class _CommandStatusCardState extends ConsumerState<CommandStatusCard> {
  Timer? _timer;
  int _now = DateTime.now().millisecondsSinceEpoch;
  bool _expireSent = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now().millisecondsSinceEpoch);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _statusText(TagCommand cmd) {
    if (cmd.isPending) return AppStrings.commandPending;
    if (cmd.isSent) return AppStrings.commandSent;
    if (cmd.isCompleted) return AppStrings.commandCompleted;
    if (cmd.isFailed) return AppStrings.commandFailed;
    if (cmd.isExpired) return AppStrings.commandExpired;
    return AppStrings.commandCancelled;
  }

  Color _statusColor(TagCommand cmd) {
    if (cmd.isCompleted) return AppTheme.statusOk;
    if (cmd.isFailed || cmd.isExpired) return AppTheme.statusBad;
    if (cmd.isActive) return AppTheme.accentCyan;
    return AppTheme.darkMuted;
  }

  String _remaining(TagCommand cmd) {
    final ms = (cmd.expiresAt - _now).clamp(0, 1 << 31);
    final s = ms ~/ 1000;
    final mm = s ~/ 60;
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final cmd = ref
        .watch(commandStatusProvider(
            (deviceId: widget.deviceId, commandId: widget.commandId)))
        .valueOrNull;

    if (cmd == null) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    // Mark the command expired once its time is up and it is still active.
    if (cmd.isActive && _now >= cmd.expiresAt && !_expireSent) {
      _expireSent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(commandRepositoryProvider)
            .markExpired(widget.deviceId, widget.commandId);
      });
    }

    final color = _statusColor(cmd);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_outlined, size: 18, color: color),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  AppStrings.findViaInternet,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppTheme.darkMuted),
                ),
              ),
              const SizedBox(width: 8),
              if (cmd.isActive)
                Text(
                  '${AppStrings.findExpiresIn} ${_remaining(cmd)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.darkMuted),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _statusText(cmd),
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          if (cmd.isPending) ...[
            const SizedBox(height: 6),
            const Text(
              AppStrings.pollDelayNotice,
              style: TextStyle(fontSize: 12, color: AppTheme.darkMuted, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
