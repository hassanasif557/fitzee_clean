import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Abstract repository for user profile (Clean Architecture: domain layer).
/// Implementation uses [UserProfileService] (Firestore + local). Cubits/use cases depend only on this interface.
abstract class UserProfileRepository {
  Future<UserProfile?> getProfile(String? userId);
  Future<void> saveProfile(UserProfile profile);
}
