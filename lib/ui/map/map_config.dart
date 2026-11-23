import 'package:latlong2/latlong.dart';

/// Everything you might change about the map's tile source in one place.
class MapConfig {
  MapConfig._();

  /// OpenStreetMap's public tile server: free, no API key, no account.
  /// Its usage policy applies (https://operations.osmfoundation.org/policies/tiles/):
  /// fine for development and light use, not for heavy traffic. To switch
  /// provider, change this template plus [attribution] below.
  static const String tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// REQUIRED to be unique to your app. OSM blocks tile requests with a missing
  /// or generic identifier (including "com.example.*" ids), which is what
  /// produces the grey "Access blocked / 403" tiles. Use something that
  /// identifies *your* app and how to reach you. (Not used on web, where the
  /// browser controls the User-Agent.)
  static const String userAgentPackageName =
      'FloodWatch/1.0 +https://github.com/khadijashujaat/FloodWatch';

  /// Must be visible on the map (OSM's policy and licence require it).
  static const String attribution = '© OpenStreetMap contributors';

  /// Roughly centred on Pakistan; used until there are reports to fit to.
  static const LatLng defaultCenter = LatLng(30.4, 69.3);
  static const double defaultZoom = 5;
}
