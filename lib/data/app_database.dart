import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'db_factory.dart';

/// Equivalent of the Kotlin `AppDatabase` (Room).
///
/// The file name is deliberately different from the Android/Room app's
/// "floodwatch.db": if this app is installed over the old one (same package
/// name), opening Room's file with a different schema would crash.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const String _fileName = 'floodwatch_flutter.db';

  Future<Database>? _opening;

  Future<Database> get database {
    return _opening ??= _open().onError<Object>((error, stackTrace) {
      _opening = null; // don't cache a failed open
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  Future<Database> _open() async {
    final factory = platformDatabaseFactory();
    // On the web the "path" is just a name inside the browser's IndexedDB.
    final path = kIsWeb
        ? _fileName
        : join(await factory.getDatabasesPath(), _fileName);
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        water_level_severity TEXT,
        notes TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
