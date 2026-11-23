import 'dart:async';

import 'package:flutter/foundation.dart';

import 'report_dao.dart';
import 'sync_service.dart';

/// Syncs unsent reports while the app is open. This is the only sync on iOS
/// and web (there is no WorkManager there) and a complement to it on Android.
///
/// Triggers: app start, after saving a report, when the app returns to the
/// foreground, and a slow timer. Safe to run alongside the background job:
/// uploads are idempotent (document id = the report's clientId).
class ForegroundSync {
  ForegroundSync(this._dao, this._service, {this.onSynced});

  final ReportDao _dao;
  final SyncService _service;

  /// Called after an attempt that had reports to send, so the UI can reload.
  final VoidCallback? onSynced;

  Timer? _timer;
  bool _running = false;

  void start({Duration every = const Duration(seconds: 60)}) {
    _timer ??= Timer.periodic(every, (_) => unawaited(syncNow()));
    unawaited(syncNow());
  }

  Future<void> syncNow() async {
    if (_running) return;
    _running = true;
    var attempted = false;
    try {
      final pending = await _dao.getUnsynced();
      if (pending.isEmpty) return;
      attempted = true;
      await _service.syncPending();
    } catch (error) {
      // Offline or rules rejected the write: leave rows unsynced, try later.
      debugPrint('Foreground sync did not complete: $error');
    } finally {
      _running = false;
      if (attempted) onSynced?.call();
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
