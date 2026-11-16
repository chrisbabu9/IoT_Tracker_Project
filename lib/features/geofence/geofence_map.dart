import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/core/theme.dart';

/// Map for the geofence editor: the circle, its centre and the tag.
class GeofenceEditorMap extends StatelessWidget {
  const GeofenceEditorMap({
    super.key,
    required this.controller,
    required this.onReady,
    required this.onTap,
    required this.radiusM,
    this.center,
    this.tagPos,
    this.tileUrl,
  });

  final MapController controller;
  final VoidCallback onReady;
  final void Function(LatLng point) onTap;
  final double radiusM;
  final LatLng? center;
  final LatLng? tagPos;
  final String? tileUrl;

  @override
  Widget build(BuildContext context) {
    final start = center ?? tagPos;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: start ?? const LatLng(0, 0),
          initialZoom: start != null ? 15 : 2,
          onMapReady: onReady,
          onTap: (_, point) => onTap(point),
        ),
        children: [
          TileLayer(
            urlTemplate: tileUrl ?? AppConfig.osmTileUrlTemplate,
            userAgentPackageName: AppConfig.userAgentPackageName,
          ),
          if (center != null)
            CircleLayer(circles: [
              CircleMarker(
                point: center!,
                radius: radiusM,
                useRadiusInMeter: true,
                color: AppTheme.accentBlue.withValues(alpha: 0.15),
                borderColor: AppTheme.accentBlue,
                borderStrokeWidth: 2,
              ),
            ]),
          MarkerLayer(markers: [
            if (center != null)
              Marker(
                point: center!,
                width: 36,
                height: 36,
                child: const Icon(Icons.flag,
                    color: AppTheme.accentPurple, size: 30),
              ),
            if (tagPos != null)
              Marker(
                point: tagPos!,
                width: 44,
                height: 44,
                child: const Icon(Icons.location_on,
                    color: AppTheme.statusBad, size: 40),
              ),
          ]),
          RichAttributionWidget(attributions: [
            TextSourceAttribution(AppConfig.osmAttribution),
          ]),
        ],
      ),
    );
  }
}
