import 'package:flutter_test/flutter_test.dart';
import 'package:floodwatch/data/map_report.dart';
import 'package:floodwatch/data/report.dart';

MapReport _pin(
  String id,
  double lat,
  double lng, {
  int ts = 1,
  bool pending = false,
}) => MapReport(
  id: id,
  type: 'Water level reading',
  notes: '',
  latitude: lat,
  longitude: lng,
  timestamp: ts,
  pendingUpload: pending,
);

void main() {
  group('MapReport.fromRemote', () {
    test('reads a normal Firestore document (ints or doubles)', () {
      final r = MapReport.fromRemote('abc', {
        'type': 'Drainage blockage',
        'waterLevelSeverity': null,
        'notes': 'local witness',
        'latitude': 34, // Firestore may hand back an int
        'longitude': 71.5249,
        'timestamp': 1789289000000,
      })!;
      expect(r.id, 'abc');
      expect(r.latitude, 34.0);
      expect(r.waterLevelSeverity, isNull);
      expect(r.pendingUpload, isFalse);
      expect(r.hasLocation, isTrue);
    });

    test('returns null when coordinates are missing or the wrong type', () {
      expect(MapReport.fromRemote('x', {'type': 'a'}), isNull);
      expect(
        MapReport.fromRemote('x', {'latitude': 'n/a', 'longitude': 1}),
        isNull,
      );
    });

    test('tolerates missing optional fields', () {
      final r = MapReport.fromRemote('x', {'latitude': 1, 'longitude': 2})!;
      expect(r.type, 'Report');
      expect(r.notes, '');
      expect(r.timestamp, 0);
    });
  });

  group('hasLocation', () {
    test('(0,0) and out-of-range values are not plottable', () {
      expect(_pin('a', 0, 0).hasLocation, isFalse);
      expect(_pin('a', 91, 10).hasLocation, isFalse);
      expect(_pin('a', 10, 181).hasLocation, isFalse);
      expect(_pin('a', double.nan, 10).hasLocation, isFalse);
      expect(_pin('a', 0, 10).hasLocation, isTrue); // on the equator is fine
    });
  });

  group('mergeForMap', () {
    test('shows a report that exists locally and remotely only once, '
        'preferring the local copy', () {
      final result = mergeForMap(
        local: [_pin('same', 34, 71, pending: false)],
        remote: [_pin('same', 99, 99)],
      );
      expect(result.plottable.length, 1);
      expect(result.plottable.single.latitude, 34);
    });

    test('keeps local pending reports and remote-only reports', () {
      final result = mergeForMap(
        local: [_pin('mine', 34, 71, pending: true)],
        remote: [_pin('theirs', 35, 72)],
      );
      expect(result.plottable.map((r) => r.id).toSet(), {'mine', 'theirs'});
      expect(
        result.plottable.firstWhere((r) => r.id == 'mine').pendingUpload,
        isTrue,
      );
    });

    test('counts reports without a location instead of plotting them', () {
      final result = mergeForMap(
        local: [_pin('nogps', 0, 0)],
        remote: [_pin('ok', 34, 71)],
      );
      expect(result.plottable.length, 1);
      expect(result.withoutLocation, 1);
    });

    test('sorts newest first', () {
      final result = mergeForMap(
        local: const [],
        remote: [_pin('old', 1, 1, ts: 5), _pin('new', 2, 2, ts: 50)],
      );
      expect(result.plottable.first.id, 'new');
    });

    test('a local Report maps to a pin keyed by its clientId', () {
      const report = Report(
        clientId: 'cid',
        type: 'Rainfall observation',
        notes: '',
        latitude: 34,
        longitude: 71,
        timestamp: 1,
      );
      final pin = MapReport.fromLocal(report);
      expect(pin.id, 'cid');
      expect(pin.pendingUpload, isTrue); // not synced yet
    });
  });
}
