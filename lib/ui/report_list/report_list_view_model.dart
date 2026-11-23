import 'package:flutter/foundation.dart';

import '../../data/report.dart';
import '../../data/report_dao.dart';

/// Equivalent of the Kotlin `ReportListViewModel`.
///
/// Room exposed `getAll()` as a `Flow` that re-emitted on every table change.
/// sqflite has no reactive queries, so [load] re-reads the table instead. It
/// is called on start-up, after a report is saved, when the History tab is
/// opened, on pull-to-refresh, and when the app returns to the foreground
/// (the background sync job updates rows from a different isolate).
class ReportListViewModel extends ChangeNotifier {
  ReportListViewModel(this._dao);

  final ReportDao _dao;

  List<Report> _reports = const [];
  bool _loading = true;
  String? _error;

  List<Report> get reports => _reports;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    try {
      _reports = await _dao.getAll();
      _error = null;
    } catch (error) {
      _error = 'Could not load reports.';
      debugPrint('ReportListViewModel.load failed: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
