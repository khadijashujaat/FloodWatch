import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import 'sync_worker.dart';

/// Equivalent of the WorkManager enqueue calls in the Kotlin `MainActivity`
/// (periodic) and `ReportFormViewModel` (one-time after submit).
///
/// Android only. On iOS and web there is no equivalent background job here;
/// those platforms sync through `ForegroundSync` while the app is open.
/// (`!kIsWeb` matters: on Chrome for Android `defaultTargetPlatform` reports
/// android.)
class SyncScheduler {
  SyncScheduler._();

  static const String _periodicName = 'report_sync';

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // Only run when the device has a network connection.
  static Constraints get _constraints =>
      Constraints(networkType: NetworkType.connected);

  static Future<void> initialize() async {
    if (!_supported) return;
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _periodicName,
      syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: _constraints,
    );
  }

  /// Queue a sync as soon as connectivity allows (call after saving a report).
  static Future<void> syncSoon() async {
    if (!_supported) return;
    await Workmanager().registerOneOffTask(
      'sync_now_${DateTime.now().millisecondsSinceEpoch}',
      syncTaskName,
      constraints: _constraints,
    );
  }
}
