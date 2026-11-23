import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/map_report.dart';
import '../../data/remote/firestore_report_reader.dart';
import '../report_list/report_list_view_model.dart';

/// Feeds the map: reports from this device (taken from the History view
/// model, so there is no second database read) merged with everyone's
/// reports from Firestore. Remote listening starts the first time the Map
/// tab is opened, not at app start.
class MapViewModel extends ChangeNotifier {
  MapViewModel(this._localSource, this._reader) {
    _localSource.addListener(_onLocalChanged);
  }

  final ReportListViewModel _localSource;
  final FirestoreReportReader _reader;

  StreamSubscription<List<MapReport>>? _subscription;
  List<MapReport> _remote = const [];
  String? _remoteProblem;
  bool _started = false;

  MapMergeResult _merged = const MapMergeResult(
    plottable: [],
    withoutLocation: 0,
  );

  List<MapReport> get plottable => _merged.plottable;
  int get withoutLocation => _merged.withoutLocation;

  /// Non-null when the shared reports couldn't be loaded; the map still shows
  /// this device's own reports.
  String? get remoteProblem => _remoteProblem;

  void start() {
    if (_started) return;
    _started = true;
    _recompute();
    try {
      _subscription = _reader.watchReports().listen(
        (reports) {
          _remote = reports;
          _remoteProblem = null;
          _recompute();
        },
        onError: (Object error) {
          debugPrint('Map: could not read shared reports: $error');
          _remoteProblem = 'Showing reports from this device only. Could not load shared reports.';
          notifyListeners();
        },
      );
    } catch (error) {
      debugPrint('Map: could not start listening: $error');
      _remoteProblem = 'Showing reports from this device only. Could not load shared reports.';
      notifyListeners();
    }
  }

  void _onLocalChanged() {
    if (_started) _recompute();
  }

  void _recompute() {
    _merged = mergeForMap(
      local: _localSource.reports.map(MapReport.fromLocal).toList(),
      remote: _remote,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _localSource.removeListener(_onLocalChanged);
    _subscription?.cancel();
    super.dispose();
  }
}
