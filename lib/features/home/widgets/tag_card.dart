import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/core/time_utils.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/domain/tag_presence.dart';
import 'package:trackpoint/features/home/tag_providers.dart';

/// Interactive device card displaying real-time tag presence,
/// battery level, GPS status, and connection mode.
/// Supports tap to select, long-press for options, and swipe-to-delete.
class TagCard extends ConsumerWidget {
  final DeviceSummary device;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onRemove;

  const TagCard({
    super.key,
    required this.device,
    required this.isSelected,
    required this.onTap,
    required this.onRename,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(clockTickProvider);
    final isBleConnected =
        ref.watch(tagLinkProvider(device.bleId)).valueOrNull?.isConnected ??
            false;
    final bleStatus = ref.watch(tagBleStatusProvider(device.bleId)).valueOrNull;
    final latestReport =
        ref.watch(latestReportProvider(device.deviceId)).valueOrNull;
    final offlineTimeoutS = ref
            .watch(tagConfigProvider(device.deviceId))
            .valueOrNull
            ?.settings
            .offlineTimeoutS ??
        900;

    final presence = TagPresence.compute(
      isBleConnected: isBleConnected,
      latestReport: latestReport,
      offlineTimeoutSeconds: offlineTimeoutS,
    );

    // Effective Battery
    final int? batteryPct = isBleConnected && bleStatus != null
        ? bleStatus.batteryPct
        : latestReport?.bat;

    // Last seen text
    final String lastSeenDisplay;
    if (isBleConnected) {
      lastSeenDisplay = 'Connected now';
    } else if (latestReport != null && latestReport.srv > 0) {
      lastSeenDisplay =
          'Last seen ${TimeUtils.formatTimeAgo(latestReport.srv)}';
    } else {
      lastSeenDisplay = 'Never connected';
    }

    return Dismissible(
      key: Key('tag_${device.deviceId}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onRemove();
        return false; // Let onRemove handle the confirmation dialog
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.statusBad.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.statusBad),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showDeviceActionSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.accentCyan : AppTheme.darkLine,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.accentCyan.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name, Selected Check, and Presence Status Pill
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.radar,
                      color: isSelected
                          ? AppTheme.accentCyan
                          : AppTheme.accentPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          device.deviceId,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.darkMuted,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusPill(presence),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Telemetry Info Row: Battery, GPS, Signal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Battery
                  _buildTelemetryItem(
                    icon: _getBatteryIcon(batteryPct ?? 0),
                    iconColor: batteryPct == null
                        ? AppTheme.darkMuted
                        : _getBatteryColor(batteryPct),
                    label: batteryPct == null ? '—' : '$batteryPct%',
                    sublabel: 'Battery',
                  ),

                  // GPS Status
                  _buildTelemetryItem(
                    icon: Icons.location_on_outlined,
                    iconColor: (latestReport?.fix == 1)
                        ? AppTheme.statusOk
                        : AppTheme.darkMuted,
                    label: (latestReport?.fix == 1)
                        ? 'Fix (${latestReport?.acc ?? 0}m ${AppStrings.accuracyEst})'
                        : AppStrings.noFixYet,
                    sublabel: isBleConnected ? 'BLE nearby' : 'Cellular GPS',
                  ),

                  // Signal / Mode
                  _buildTelemetryItem(
                    icon: isBleConnected
                        ? Icons.bluetooth_connected
                        : Icons.cell_tower,
                    iconColor: isBleConnected
                        ? AppTheme.accentCyan
                        : (latestReport?.signalDbm != null // csq 99 = unknown
                            ? AppTheme.statusOk
                            : AppTheme.darkMuted),
                    label: isBleConnected
                        ? 'Connected'
                        : (latestReport?.signalDbm != null
                            ? '${latestReport!.signalDbm} dBm'
                            : 'Offline'),
                    sublabel: isBleConnected ? 'BLE' : '4G LTE',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Footer: Last seen timestamp and actions button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 13, color: AppTheme.darkMuted),
                      const SizedBox(width: 4),
                      Text(
                        lastSeenDisplay,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkMuted,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz,
                        size: 20, color: AppTheme.darkMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showDeviceActionSheet(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(TagPresenceInfo presence) {
    Color pillColor;
    Color textColor;

    switch (presence.state) {
      case PresenceState.near:
        pillColor = AppTheme.statusOk;
        textColor = const Color(0xFFBBF7D0);
        break;
      case PresenceState.away:
      case PresenceState.lost:
        pillColor = AppTheme.statusWarn;
        textColor = const Color(0xFFFDE68A);
        break;
      case PresenceState.sos:
      case PresenceState.offline:
        pillColor = AppTheme.statusBad;
        textColor = const Color(0xFFFECACA);
        break;
      case PresenceState.neverConnected:
        pillColor = AppTheme.darkMuted;
        textColor = const Color(0xFFE2E8F0);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pillColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: pillColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            presence.label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sublabel,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sublabel,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.darkMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getBatteryIcon(int pct) {
    if (pct > 80) return Icons.battery_full;
    if (pct > 50) return Icons.battery_5_bar;
    if (pct > 20) return Icons.battery_3_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(int pct) {
    if (pct >= 40) return AppTheme.statusOk; // same bands as the dashboard
    if (pct >= 20) return AppTheme.statusWarn;
    return AppTheme.statusBad;
  }

  void _showDeviceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkNav,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined,
                      color: AppTheme.accentCyan),
                  title: const Text(AppStrings.renameTag),
                  onTap: () {
                    Navigator.pop(ctx);
                    onRename();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: AppTheme.statusBad),
                  title: const Text(
                    AppStrings.removeTag,
                    style: TextStyle(color: AppTheme.statusBad),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onRemove();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
