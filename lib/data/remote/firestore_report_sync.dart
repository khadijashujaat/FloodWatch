import 'package:cloud_firestore/cloud_firestore.dart';

import '../report.dart';

/// Equivalent of the Kotlin `FirestoreReportSync`.
///
/// - `doc(clientId).set(...)` instead of `.add(...)` makes the upload
///   idempotent: retrying or racing syncs rewrite the same document.
/// - A Firestore write future only completes once the server acknowledges it,
///   so while offline it would hang forever. The timeout turns that into a
///   normal failure; the report simply stays "unsynced" and is retried.
/// - The Firestore instance is created lazily so a misconfigured Firebase
///   can't crash the app at start-up.
class FirestoreReportSync {
  FirestoreReportSync({this._firestore});

  static const Duration _writeTimeout = Duration(seconds: 15);

  FirebaseFirestore? _firestore;
  FirebaseFirestore get _db => _firestore ??= FirebaseFirestore.instance;

  Future<void> uploadReport(Report report) {
    return _db
        .collection('reports')
        .doc(report.clientId)
        .set(report.toRemoteMap())
        .timeout(_writeTimeout);
  }
}
