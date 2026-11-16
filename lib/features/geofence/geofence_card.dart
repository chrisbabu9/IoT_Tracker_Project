import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/domain/geofence_tracker.dart';
import 'package:trackpoint/features/geofence/geofence_providers.dart';
import 'package:trackpoint/features/settings/app_settings_providers.dart';

/// Dashboard card: geofence state at a glance, opens the editor.
class GeofenceCard extends ConsumerWidget {
  const GeofenceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(geofenceStatusProvider);
    final imperial = ref.watch(unitSystemProvider) == UnitSystem.imperial;

    String subtitle;
    Color color = AppTheme.darkMuted;
    if (status == null) {
      subtitle = AppStrings.geofenceNotSet;
    } else if (!status.fence.enabled) {
      subtitle =
          '${AppStrings.geofenceOff} · ${formatDistance(status.fence.radiusM, imperial: imperial)}';
    } else if (status.evaluation == null) {
      subtitle = AppStrings.geofenceWaitingFix;
    } else {
      final eval = status.evaluation!;
      color = eval.isInside ? AppTheme.statusOk : AppTheme.statusBad;
      subtitle =
          '${eval.isInside ? AppStrings.geofenceInside : AppStrings.geofenceOutside} · '
          '${formatDistance(eval.distanceToCenterMeters, imperial: imperial)} ${AppStrings.geofenceFromCentre}';
    }

    // Material (not a coloured Container) so ListTile ink/background paints.
    return Material(
      color: AppTheme.darkCard,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.darkLine),
      ),
      child: ListTile(
        leading: Icon(Icons.fence, color: color),
        title: const Text(AppStrings.geofenceTitle),
        subtitle: Text(subtitle, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/geofence'),
      ),
    );
  }
}
