/// Web placeholder: SQLite/Drift native is not available on web (uses FFI).
/// This avoids compiling sqlite3 FFI for JS. Database is not available on web.
import 'package:drift/drift.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    throw UnsupportedError(
      'SQLite database is not available on web. Run the app on Android, iOS, or desktop.',
    );
  });
}
