import 'app_database.dart';
import 'report.dart';

/// Equivalent of the Kotlin `ReportDao`.
///
/// Room's `getAll(): Flow<...>` re-emits automatically; sqflite has no
/// reactive queries, so the view model simply calls [getAll] again after
/// writes (see `ReportListViewModel.load`).
class ReportDao {
  ReportDao(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<int> insert(Report report) async {
    final db = await _appDatabase.database;
    return db.insert('reports', report.toMap());
  }

  /// Newest first, like `ORDER BY timestamp DESC`.
  Future<List<Report>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query('reports', orderBy: 'timestamp DESC, id DESC');
    return rows.map(Report.fromMap).toList();
  }

  Future<List<Report>> getUnsynced() async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'reports',
      where: 'synced = 0',
      orderBy: 'timestamp ASC, id ASC',
    );
    return rows.map(Report.fromMap).toList();
  }

  Future<void> markSynced(int id) async {
    final db = await _appDatabase.database;
    await db.update('reports', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
