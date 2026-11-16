import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/dashboard/tag_presence_provider.dart';
import 'package:trackpoint/features/settings/app_settings_providers.dart';

class DeveloperScreen extends ConsumerStatefulWidget {
  const DeveloperScreen({super.key});

  @override
  ConsumerState<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends ConsumerState<DeveloperScreen> {
  late TextEditingController _tileUrlController;
  bool _isTestingFirebase = false;
  String? _firebaseDiagResult;

  @override
  void initState() {
    super.initState();
    _tileUrlController = TextEditingController(
      text: ref.read(customTileUrlProvider) ?? AppConfig.osmTileUrlTemplate,
    );
  }

  @override
  void dispose() {
    _tileUrlController.dispose();
    super.dispose();
  }

  Future<void> _runFirebaseDiagnostics() async {
    setState(() {
      _isTestingFirebase = true;
      _firebaseDiagResult = 'Running diagnostics...';
    });

    final buffer = StringBuffer();
    final user = ref.read(currentUserProvider);

    if (user == null) {
      buffer.writeln('❌ Auth: No user signed in!');
      buffer.writeln('Please sign in with email/password before testing RTDB.');
      if (mounted) {
        setState(() {
          _isTestingFirebase = false;
          _firebaseDiagResult = buffer.toString();
        });
      }
      return;
    }

    buffer.writeln('✅ Auth: Signed in');
    buffer.writeln('   UID: ${user.uid}');
    buffer.writeln('   Email: ${user.email ?? "(none)"}');
    buffer.writeln('   Target: ${AppConfig.useEmulator ? "Local Emulator" : "Production Cloud"}');

    try {
      final db = FirebaseDatabase.instance;
      buffer.writeln('\n1. Testing Write to users/${user.uid}/_diagnostic_ping...');
      await db.ref('users/${user.uid}/_diagnostic_ping').set({
        'pingAt': ServerValue.timestamp,
        'platform': 'flutter_diag',
      }).timeout(const Duration(seconds: 8));
      buffer.writeln('   ✅ Success: User node is writable');

      buffer.writeln('\n2. Checking simulated tag "tp_c0ffee00dead5e61"...');
      final ownerSnap = await db.ref('devices/tp_c0ffee00dead5e61/meta/owner')
          .get()
          .timeout(const Duration(seconds: 8));

      if (!ownerSnap.exists || ownerSnap.value == null) {
        buffer.writeln('   ✅ Tag Status: UNCLAIMED (Ready for pairing)');
      } else {
        final currentOwner = ownerSnap.value.toString();
        if (currentOwner == user.uid) {
          buffer.writeln('   ℹ️ Tag Status: Claimed by YOUR account ($currentOwner)');
        } else {
          buffer.writeln('   ⚠️ Tag Status: Already claimed by ANOTHER user: $currentOwner');
          buffer.writeln('   (Security rules will reject re-claiming until cleared in RTDB)');
        }
      }
    } on TimeoutException {
      buffer.writeln('❌ RTDB Timeout: Database request took >8s.');
      buffer.writeln('   Check internet and Firebase region URL.');
    } catch (e) {
      buffer.writeln('❌ RTDB Error: $e');
      if (e.toString().contains('permission-denied') || e.toString().contains('Permission denied')) {
        buffer.writeln('   ⚠️ Firebase Security Rules rejected this request.');
        buffer.writeln('   Deploy database.rules.json to Firebase Console.');
      }
    }

    if (mounted) {
      setState(() {
        _isTestingFirebase = false;
        _firebaseDiagResult = buffer.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSimulation = ref.watch(simulationModeProvider);
    final reportAsync = ref.watch(selectedDeviceReportProvider);
    final selectedId = ref.watch(selectedDeviceIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.developerOptions),
        backgroundColor: AppTheme.darkBackground,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Simulation Mode Card
          Card(
            child: SwitchListTile(
              title: const Text(
                AppStrings.simulationMode,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                AppStrings.simulationModeDesc,
                style: TextStyle(color: AppTheme.darkMuted, fontSize: 12),
              ),
              value: isSimulation,
              onChanged: (val) async {
                ref.read(simulationModeProvider.notifier).state = val;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(AppConfig.prefSimulationMode, val);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Firebase Emulator Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.emulatorToggle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppStrings.emulatorDesc,
                    style: TextStyle(color: AppTheme.darkMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Status: ${AppConfig.useEmulator ? "Connected (Local)" : "Production Firebase"}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppConfig.useEmulator
                          ? AppTheme.statusWarn
                          : AppTheme.statusOk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Host: ${AppConfig.emulatorHost} (Auth: ${AppConfig.authEmulatorPort}, RTDB: ${AppConfig.rtdbEmulatorPort})',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppTheme.darkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Firebase RTDB Live Diagnostics Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Firebase RTDB Connection Test',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Validates authentication state, RTDB read/write permissions, and simulated tag ownership.',
                    style: TextStyle(color: AppTheme.darkMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isTestingFirebase ? null : _runFirebaseDiagnostics,
                    icon: _isTestingFirebase
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check),
                    label: Text(_isTestingFirebase ? 'Testing...' : 'Run Diagnostics'),
                  ),
                  if (_firebaseDiagResult != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.darkLine),
                      ),
                      child: SelectableText(
                        _firebaseDiagResult!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.4,
                          color: AppTheme.accentCyan,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tile URL Override Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.tileUrlOverride,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tileUrlController,
                    decoration: const InputDecoration(
                      hintText: 'https://...',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final text = _tileUrlController.text.trim();
                          ref.read(customTileUrlProvider.notifier).state =
                              text.isNotEmpty ? text : null;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tile URL updated')),
                          );
                        },
                        child: const Text(AppStrings.save),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          _tileUrlController.text =
                              AppConfig.osmTileUrlTemplate;
                          ref.read(customTileUrlProvider.notifier).state = null;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reset to default OSM tiles'),
                            ),
                          );
                        },
                        child: const Text(AppStrings.tileUrlReset),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Raw Report Inspector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.showRawReports} (${selectedId ?? "No device"})',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppStrings.showRawReportsDesc,
                    style: TextStyle(color: AppTheme.darkMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  reportAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                    data: (report) {
                      if (report == null) {
                        return const Text(
                          'No reports recorded yet for this device.',
                          style: TextStyle(color: AppTheme.darkMuted),
                        );
                      }
                      final pretty = const JsonEncoder.withIndent('  ')
                          .convert(report.toJson());
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          pretty,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
