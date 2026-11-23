import 'dart:math';

/// Equivalent of the Kotlin `ReportEntity` (Room).
///
/// One addition: [clientId]. It is generated on the device when the report is
/// created and used as the Firestore document id, so uploading the same report
/// twice (e.g. two sync jobs racing) overwrites one document instead of
/// creating duplicates.
class Report {
  const Report({
    this.id,
    required this.clientId,
    required this.type,
    this.waterLevelSeverity,
    required this.notes,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.synced = false,
  });

  final int? id;
  final String clientId;
  final String type;

  /// Only set when [type] is the water-level type; null otherwise.
  final String? waterLevelSeverity;
  final String notes;
  final double latitude;
  final double longitude;

  /// Milliseconds since epoch, same as `System.currentTimeMillis()` in Kotlin.
  final int timestamp;

  /// Local-only bookkeeping flag; never sent to Firestore.
  final bool synced;

  static String newClientId() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'client_id': clientId,
    'type': type,
    'water_level_severity': waterLevelSeverity,
    'notes': notes,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp,
    'synced': synced ? 1 : 0,
  };

  factory Report.fromMap(Map<String, Object?> map) => Report(
    id: map['id'] as int?,
    clientId: map['client_id'] as String,
    type: map['type'] as String,
    waterLevelSeverity: map['water_level_severity'] as String?,
    notes: map['notes'] as String,
    latitude: (map['latitude'] as num).toDouble(),
    longitude: (map['longitude'] as num).toDouble(),
    timestamp: map['timestamp'] as int,
    synced: (map['synced'] as int) == 1,
  );

  /// Same fields as the Kotlin `RemoteReport` data class, so documents written
  /// by the Flutter app and the Android app look identical in Firestore.
  Map<String, Object?> toRemoteMap() => {
    'type': type,
    'waterLevelSeverity': waterLevelSeverity,
    'notes': notes,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp,
  };
}
