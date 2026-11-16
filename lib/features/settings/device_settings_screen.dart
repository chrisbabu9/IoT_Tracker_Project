import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/core/time_utils.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/data/models/tag_config.dart';
import 'package:trackpoint/domain/tag_presence.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/dashboard/tag_presence_provider.dart';
import 'package:trackpoint/features/home/tag_providers.dart';

class DeviceSettingsScreen extends ConsumerStatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  ConsumerState<DeviceSettingsScreen> createState() =>
      _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends ConsumerState<DeviceSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _uploadIntervalController = TextEditingController();
  final _pollIntervalController = TextEditingController();
  final _buzzerMaxController = TextEditingController();
  final _offlineTimeoutController = TextEditingController();
  final _lowBatteryController = TextEditingController();

  String? _loadedDeviceId;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _uploadIntervalController.dispose();
    _pollIntervalController.dispose();
    _buzzerMaxController.dispose();
    _offlineTimeoutController.dispose();
    _lowBatteryController.dispose();
    super.dispose();
  }

  void _populateForm(DeviceSummary summary, TagSettings settings) {
    _loadedDeviceId = summary.deviceId;
    _nameController.text = summary.name;
    _uploadIntervalController.text = settings.uploadIntervalS.toString();
    _pollIntervalController.text = settings.pollIntervalS.toString();
    _buzzerMaxController.text = settings.buzzerMaxS.toString();
    _offlineTimeoutController.text = settings.offlineTimeoutS.toString();
    _lowBatteryController.text = settings.lowBatteryV.toStringAsFixed(2);
  }

  Future<void> _saveSettings(
    DeviceSummary summary,
    TagSettings currentSettings,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);

    final newName = _nameController.text.trim();
    final newUpload = int.parse(_uploadIntervalController.text.trim());
    final newPoll = int.parse(_pollIntervalController.text.trim());
    final newBuzzer = int.parse(_buzzerMaxController.text.trim());
    final newOffline = int.parse(_offlineTimeoutController.text.trim());
    final newLowBat = double.parse(_lowBatteryController.text.trim());

    final updatedSettings = TagSettings(
      uploadIntervalS: newUpload,
      pollIntervalS: newPoll,
      buzzerMaxS: newBuzzer,
      offlineTimeoutS: newOffline,
      lowBatteryV: newLowBat,
    );

    // 1. Rename device if name changed
    if (newName != summary.name) {
      final renameResult = await ref.read(deviceRepositoryProvider).renameDevice(
            uid: user.uid,
            deviceId: summary.deviceId,
            newName: newName,
          );
      if (renameResult.isFailure) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(renameResult.exceptionOrNull?.message ??
                  AppStrings.settingsSaveFailed),
              backgroundColor: AppTheme.statusBad,
            ),
          );
        }
        return;
      }
    }

    // 2. Update config settings
    final configResult = await ref.read(configRepositoryProvider).updateSettings(
          summary.deviceId,
          updatedSettings,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    configResult.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.settingsSaved),
            backgroundColor: AppTheme.statusOk,
          ),
        );
      },
      onFailure: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.message),
            backgroundColor: AppTheme.statusBad,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(userDevicesProvider).valueOrNull ?? [];
    final selectedId = ref.watch(selectedDeviceIdProvider);

    if (devices.isEmpty || selectedId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.deviceSettingsTitle)),
        body: const Center(child: Text(AppStrings.noTagSelected)),
      );
    }

    final summary = devices.firstWhere(
      (d) => d.deviceId == selectedId,
      orElse: () => devices.first,
    );

    final configAsync = ref.watch(tagConfigProvider(summary.deviceId));
    final presence = ref.watch(tagPresenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${summary.name} - ${AppStrings.deviceSettingsTitle}'),
        backgroundColor: AppTheme.darkBackground,
        scrolledUnderElevation: 0,
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (config) {
          final settings = config.settings;
          if (_loadedDeviceId != summary.deviceId) {
            _populateForm(summary, settings);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Device Information Card
                  _DeviceInfoCard(summary: summary, presence: presence),
                  const SizedBox(height: 16),

                  // Settings Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.deviceSettingsTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            AppStrings.settingsCheckInNotice,
                            style: TextStyle(
                              color: AppTheme.darkMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.deviceName,
                              prefixIcon: Icon(Icons.label_outline, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return AppStrings.invalidName;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Upload interval
                          TextFormField(
                            controller: _uploadIntervalController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: AppStrings.uploadIntervalLabel,
                              hintText: AppStrings.uploadIntervalHint,
                              prefixIcon: Icon(Icons.upload_outlined, size: 20),
                              suffixText: 's',
                            ),
                            validator: (v) {
                              final parsed = int.tryParse(v?.trim() ?? '');
                              if (parsed == null ||
                                  parsed < 5 ||
                                  parsed > 3600) {
                                return AppStrings.invalidUploadInterval;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Command poll interval
                          TextFormField(
                            controller: _pollIntervalController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: AppStrings.pollIntervalLabel,
                              hintText: AppStrings.pollIntervalHint,
                              prefixIcon: Icon(Icons.sync, size: 20),
                              suffixText: 's',
                            ),
                            validator: (v) {
                              final parsed = int.tryParse(v?.trim() ?? '');
                              if (parsed == null || parsed < 5 || parsed > 300) {
                                return AppStrings.invalidPollInterval;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Buzzer max duration
                          TextFormField(
                            controller: _buzzerMaxController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: AppStrings.buzzerMaxLabel,
                              hintText: AppStrings.buzzerMaxHint,
                              prefixIcon: Icon(Icons.volume_up_outlined, size: 20),
                              suffixText: 's',
                            ),
                            validator: (v) {
                              final parsed = int.tryParse(v?.trim() ?? '');
                              if (parsed == null || parsed < 5 || parsed > 600) {
                                return AppStrings.invalidBuzzerMax;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Offline timeout
                          TextFormField(
                            controller: _offlineTimeoutController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: AppStrings.offlineTimeoutLabel,
                              hintText: AppStrings.offlineTimeoutHint,
                              prefixIcon: Icon(Icons.timer_outlined, size: 20),
                              suffixText: 's',
                            ),
                            validator: (v) {
                              final parsed = int.tryParse(v?.trim() ?? '');
                              if (parsed == null ||
                                  parsed < 30 ||
                                  parsed > 86400) {
                                return AppStrings.invalidOfflineTimeout;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Low battery threshold
                          TextFormField(
                            controller: _lowBatteryController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: AppStrings.lowBatteryThresholdLabel,
                              hintText: AppStrings.lowBatteryThresholdHint,
                              prefixIcon:
                                  Icon(Icons.battery_alert_outlined, size: 20),
                              suffixText: 'V',
                            ),
                            validator: (v) {
                              final parsed = double.tryParse(v?.trim() ?? '');
                              if (parsed == null ||
                                  parsed < 3.0 ||
                                  parsed > 4.0) {
                                return AppStrings.invalidLowBattery;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save button
                  ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () => _saveSettings(summary, settings),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text(AppStrings.save),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard({
    required this.summary,
    required this.presence,
  });

  final DeviceSummary summary;
  final TagPresenceInfo presence;

  @override
  Widget build(BuildContext context) {
    final pairedAtText = summary.pairedAt > 0
        ? TimeUtils.formatDateTime(summary.pairedAt)
        : AppStrings.registeredNever;

    final lastCommText = presence.lastCommunicationMs != null
        ? TimeUtils.formatTimeAgo(presence.lastCommunicationMs)
        : AppStrings.never;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.deviceInfoTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _infoRow(AppStrings.deviceName, summary.name),
            _infoRow(AppStrings.deviceId, summary.deviceId),
            _infoRow('BLE ID', summary.bleId.isNotEmpty ? summary.bleId : '—'),
            _infoRow(AppStrings.firmwareVersion, summary.fw ?? '—'),
            _infoRow(AppStrings.registeredDate, pairedAtText),
            _infoRow(AppStrings.lastCommunication, lastCommText),
            _infoRow('Presence Status', presence.label),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.darkMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
