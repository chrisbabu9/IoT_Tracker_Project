import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/models/tag_report.dart';

/// Path of a day (or the last 24 h) with start/end, a focused row and the
/// replay position.
class HistoryPathMap extends StatelessWidget {
  const HistoryPathMap({
    super.key,
    required this.points,
    required this.controller,
    required this.onReady,
    this.focused,
    this.replay,
    this.tileUrl,
  });

  /// Oldest first, all with coordinates.
  final List<TagReport> points;
  final MapController controller;
  final VoidCallback onReady;
  final TagReport? focused;
  final TagReport? replay;
  final String? tileUrl;

  static LatLng toLatLng(TagReport r) => LatLng(r.lat!, r.lon!);

  @override
  Widget build(BuildContext context) {
    final latLngs = points.map(toLatLng).toList();
    final center = latLngs.isNotEmpty ? latLngs.last : const LatLng(0, 0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: controller,
        options: MapOptions(
          initialCenter: center,
          initialZoom: latLngs.isEmpty ? 2 : 15,
          onMapReady: onReady,
        ),
        children: [
          TileLayer(
            urlTemplate: tileUrl ?? AppConfig.osmTileUrlTemplate,
            userAgentPackageName: AppConfig.userAgentPackageName,
          ),
          if (latLngs.length > 1)
            PolylineLayer(polylines: [
              Polyline(
                points: latLngs,
                strokeWidth: 3,
                color: AppTheme.accentBlue.withValues(alpha: 0.8),
              ),
            ]),
          MarkerLayer(markers: [
            if (latLngs.isNotEmpty)
              Marker(
                point: latLngs.first,
                width: 28,
                height: 28,
                child: const Icon(Icons.trip_origin,
                    color: AppTheme.statusOk, size: 22),
              ),
            if (latLngs.length > 1)
              Marker(
                point: latLngs.last,
                width: 28,
                height: 28,
                child: const Icon(Icons.flag,
                    color: AppTheme.statusBad, size: 24),
              ),
            if (focused != null && focused!.hasCoordinates)
              Marker(
                point: toLatLng(focused!),
                width: 36,
                height: 36,
                child: const Icon(Icons.place,
                    color: AppTheme.accentPurple, size: 32),
              ),
            if (replay != null && replay!.hasCoordinates)
              Marker(
                point: toLatLng(replay!),
                width: 30,
                height: 30,
                child: const Icon(Icons.circle,
                    color: AppTheme.accentCyan, size: 22),
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
