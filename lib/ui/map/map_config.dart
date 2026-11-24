import 'package:latlong2/latlong.dart';

/// Everything you might change about the map's tile source in one place.
class MapConfig {
  MapConfig._();

  /// Stadia Maps Alidade Smooth tiles. Override with --dart-define=TILE_URL=...
  static const String tileUrlTemplate = String.fromEnvironment(
    'TILE_URL',
    defaultValue:
        'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png',
  );

  /// Used by OSM tile requests; the browser controls the User-Agent on web.
  static const String userAgentPackageName =
      'FloodWatch/1.0 +https://github.com/khadijashujaat/FloodWatch';

  /// Must be visible on the map and match the selected tile provider.
  static const String attribution = String.fromEnvironment(
    'TILE_ATTRIBUTION',
    defaultValue: '© Stadia Maps © OpenMapTiles © OpenStreetMap',
  );

  /// Roughly centred on Pakistan; used until there are reports to fit to.
  static const LatLng defaultCenter = LatLng(30.4, 69.3);
  static const double defaultZoom = 5;
}
