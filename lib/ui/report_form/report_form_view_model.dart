import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/remote/sync_scheduler.dart';
import '../../data/report.dart';
import '../../data/report_dao.dart';

/// Equivalent of the Kotlin `SubmitState` sealed interface.
enum SubmitState { idle, saving, saved, error }

/// Equivalent of the Kotlin `ReportFormViewModel`.
class ReportFormViewModel extends ChangeNotifier {
  ReportFormViewModel(this._dao, {this.onSaved});

  final ReportDao _dao;

  /// Called after a report is stored, so the History tab can refresh.
  final VoidCallback? onSaved;

  SubmitState _state = SubmitState.idle;
  String? _errorMessage;

  SubmitState get state => _state;
  bool get isSubmitting => _state == SubmitState.saving;
  String? get errorMessage => _errorMessage;

  /// Saves locally first, always. The only network-related thing that happens
  /// here is *scheduling* a background sync, which can't fail the save.
  ///
  /// Returns true if the report was stored. Returns false if a save is
  /// already in progress (double tap) or if storing failed; in the failure
  /// case [errorMessage] is set.
  Future<bool> submitReport({
    required String type,
    required String? severity,
    required String notes,
  }) async {
    if (isSubmitting) return false;
    _state = SubmitState.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _currentPosition();
      final report = Report(
        clientId: Report.newClientId(),
        type: type,
        waterLevelSeverity: severity,
        notes: notes.trim(),
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await _dao.insert(report); // local-first, no network call
      try {
        await SyncScheduler.syncSoon();
      } catch (error) {
        // The periodic job will still pick the report up.
        debugPrint('Could not schedule immediate sync: $error');
      }
      _state = SubmitState.saved;
      notifyListeners();
      onSaved?.call();
      return true;
    } catch (error) {
      _state = SubmitState.error;
      _errorMessage = 'Could not save the report. Please try again.';
      notifyListeners();
      debugPrint('submitReport failed: $error');
      return false;
    }
  }

  /// Last known fix first (fast, like the Kotlin version); if the device has
  /// none, try one fresh fix with a short timeout. Falls back to null, which
  /// the caller stores as (0.0, 0.0) exactly like the original app.
  ///
  /// `getLastKnownPosition` isn't supported in browsers, so on web it goes
  /// straight to a fresh fix. The two steps are separate so a failure in the
  /// first one can't skip the second.
  Future<Position?> _currentPosition() async {
    if (!kIsWeb) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return last;
      } catch (error) {
        debugPrint('No last known location: $error');
      }
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (error) {
      debugPrint('No location available: $error');
      return null;
    }
  }
}
