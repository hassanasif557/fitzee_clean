/// Cubit for the onboarding flow: holds in-memory [UserProfile] and emits step states.
/// Loads existing profile on init; save goes through [UserProfileService] (could be refactored to use cases).
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/medical_profile.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

part 'onboard_state.dart';

class OnboardCubit extends Cubit<OnboardState> {
  OnboardCubit() : super(OnboardInitial()) {
    _loadProfile();
  }

  UserProfile _profile = UserProfile();

  Future<void> _loadProfile() async {
    final userId = await LocalStorageService.getUserId();
    final savedProfile = await UserProfileService.getUserProfile(userId);
    if (savedProfile != null) {
      _profile = savedProfile;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user?.phoneNumber != null && _profile.phone == null) {
      _profile = _profile.copyWith(phone: user!.phoneNumber);
    }
  }

  /// Sets user type: fat_loss | medical | rehab. Also sets goal for backward compat.
  void setUserType(String userType) {
    _profile = _profile.copyWith(userType: userType, goal: userType);
    emit(OnboardGoalSelected(userType));
  }

  void setGoal(String goal) {
    _profile = _profile.copyWith(goal: goal, userType: goal);
    emit(OnboardGoalSelected(goal));
  }

  void setMedicalProfile(MedicalProfile medicalProfile) {
    _profile = _profile.copyWith(medicalProfile: medicalProfile);
    emit(OnboardMedicalProfileSet());
  }

  void setFatLossGoals({double? targetWeightKg, String? weeklyGoal}) {
    _profile = _profile.copyWith(
      targetWeightKg: targetWeightKg,
      fatLossWeeklyGoal: weeklyGoal,
    );
    emit(OnboardGoalSelected(_profile.userType ?? _profile.goal ?? ''));
  }

  void setRehabGoals({List<String>? focusAreas, String? painLevel}) {
    _profile = _profile.copyWith(
      rehabFocusAreas: focusAreas,
      rehabPainLevel: painLevel,
    );
    emit(OnboardGoalSelected(_profile.userType ?? _profile.goal ?? ''));
  }

  void setHeight(double height) {
    _profile = _profile.copyWith(height: height);
    emit(OnboardHeightSet(height));
  }

  void setWeight(double weight) {
    _profile = _profile.copyWith(weight: weight);
    emit(OnboardWeightSet(weight));
  }

  void setGender(String gender) {
    _profile = _profile.copyWith(gender: gender);
    emit(OnboardGenderSet(gender));
  }

  void setAge(int age) {
    _profile = _profile.copyWith(age: age);
    emit(OnboardAgeSet(age));
  }

  void setName(String name) {
    _profile = _profile.copyWith(name: name);
    emit(OnboardNameSet(name));
  }

  void setPhone(String phone) {
    _profile = _profile.copyWith(phone: phone);
    emit(OnboardPhoneSet(phone));
  }

  // Activity History
  void setExerciseFrequencyPerWeek(int frequency) {
    _profile = _profile.copyWith(exerciseFrequencyPerWeek: frequency);
    emit(OnboardExerciseFrequencySet(frequency));
  }

  // Availability
  void setTrainingDaysPerWeek(int days) {
    _profile = _profile.copyWith(trainingDaysPerWeek: days);
    emit(OnboardTrainingDaysSet(days));
  }

  void setPreferredTimeOfDay(String timeOfDay) {
    _profile = _profile.copyWith(preferredTimeOfDay: timeOfDay);
    emit(OnboardPreferredTimeSet(timeOfDay));
  }

  // Daily Habits
  void setAverageSleepHours(double hours) {
    _profile = _profile.copyWith(averageSleepHours: hours);
    emit(OnboardSleepHoursSet(hours));
  }

  void setStressLevel(int level) {
    _profile = _profile.copyWith(stressLevel: level);
    emit(OnboardStressLevelSet(level));
  }

  // Medical Conditions
  void setDoctorAdvisedAgainstExercise(bool advised) {
    _profile = _profile.copyWith(doctorAdvisedAgainstExercise: advised);
    emit(OnboardMedicalConditionSet());
  }

  void setHasHeartConditions(bool has) {
    _profile = _profile.copyWith(hasHeartConditions: has);
    emit(OnboardMedicalConditionSet());
  }

  void setHasAsthma(bool has) {
    _profile = _profile.copyWith(hasAsthma: has);
    emit(OnboardMedicalConditionSet());
  }

  void setHasDiabetes(bool has) {
    _profile = _profile.copyWith(hasDiabetes: has);
    emit(OnboardMedicalConditionSet());
  }

  // Current Physical State
  void setHasActiveInjuries(bool has) {
    _profile = _profile.copyWith(hasActiveInjuries: has);
    emit(OnboardPhysicalStateSet());
  }

  void setHasChronicPain(bool has) {
    _profile = _profile.copyWith(hasChronicPain: has);
    emit(OnboardPhysicalStateSet());
  }

  void setTakingPrescriptionMedications(bool taking) {
    _profile = _profile.copyWith(takingPrescriptionMedications: taking);
    emit(OnboardPhysicalStateSet());
  }

  // Recent Events
  void setHasRecentSurgeries(bool has) {
    _profile = _profile.copyWith(hasRecentSurgeries: has);
    emit(OnboardRecentEventsSet());
  }

  void setIsPregnant(bool isPregnant) {
    _profile = _profile.copyWith(isPregnant: isPregnant);
    emit(OnboardRecentEventsSet());
  }

  Future<void> saveProfile() async {
    emit(OnboardSaving());
    try {
      final userId = await LocalStorageService.getUserId();
      
      // Get phone from Firebase Auth if not already set
      final user = FirebaseAuth.instance.currentUser;
      final phone = _profile.phone ?? user?.phoneNumber;
      
      final profileToSave = _profile.copyWith(
        userId: userId,
        phone: phone,
        updatedAt: DateTime.now(),
        createdAt: _profile.createdAt ?? DateTime.now(),
      );

      // Save to both Firestore (if online) and local storage
      await UserProfileService.saveUserProfile(profileToSave);
      await LocalStorageService.setOnboardCompleted(true);
      emit(OnboardCompleted());
    } catch (e) {
      emit(OnboardError(e.toString()));
    }
  }

  UserProfile get profile => _profile;
  bool get isProfileComplete => _profile.isComplete;
}
