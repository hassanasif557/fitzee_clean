/// Provides a single [AppDatabase] instance for the app (offline-first SQLite).
/// Initialize early (e.g. in main) so repositories can read/write Drift first.
import 'package:fitzee_new/core/database/app_database.dart';

AppDatabase? _db;

/// Returns the app database. Call [initDatabase] from main before using.
AppDatabase get appDatabase {
  final db = _db;
  if (db == null) {
    throw StateError(
      'AppDatabase not initialized. Call initDatabase() from main() before using repositories.',
    );
  }
  return db;
}

/// Initializes the SQLite database. Call once at app startup (e.g. in main() after WidgetsFlutterBinding).
Future<void> initDatabase() async {
  _db ??= AppDatabase();
}

/// Closes the database (e.g. on sign-out if you want to clear in-memory ref; the file persists).
Future<void> closeDatabase() async {
  if (_db != null) {
    await _db!.close();
    _db = null;
  }
}
