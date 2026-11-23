// Picks the right SQLite implementation per platform at compile time.
export 'db_factory_stub.dart'
    if (dart.library.js_interop) 'db_factory_web.dart';
