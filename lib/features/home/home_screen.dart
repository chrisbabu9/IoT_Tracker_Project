import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/home/widgets/tag_card.dart';

/// Main screen displaying the user's multi-tag device list,
/// connection status cards, actions to add, rename, and remove tags.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final int _navIndex = 0;

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        context.push('/map');
        break;
      case 2:
        context.push('/find');
        break;
      case 3:
        context.push('/alerts');
        break;
      case 4:
        context.push('/settings');
        break;
    }
  }

  Future<void> _showRenameDialog(DeviceSummary device) async {
    final textController = TextEditingController(text: device.name);
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.darkNav,
          title: const Text(AppStrings.renameTag),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: AppStrings.deviceName,
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a device name';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final newName = textController.text.trim();
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final deviceRepo = ref.read(deviceRepositoryProvider);
        final res = await deviceRepo.renameDevice(
          uid: user.uid,
          deviceId: device.deviceId,
          newName: newName,
        );

        if (res.isSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.tagRenamedSuccess)),
          );
        }
      }
    }
  }

  Future<void> _showRemoveDialog(DeviceSummary device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.darkNav,
          title: const Text(AppStrings.removeTagConfirmTitle),
          content: const Text(
            AppStrings.removeTagConfirmMessage,
            style: TextStyle(color: AppTheme.darkMuted, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusBad,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(AppStrings.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final deviceRepo = ref.read(deviceRepositoryProvider);
        final bleService = ref.read(bleServiceProvider);

        // 1. Unbond and disconnect from local BLE
        await bleService.removeBond(device.bleId);

        // 2. Remove from user's device index in Firebase
        final res = await deviceRepo.removeDevice(
          uid: user.uid,
          deviceId: device.deviceId,
        );

        if (res.isSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.tagRemovedSuccess)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSimulation = ref.watch(simulationModeProvider);
    final userDevicesAsync = ref.watch(userDevicesProvider);
    final selectedDeviceId = ref.watch(selectedDeviceIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.brandGradient.createShader(bounds),
              child:
                  const Icon(Icons.location_on, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 8),
            const Text(
              AppStrings.appTitle,
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          // Simulation indicator chip
          if (isSimulation)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentPurple.withValues(alpha: 0.5),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.science_outlined,
                      size: 14, color: AppTheme.accentPurple),
                  SizedBox(width: 4),
                  Text(
                    'Sim',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.accentPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            tooltip: AppStrings.account,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/account'),
          ),
        ],
      ),
      body: SafeArea(
        child: userDevicesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.accentCyan),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppTheme.statusBad),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading devices: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.darkMuted),
                  ),
                ],
              ),
            ),
          ),
          data: (devices) {
            if (devices.isEmpty) {
              return _buildEmptyState();
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    if (idx == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppStrings.myTags} (${devices.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => context.push('/pair'),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Tag'),
                            ),
                          ],
                        ),
                      );
                    }

                    final device = devices[idx - 1];
                    final isSelected = device.deviceId == selectedDeviceId;

                    return TagCard(
                      device: device,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedDeviceOverrideProvider.notifier).state =
                            device.deviceId;
                        context.push('/dashboard');
                      },
                      onRename: () => _showRenameDialog(device),
                      onRemove: () => _showRemoveDialog(device),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/pair'),
        icon: const Icon(Icons.add),
        label: const Text('Add Tag'),
        backgroundColor: AppTheme.accentBlue,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.darkNav,
        selectedItemColor: AppTheme.accentCyan,
        unselectedItemColor: AppTheme.darkMuted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: AppStrings.navMap,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radar_outlined),
            activeIcon: Icon(Icons.radar),
            label: AppStrings.navFind,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: AppStrings.navAlerts,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: AppStrings.navMore,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentBlue.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.devices_other_outlined,
                size: 54,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.noTagsYet,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.noTagsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.darkMuted, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/pair'),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(AppStrings.addYourFirstTag),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
