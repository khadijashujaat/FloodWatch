import 'package:cloud_firestore/cloud_firestore.dart';

import '../map_report.dart';

/// Reads the shared `reports` collection (everyone's reports) for the map.
/// On mobile, Firestore serves cached results while offline.
class FirestoreReportReader {
  FirestoreReportReader({this._firestore});

  FirebaseFirestore? _firestore;
  FirebaseFirestore get _db => _firestore ??= FirebaseFirestore.instance;

  /// Newest [limit] reports, live. Documents without usable coordinates are
  /// skipped.
  Stream<List<MapReport>> watchReports({int limit = 500}) {
    return _db
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final reports = <MapReport>[];
          for (final doc in snapshot.docs) {
            final report = MapReport.fromRemote(doc.id, doc.data());
            if (report != null) reports.add(report);
          }
          return reports;
        });
  }
}
