# Offline-first architecture (SQLite + Drift + Firebase)

## Overview

- **SQLite (Drift)** is the **source of truth**. All reads and writes go to the local database first.
- **Firebase** is used for **sync when online**: push pending changes, pull remote updates into SQLite.
- **UI** is fully decoupled: it uses **repositories / use cases** only; no direct database or Firebase calls in presentation.

## Layers

1. **UI** → calls **Cubits** → which call **Use cases**.
2. **Use cases** → call **Repositories** (domain interface).
3. **Repositories** (impl) → **Local data source (Drift)** for read/write, and **Firebase** for sync when online.

## Database (Drift)

- **Location**: `lib/core/database/`
- **Tables**: `LocalUserProfiles`, `DailyDataEntries`, `DailyNutritionEntries`, `FoodEntries`, `WorkoutPlans`, `WorkoutSessions`.
- **Soft deletes**: every table has `deletedAt` (nullable). "Deletes" set `deletedAt = now` and exclude rows where `deletedAt IS NOT NULL` in queries.
- **Sync**: `syncStatus` (`pending` | `synced`) and optional `firestoreId` for mapping to Firestore docs.

## Pagination

For list data (e.g. medical entries, food entries, leaderboard cache), use **limit + offset** in Drift:

```dart
select()..where(...)..orderBy(...)..limit(limit)..offset(offset)
```

Repositories expose methods like `getMedicalEntriesPaginated(userId, limit, offset)` so the UI can load pages and scroll smoothly.

## Sync flow

1. **Write path**: Repository writes to Drift, sets `syncStatus = pending`. If online, push to Firebase and set `syncStatus = synced`.
2. **Read path**: Repository reads from Drift. Optionally, when online, pull from Firebase, merge into Drift, then return from Drift.
3. **On connectivity restored**: Call `FirebaseSyncService.syncWhenOnline()` to push pending rows and pull remote changes.

## Initialization

- `initDatabase()` is called from `main()` so Drift is ready before any repository is used.
- Access the database via `appDatabase` from `database_provider.dart`.
