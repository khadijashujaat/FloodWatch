import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_database.dart';
import 'data/foreground_sync.dart';
import 'data/remote/firestore_report_reader.dart';
import 'data/remote/firestore_report_sync.dart';
import 'data/remote/sync_scheduler.dart';
import 'data/report_dao.dart';
import 'data/sync_service.dart';
import 'firebase_bootstrap.dart';
import 'ui/home_shell.dart';
import 'ui/map/map_view_model.dart';
import 'ui/report_form/report_form_view_model.dart';
import 'ui/report_list/report_list_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The app is local-first: a misconfigured Firebase or scheduler must not
  // stop people from saving reports, so failures here are logged, not fatal.
  try {
    await ensureFirebaseInitialized();
  } catch (error) {
    debugPrint('Firebase init failed (reports will stay local): $error');
  }
  try {
    await SyncScheduler.initialize(); // Android background sync only
  } catch (error) {
    debugPrint('Sync scheduler init failed: $error');
  }

  // Equivalent of the manual wiring in the Kotlin MainActivity.
  final dao = ReportDao(AppDatabase.instance);
  final listViewModel = ReportListViewModel(dao);
  final foregroundSync = ForegroundSync(
    dao,
    SyncService(dao, FirestoreReportSync()),
    onSynced: listViewModel.load,
  );
  final formViewModel = ReportFormViewModel(
    dao,
    onSaved: () {
      listViewModel.load();
      unawaited(foregroundSync.syncNow());
    },
  );
  final mapViewModel = MapViewModel(listViewModel, FirestoreReportReader());

  unawaited(listViewModel.load());
  foregroundSync.start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ReportListViewModel>.value(value: listViewModel),
        ChangeNotifierProvider<ReportFormViewModel>.value(value: formViewModel),
        ChangeNotifierProvider<MapViewModel>.value(value: mapViewModel),
        Provider<ForegroundSync>.value(value: foregroundSync),
      ],
      child: const FloodWatchApp(),
    ),
  );
}

class FloodWatchApp extends StatelessWidget {
  const FloodWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FloodWatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      ),
      home: const HomeShell(),
    );
  }
}
