import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/config.dart';

enum UnitSystem { metric, imperial }

/// Unit system preference: Metric (km, km/h) vs Imperial (mi, mph)
final unitSystemProvider = StateProvider<UnitSystem>((ref) => UnitSystem.metric);

/// Custom OSM Tile URL template override for testing and alternative map providers.
final customTileUrlProvider = StateProvider<String?>((ref) => null);

/// Active tile URL template used across maps.
final activeTileUrlProvider = Provider<String>((ref) {
  final override = ref.watch(customTileUrlProvider);
  if (override != null && override.trim().isNotEmpty) {
    return override.trim();
  }
  return AppConfig.osmTileUrlTemplate;
});
