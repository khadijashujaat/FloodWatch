import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../firebase_bootstrap.dart';
import '../app_database.dart';
import '../report_dao.dart';
import '../sync_service.dart';
import 'firestore_report_sync.dart';

const String syncTaskName = 'syncReports';

/// Equivalent of the Kotlin `SyncWorker`.
///
/// WorkManager runs this in a separate Dart isolate, possibly long after the
/// app process was killed, so nothing is shared with the UI: Firebase and the
/// database are initialised from scratch here (the same reason the Kotlin
/// worker rebuilt its own Room instance).
///
/// Returning `false` asks WorkManager to retry later (Kotlin: `Result.retry()`).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await ensureFirebaseInitialized();
      final service = SyncService(
        ReportDao(AppDatabase.instance),
        FirestoreReportSync(),
      );
      final uploaded = await service.syncPending();
      debugPrint('FloodWatch sync: uploaded $uploaded report(s)');
      return true;
    } catch (error, stackTrace) {
      debugPrint('FloodWatch sync failed, will retry: $error\n$stackTrace');
      return false;
    }
  });
}
