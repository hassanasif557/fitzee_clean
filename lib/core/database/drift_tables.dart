/// Drift table definitions for offline-first SQLite storage.
/// All tables use soft deletes (deleted_at) and sync metadata (sync_status, firestore_id).
import 'package:drift/drift.dart';

/// User profile: one row per userId. Soft delete + sync fields on every table.
/// Row class generated as [LocalUserProfile] to avoid clash with domain entity [UserProfile].
class LocalUserProfiles extends Table {
  TextColumn get userId => text()();
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))(); // pending | synced
  TextColumn get firestoreId => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Daily data: one row per (userId, date). Pagination by date.
class DailyDataEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get steps => integer().withDefault(const Constant(0))();
  IntColumn get calories => integer().withDefault(const Constant(0))();
  RealColumn get sleepHours => real().withDefault(const Constant(0))();
  IntColumn get healthScore => integer().nullable()();
  RealColumn get bloodSugar => real().nullable()();
  IntColumn get bloodPressureSystolic => integer().nullable()();
  IntColumn get bloodPressureDiastolic => integer().nullable()();
  IntColumn get exerciseMinutes => integer().nullable()();
  IntColumn get caloriesBurned => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get firestoreId => text().nullable()();
}

/// Daily nutrition summary: one row per (userId, date).
class DailyNutritionEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get totalCalories => real().withDefault(const Constant(0))();
  RealColumn get totalProtein => real().withDefault(const Constant(0))();
  RealColumn get totalCarbs => real().withDefault(const Constant(0))();
  RealColumn get totalFat => real().withDefault(const Constant(0))();
  RealColumn get totalFiber => real().nullable()();
  IntColumn get nutritionScore => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get firestoreId => text().nullable()();
}

/// Medical entries: list per user. Pagination by date desc.
/// Column named [entryDateTime] to avoid shadowing Table.dateTime().
class MedicalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get entryDateTime => dateTime()();
  TextColumn get type => text()();
  TextColumn get label => text()();
  RealColumn get valuePrimary => real().nullable()();
  IntColumn get valueSecondary => integer().nullable()();
  TextColumn get valueText => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get firestoreId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Food entries (meal items): list per user. Pagination by date desc.
class FoodEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get foodId => text()();
  TextColumn get foodName => text()();
  TextColumn get portionType => text()();
  RealColumn get grams => real()();
  TextColumn get nutritionJson => text()(); // FoodNutrition JSON
  DateTimeColumn get date => dateTime()();
  TextColumn get mealType => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get firestoreId => text().nullable()();
}

/// Workout plan: one row per userId (current plan JSON).
class WorkoutPlans extends Table {
  TextColumn get userId => text()();
  TextColumn get planJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get firestoreId => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Workout sessions: list per user. Pagination by startTime desc.
class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get workoutDayId => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get completedExercisesJson => text()(); // JSON array
  IntColumn get caloriesBurned => integer().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get firestoreId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
