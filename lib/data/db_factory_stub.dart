import 'package:sqflite/sqflite.dart' as sqflite;

/// Android / iOS: the normal sqflite factory.
sqflite.DatabaseFactory platformDatabaseFactory() => sqflite.databaseFactory;
