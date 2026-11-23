import 'remote/firestore_report_sync.dart';
import 'report_dao.dart';

/// The body of the Kotlin `SyncWorker.doWork()`: upload every unsynced report,
/// marking each one synced as soon as it succeeds. If an upload throws, the
/// reports already uploaded stay marked and the caller retries the rest later.
class SyncService {
  SyncService(this._dao, this._remote);

  final ReportDao _dao;
  final FirestoreReportSync _remote;

  Future<int> syncPending() async {
    final pending = await _dao.getUnsynced();
    var uploaded = 0;
    for (final report in pending) {
      await _remote.uploadReport(report);
      await _dao.markSynced(report.id!);
      uploaded++;
    }
    return uploaded;
  }
}
