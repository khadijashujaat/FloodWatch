import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web: SQLite compiled to WebAssembly, persisted in the browser's IndexedDB.
/// Needs `web/sqlite3.wasm` and `web/sqflite_sw.js`
/// (create them with `dart run sqflite_common_ffi_web:setup`).
sqflite.DatabaseFactory platformDatabaseFactory() => databaseFactoryFfiWeb;
