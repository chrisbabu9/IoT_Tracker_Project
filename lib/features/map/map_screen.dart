import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/core/phone_location.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/core/time_utils.dart';
import 'package:trackpoint/core/units.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/core/geo.dart';
import 'package:trackpoint/features/dashboard/last_seen_near_service.dart';
import 'package:trackpoint/features/dashboard/stats_provider.dart';
import 'package:trackpoint/features/dashboard/tag_presence_provider.dart';
import 'package:trackpoint/features/home/tag_providers.dart';
import 'package:trackpoint/features/settings/app_settings_providers.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
// Local providers
// ---------------------------------------------------------------------------

/// Whether the map is in satellite tile mode.
final _satelliteModeProvider = StateProvider<bool>((_) => false);

/// Whether the map follows the tag automatically.
final _followTagProvider = StateProvider<bool>((_) => false);

/// Whether the 24 h path polyline is shown.
final _show24hPathProvider = StateProvider<bool>((_) => false);

/// Phone's current position, updated once when the map opens.
final _phonePositionProvider = StateProvider<LatLng?>((_) => null);

// ---------------------------------------------------------------------------
// Map Screen
// ---------------------------------------------------------------------------

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  /// Picked point from tap-to-pick.
  LatLng? _pickedPoint;
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  String? _latError;
  String? _lonError;

  @override
  void initState() {
    super.initState();
    _fetchPhonePosition();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _fetchPhonePosition() async {
    final pos = await PhoneLocation.current(requestPermission: true);
    if (pos != null && mounted) {
      ref.read(_phonePositionProvider.notifier).state =
          LatLng(pos.latitude, pos.longitude);
    }
  }

  LatLng? _tagLatLng(TagReport? report) {
    if (report == null || !report.hasCoordinates) return null;
    return LatLng(report.lat!, report.lon!);
  }

  void _centerOnTag(LatLng pos) {
    _mapController.move(pos, _mapController.camera.zoom);
  }

  void _validateAndPick() {
    final rawLat = double.tryParse(_latController.text.trim());
    final rawLon = double.tryParse(_lonController.text.trim());
    setState(() {
      _latError = rawLat == null || rawLat < -90 || rawLat > 90
          ? AppStrings.pickedPointInvalidLat
          : null;
      _lonError = rawLon == null || rawLon < -180 || rawLon > 180
          ? AppStrings.pickedPointInvalidLon
          : null;
    });
    if (_latError == null && _lonError == null) {
      setState(() => _pickedPoint = LatLng(rawLat!, rawLon!));
      _mapController.move(_pickedPoint!, _mapController.camera.zoom);
    }
  }

  Future<void> _openPickedInMaps() async {
    if (_pickedPoint == null) return;
    final lat = _pickedPoint!.latitude;
    final lon = _pickedPoint!.longitude;
    final uri = Uri.parse('geo:$lat,$lon?q=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final fallback = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lon');
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(clockTickProvider);
    final reportAsync = ref.watch(selectedDeviceReportProvider);
    final phonePos = ref.watch(_phonePositionProvider);
    final isSatellite = ref.watch(_satelliteModeProvider);
    final followTag = ref.watch(_followTagProvider);
    final show24h = ref.watch(_show24hPathProvider);
    final path24hAsync = show24h ? ref.watch(reports24hProvider) : null;
    final lastSeenNear = ref.watch(selectedDeviceLastSeenNearProvider).value;

    final report = reportAsync.value;
    final tagPos = _tagLatLng(report);

    // Auto-follow
    if (followTag && tagPos != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(tagPos, _mapController.camera.zoom);
      });
    }

    final tileUrl = isSatellite
        ? AppConfig.esriSatelliteTileUrlTemplate
        : ref.watch(activeTileUrlProvider);
    final attribution =
        isSatellite ? AppConfig.esriAttribution : AppConfig.osmAttribution;

    final initialCenter = tagPos ?? phonePos ?? const LatLng(0, 0);

    // Build path polyline points
    List<LatLng> pathPoints = [];
    if (show24h && path24hAsync != null) {
      final reports = path24hAsync.value ?? [];
      final sorted = [...reports]..sort((a, b) => a.srv.compareTo(b.srv));
      pathPoints = sorted
          .where((r) => r.hasCoordinates)
          .map((r) => LatLng(r.lat!, r.lon!))
          .toList();
    }

    // Stale-fix detection
    final isStale = report != null &&
        (report.fix == 0 ||
            (DateTime.now().millisecondsSinceEpoch - report.srv) >
                15 * 60 * 1000);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.mapTitle),
        backgroundColor: AppTheme.darkBackground,
        scrolledUnderElevation: 0,
        actions: [
          // Road / Satellite toggle
          IconButton(
            tooltip: isSatellite ? AppStrings.roadMap : AppStrings.satellite,
            icon: Icon(isSatellite ? Icons.map_outlined : Icons.satellite_alt),
            onPressed: () =>
                ref.read(_satelliteModeProvider.notifier).state = !isSatellite,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stale-fix banner
          if (isStale)
            Container(
              width: double.infinity,
              color: AppTheme.statusWarn.withValues(alpha: 0.85),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                AppStrings.staleFixBanner.replaceFirst(
                  '{age}',
                  TimeUtils.formatTimeAgo(report.srv),
                ),
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: tagPos != null ? 15 : 2,
                onTap: (_, latlng) {
                  setState(() {
                    _pickedPoint = latlng;
                    _latController.text = latlng.latitude.toStringAsFixed(6);
                    _lonController.text = latlng.longitude.toStringAsFixed(6);
                    _latError = null;
                    _lonError = null;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: AppConfig.userAgentPackageName,
                ),
                // 24 h path polyline
                if (pathPoints.length > 1)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: pathPoints,
                      strokeWidth: 3,
                      color: AppTheme.accentBlue.withValues(alpha: 0.8),
                    ),
                  ]),
                // Markers
                MarkerLayer(markers: [
                  // Phone position marker
                  if (phonePos != null)
                    Marker(
                      point: phonePos,
                      width: 36,
                      height: 36,
                      child: const Icon(Icons.person_pin_circle,
                          color: AppTheme.accentCyan, size: 32),
                    ),
                  // Picked point marker
                  if (_pickedPoint != null)
                    Marker(
                      point: _pickedPoint!,
                      width: 36,
                      height: 36,
                      child: const Icon(Icons.place,
                          color: AppTheme.accentPurple, size: 32),
                    ),
                  // Last-seen-near marker (shown only when no current tag coords)
                  if (lastSeenNear != null && tagPos == null)
                    Marker(
                      point: LatLng(lastSeenNear.lat, lastSeenNear.lon),
                      width: 44,
                      height: 44,
                      child: const Tooltip(
                        message: AppStrings.lastSeenNearLabel,
                        child: Icon(Icons.history_toggle_off,
                            color: AppTheme.statusWarn, size: 36),
                      ),
                    ),
                  // Tag marker
                  if (tagPos != null)
                    Marker(
                      point: tagPos,
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.location_on,
                        color:
                            isStale ? AppTheme.statusMuted : AppTheme.statusBad,
                        size: 40,
                        shadows: const [
                          Shadow(blurRadius: 6, color: Colors.black54)
                        ],
                      ),
                    ),
                ]),
                // Accuracy circle
                if (tagPos != null && report?.acc != null && !isStale)
                  CircleLayer(circles: [
                    CircleMarker(
                      point: tagPos,
                      radius: report!.acc!.toDouble(),
                      useRadiusInMeter: true,
                      color: AppTheme.accentBlue.withValues(alpha: 0.12),
                      borderColor: AppTheme.accentBlue.withValues(alpha: 0.5),
                      borderStrokeWidth: 1.5,
                    ),
                  ]),
                RichAttributionWidget(attributions: [
                  TextSourceAttribution(attribution),
                ]),
              ],
            ),
          ),
          // Phone distance to tag
          if (tagPos != null && phonePos != null) ...[
            const SizedBox(height: 4),
            _PhoneDistanceBar(
                tagPos: tagPos,
                phonePos: phonePos,
                imperial: ref.watch(unitSystemProvider) == UnitSystem.imperial),
          ],
          // Controls panel
          _MapControlsPanel(
            tagPos: tagPos,
            show24h: show24h,
            followTag: followTag,
            pickedPoint: _pickedPoint,
            latController: _latController,
            lonController: _lonController,
            latError: _latError,
            lonError: _lonError,
            onCenterTag: tagPos != null ? () => _centerOnTag(tagPos) : null,
            onFollowToggle: () =>
                ref.read(_followTagProvider.notifier).state = !followTag,
            onPathToggle: () =>
                ref.read(_show24hPathProvider.notifier).state = !show24h,
            onValidatePick: _validateAndPick,
            onOpenInMaps: _openPickedInMaps,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Controls panel below the map
// ---------------------------------------------------------------------------

class _MapControlsPanel extends StatelessWidget {
  const _MapControlsPanel({
    required this.tagPos,
    required this.show24h,
    required this.followTag,
    required this.pickedPoint,
    required this.latController,
    required this.lonController,
    required this.latError,
    required this.lonError,
    required this.onCenterTag,
    required this.onFollowToggle,
    required this.onPathToggle,
    required this.onValidatePick,
    required this.onOpenInMaps,
  });

  final LatLng? tagPos;
  final bool show24h;
  final bool followTag;
  final LatLng? pickedPoint;
  final TextEditingController latController;
  final TextEditingController lonController;
  final String? latError;
  final String? lonError;
  final VoidCallback? onCenterTag;
  final VoidCallback onFollowToggle;
  final VoidCallback onPathToggle;
  final VoidCallback onValidatePick;
  final VoidCallback onOpenInMaps;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.darkSidebar,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Button row
          Row(
            children: [
              Expanded(
                child: _MapBtn(
                  icon: Icons.my_location,
                  label: AppStrings.centerOnTag,
                  onPressed: onCenterTag,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _MapBtn(
                  icon: followTag ? Icons.gps_fixed : Icons.gps_not_fixed,
                  label: AppStrings.followTag,
                  active: followTag,
                  onPressed: onFollowToggle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _MapBtn(
                  icon: Icons.route,
                  label: AppStrings.showPath24h,
                  active: show24h,
                  onPressed: onPathToggle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Tap-to-pick fields
          const Text(
            AppStrings.tapToPickPoint,
            style: TextStyle(color: AppTheme.darkMuted, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: latController,
                  decoration: InputDecoration(
                    labelText: AppStrings.pickedPointLat,
                    errorText: latError,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: lonController,
                  decoration: InputDecoration(
                    labelText: AppStrings.pickedPointLon,
                    errorText: lonError,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                ),
              ),
              const SizedBox(width: 6),
              Column(
                children: [
                  IconButton(
                    tooltip: 'Go',
                    icon: const Icon(Icons.search, size: 20),
                    onPressed: onValidatePick,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  if (pickedPoint != null)
                    IconButton(
                      tooltip: AppStrings.openInMaps,
                      icon: const Icon(Icons.open_in_new, size: 20),
                      onPressed: onOpenInMaps,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhoneDistanceBar extends StatelessWidget {
  const _PhoneDistanceBar(
      {required this.tagPos, required this.phonePos, this.imperial = false});

  final LatLng tagPos;
  final LatLng phonePos;
  final bool imperial;

  @override
  Widget build(BuildContext context) {
    final distM = GeoUtils.haversineDistance(
      phonePos.latitude,
      phonePos.longitude,
      tagPos.latitude,
      tagPos.longitude,
    );
    final label = Units.distance(distM, imperial: imperial);
    return Container(
      color: AppTheme.darkSidebar,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.straighten, size: 14, color: AppTheme.darkMuted),
          const SizedBox(width: 6),
          Text(
            '${AppStrings.phoneDistance}: $label',
            style: const TextStyle(color: AppTheme.darkMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MapBtn extends StatelessWidget {
  const _MapBtn({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: active ? AppTheme.accentBlue : AppTheme.darkLine,
          ),
          foregroundColor: active ? AppTheme.accentBlue : AppTheme.darkText,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}
