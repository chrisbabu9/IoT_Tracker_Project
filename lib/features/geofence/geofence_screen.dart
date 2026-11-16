import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/data/models/geofence.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/geofence/geofence_map.dart';
import 'package:trackpoint/features/geofence/geofence_providers.dart';
import 'package:trackpoint/features/settings/app_settings_providers.dart';
import 'package:trackpoint/features/home/tag_providers.dart';

class GeofenceScreen extends ConsumerStatefulWidget {
  const GeofenceScreen({super.key});

  @override
  ConsumerState<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends ConsumerState<GeofenceScreen> {
  final _mapController = MapController();
  LatLng? _center;
  double _radiusM = AppConfig.defaultGeofenceRadiusM;
  bool _enabled = false;
  bool _saving = false;
  bool _mapReady = false;
  String? _loadedFor; // deviceId whose saved fence was applied

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _save(String deviceId) async {
    if (_center == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tap the map to set the geofence centre.')),
      );
      return;
    }

    setState(() => _saving = true);

    final fence = Geofence(
      enabled: _enabled,
      lat: _center!.latitude,
      lon: _center!.longitude,
      radiusM: _radiusM,
    );

    final result = await ref
        .read(configRepositoryProvider)
        .updateGeofence(deviceId, fence);

    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geofence saved')),
        );
        ref.invalidate(tagConfigProvider(deviceId));
      },
      onFailure: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceId = ref.watch(selectedDeviceIdProvider);

    if (deviceId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Geofence')),
        body: const Center(child: Text('No tag selected')),
      );
    }

    // Apply the saved geofence once per tag, and only after the config has
    // actually arrived (plain field writes: no setState during build).
    final cfg = ref.watch(tagConfigProvider(deviceId));
    if (_loadedFor != deviceId && cfg.hasValue) {
      _loadedFor = deviceId;
      final fence = cfg.value?.geofence;
      if (fence != null) {
        _enabled = fence.enabled;
        _radiusM = fence.radiusM;
        _center = LatLng(fence.lat, fence.lon);
      }
    }

    final report = ref.watch(latestReportProvider(deviceId)).valueOrNull;
    final tagPos = (report?.lat != null && report?.lon != null)
        ? LatLng(report!.lat!, report.lon!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(deviceId),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: !ref.watch(geofenceMapEnabledProvider)
                ? const SizedBox.shrink()
                : GeofenceEditorMap(
              tileUrl: ref.watch(activeTileUrlProvider),
              controller: _mapController,
              onReady: () {
                if (!_mapReady) {
                  _mapReady = true;
                  final start = _center ?? tagPos;
                  if (start != null) {
                    _mapController.move(start, 15);
                  }
                }
              },
              onTap: (point) => setState(() => _center = point),
              radiusM: _radiusM,
              center: _center,
              tagPos: tagPos,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Geofence enabled'),
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                  Text(
                    'Radius: ${_radiusM.round()} m',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Slider(
                    value: _radiusM.clamp(AppConfig.minGeofenceRadiusM,
                        AppConfig.maxGeofenceRadiusM),
                    min: AppConfig.minGeofenceRadiusM,
                    max: AppConfig.maxGeofenceRadiusM,
                    divisions: ((AppConfig.maxGeofenceRadiusM -
                                AppConfig.minGeofenceRadiusM) /
                            AppConfig.geofenceStepM)
                        .round(),
                    label: '${_radiusM.round()} m',
                    onChanged: (v) => setState(() => _radiusM = v),
                  ),
                  Text(
                    _center == null
                        ? 'Tap the map to place the centre'
                        : 'Centre: ${_center!.latitude.toStringAsFixed(5)}, ${_center!.longitude.toStringAsFixed(5)}',
                    style: Theme.of(context).textTheme.bodySmall,
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
