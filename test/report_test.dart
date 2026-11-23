import 'package:flutter_test/flutter_test.dart';
import 'package:floodwatch/data/report.dart';
import 'package:floodwatch/util/format.dart';

void main() {
  group('Report', () {
    const original = Report(
      id: 7,
      clientId: 'abc123',
      type: 'Water level reading',
      waterLevelSeverity: 'Knee to waist deep',
      notes: 'local witness',
      latitude: 34.0151,
      longitude: 71.5249,
      timestamp: 1789289000000,
      synced: true,
    );

    test('survives a toMap/fromMap round trip', () {
      final copy = Report.fromMap(original.toMap());
      expect(copy.id, 7);
      expect(copy.clientId, 'abc123');
      expect(copy.type, original.type);
      expect(copy.waterLevelSeverity, original.waterLevelSeverity);
      expect(copy.notes, original.notes);
      expect(copy.latitude, original.latitude);
      expect(copy.longitude, original.longitude);
      expect(copy.timestamp, original.timestamp);
      expect(copy.synced, true);
    });

    test('keeps severity null for non water-level reports', () {
      const report = Report(
        clientId: 'x',
        type: 'Drainage blockage',
        notes: '',
        latitude: 0,
        longitude: 0,
        timestamp: 1,
      );
      expect(Report.fromMap(report.toMap()).waterLevelSeverity, isNull);
      expect(report.toMap().containsKey('id'), isFalse);
      expect(report.toMap()['synced'], 0);
    });

    test('remote map matches the Android RemoteReport fields only', () {
      expect(original.toRemoteMap().keys.toSet(), {
        'type',
        'waterLevelSeverity',
        'notes',
        'latitude',
        'longitude',
        'timestamp',
      });
    });

    test('client ids are 32 hex chars and unique', () {
      final ids = {for (var i = 0; i < 200; i++) Report.newClientId()};
      expect(ids.length, 200);
      expect(ids.every((id) => RegExp(r'^[0-9a-f]{32}$').hasMatch(id)), isTrue);
    });
  });

  test('formatTimestamp uses "dd MMM yyyy, HH:mm"', () {
    final ms = DateTime(2026, 9, 13, 7, 55).millisecondsSinceEpoch;
    expect(formatTimestamp(ms), '13 Sep 2026, 07:55');
  });
}
