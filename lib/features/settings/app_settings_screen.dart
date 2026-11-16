import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/features/settings/app_settings_providers.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitSystem = ref.watch(unitSystemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appSettingsTitle),
        backgroundColor: AppTheme.darkBackground,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Units
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.unitsTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<UnitSystem>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: UnitSystem.metric, label: Text('Metric')),
                      ButtonSegment(
                          value: UnitSystem.imperial, label: Text('Imperial')),
                    ],
                    selected: {unitSystem},
                    onSelectionChanged: (sel) async {
                      final v = sel.first;
                      ref.read(unitSystemProvider.notifier).state = v;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(AppConfig.prefUnits, v.name);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Metric: m, km, km/h  ·  Imperial: ft, miles, mph',
                    style: TextStyle(color: AppTheme.darkMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Navigation list tiles
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text(AppStrings.alertsSettings),
                  subtitle: const Text('Configure notification categories'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/alerts'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text(AppStrings.helpTitle),
                  subtitle: const Text('FAQs, button guide & troubleshooting'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/help'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code_outlined),
                  title: const Text(AppStrings.developerOptions),
                  subtitle: const Text('Simulation, emulator, raw data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/developer'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text(AppStrings.account),
                  subtitle: const Text('Manage password & account details'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
