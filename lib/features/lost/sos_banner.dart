import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/core/time_utils.dart';
import 'package:trackpoint/features/home/tag_providers.dart';
import 'package:trackpoint/features/lost/lost_providers.dart';

/// Wraps the whole app and shows a red full-width banner on every screen
/// for each tag that is in SOS. Use it in `MaterialApp.router(builder: ...)`.
class SosBannerHost extends ConsumerWidget {
  const SosBannerHost({
    super.key,
    required this.child,
    required this.onOpenMap,
  });

  final Widget child;
  final void Function(String deviceId) onOpenMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(sosTagsProvider);
    if (tags.isNotEmpty) {
      // Re-render every 30 s so "x min ago" stays correct.
      ref.watch(clockTickProvider);
    }

    // The column always has the same two children so the app's Navigator
    // keeps its state when a banner appears or disappears.
    return Column(
      children: [
        if (tags.isEmpty)
          const SizedBox.shrink()
        else
          Material(
            color: AppTheme.statusBad,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  for (final t in tags)
                    _SosBanner(
                      tag: t,
                      onOpenMap: () => onOpenMap(t.device.deviceId),
                    ),
                ],
              ),
            ),
          ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: tags.isNotEmpty,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _SosBanner extends StatelessWidget {
  const _SosBanner({required this.tag, required this.onOpenMap});

  final SosTag tag;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final r = tag.report;
    final location = (r != null && r.hasCoordinates)
        ? '${r.lat!.toStringAsFixed(5)}, ${r.lon!.toStringAsFixed(5)} · ${TimeUtils.formatTimeAgo(r.srv)}'
        : AppStrings.sosNoFix;
    final battery = tag.batteryPct == null
        ? ''
        : '  ·  ${AppStrings.sosBattery} ${tag.batteryPct}%';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.sosBannerTitle} · ${tag.device.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppStrings.sosLastLocation}: $location$battery',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onOpenMap,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text(AppStrings.sosOpenMap),
          ),
        ],
      ),
    );
  }
}
