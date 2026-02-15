/// App SQLite database (Drift). Source of truth for offline-first; Firebase syncs when online.
/// All reads/writes go through this; UI stays decoupled via repositories.
/// Uses conditional import: native (sqlite3 FFI) on mobile/desktop, stub on web so web build does not compile sqlite3.
import 'package:drift/drift.dart';

import 'connection_web.dart' if (dart.library.io) 'connection_native.dart' as connection;
import 'drift_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalUserProfiles,
    DailyDataEntries,
    DailyNutritionEntries,
    // MedicalEntries omitted until drift_dev analyzer supports it; use SharedPreferences path for now
    FoodEntries,
    WorkoutPlans,
    WorkoutSessions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());

  @override
  int get schemaVersion => 1;

  /// Soft delete: set deletedAt to now and update syncStatus so sync can push the delete.
  static const String syncStatusPending = 'pending';
  static const String syncStatusSynced = 'synced';
}
