/// Syncs local SQLite (Drift) with Firebase when network is available.
/// Run after connectivity is restored so pending writes are pushed and remote changes can be pulled.
/// UI stays decoupled; this service is called from app lifecycle or connectivity listener.
import 'package:fitzee_new/core/services/connectivity_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';

class FirebaseSyncService {
  /// Call when app resumes or when connectivity is restored.
  /// Syncs user profile and other entities that have pending local changes.
  static Future<void> syncWhenOnline() async {
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (!hasInternet) return;

    final userId = await LocalStorageService.getUserId();
    if (userId == null || userId.isEmpty) return;

    await UserProfileService.syncLocalToFirestore(userId);
    // Add more entity syncs here: daily data, medical entries, workouts, etc.
  }
}
