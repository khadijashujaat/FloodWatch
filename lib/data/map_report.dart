import 'report.dart';

/// One pin on the map. Built either from a report stored on this device or
/// from a document in the shared Firestore collection, so both can be drawn
/// and de-duplicated the same way. Pure Dart (no Flutter/Firebase imports).
class MapReport {
  const MapReport({
    required this.id,
    required this.type,
    this.waterLevelSeverity,
    required this.notes,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.pendingUpload,
  });

  /// Local reports use their `clientId`, which is also the Firestore document
  /// id for reports uploaded by this app, so the two sides line up.
  final String id;
  final String type;
  final String? waterLevelSeverity;
  final String notes;
  final double latitude;
  final double longitude;
  final int timestamp;

  /// True only for reports that exist on this device and haven't reached
  /// Firestore yet.
  final bool pendingUpload;

  /// (0, 0) is the "no GPS fix" placeholder the app stores, and plotting it
  /// would put a pin in the Atlantic Ocean, so it counts as "no location".
  bool get hasLocation =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180 &&
      !(latitude == 0 && longitude == 0);

  factory MapReport.fromLocal(Report r) => MapReport(
    id: r.clientId,
    type: r.type,
    waterLevelSeverity: r.waterLevelSeverity,
    notes: r.notes,
    latitude: r.latitude,
    longitude: r.longitude,
    timestamp: r.timestamp,
    pendingUpload: !r.synced,
  );

  /// Parses a Firestore document defensively (older documents may lack
  /// fields). Returns null if it has no usable coordinates.
  static MapReport? fromRemote(String id, Map<String, Object?> data) {
    final lat = data['latitude'];
    final lng = data['longitude'];
    if (lat is! num || lng is! num) return null;
    final ts = data['timestamp'];
    return MapReport(
      id: id,
      type: _string(data['type']) ?? 'Report',
      waterLevelSeverity: _string(data['waterLevelSeverity']),
      notes: _string(data['notes']) ?? '',
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      timestamp: ts is num ? ts.toInt() : 0,
      pendingUpload: false,
    );
  }

  static String? _string(Object? value) => value is String ? value : null;
}

class MapMergeResult {
  const MapMergeResult({
    required this.plottable,
    required this.withoutLocation,
  });

  /// Newest first.
  final List<MapReport> plottable;

  /// Reports that exist but can't be drawn because they have no GPS location.
  final int withoutLocation;
}

/// Combines this device's reports with the shared ones. A report present in
/// both (same id) is shown once, using the local copy. Reports without a
/// usable location are counted, not plotted.
MapMergeResult mergeForMap({
  required List<MapReport> local,
  required List<MapReport> remote,
}) {
  final byId = <String, MapReport>{};
  for (final report in remote) {
    byId[report.id] = report;
  }
  for (final report in local) {
    byId[report.id] = report;
  }
  final all = byId.values.toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  final plottable = all.where((r) => r.hasLocation).toList();
  return MapMergeResult(
    plottable: plottable,
    withoutLocation: all.length - plottable.length,
  );
}
