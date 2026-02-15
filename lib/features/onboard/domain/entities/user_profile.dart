import 'medical_profile.dart';

class UserProfile {
  final String? userId;
  final String? name;
  final String? phone;
  /// User type: 'fat_loss' | 'medical' | 'rehab'. Drives questionnaire and features.
  final String? userType;
  /// Legacy; kept for backward compat. When userType is set, goal mirrors it.
  final String? goal; // 'fat_loss', 'medical', 'rehab'
  final double? height; // in cm
  final double? weight; // in kg
  final String? gender; // 'male', 'female', 'other'
  final int? age;

  // Activity History
  final int? exerciseFrequencyPerWeek;
  final int? trainingDaysPerWeek;
  final String? preferredTimeOfDay; // 'morning', 'afternoon', 'evening'

  // Daily Habits
  final double? averageSleepHours;
  final int? stressLevel; // 1-10

  // Medical Conditions (legacy / general)
  final bool? doctorAdvisedAgainstExercise;
  final bool? hasHeartConditions;
  final bool? hasAsthma;
  final bool? hasDiabetes;
  final bool? hasActiveInjuries;
  final bool? hasChronicPain;
  final bool? takingPrescriptionMedications;
  final bool? hasRecentSurgeries;
  final bool? isPregnant;

  /// Full medical questionnaire (6 sections). Used when userType == 'medical'.
  final MedicalProfile? medicalProfile;

  /// Fat-loss specific (optional). When userType == 'fat_loss'.
  final double? targetWeightKg;
  final String? fatLossWeeklyGoal; // lose_1kg, lose_0_5kg, maintain

  /// Rehab specific (optional). When userType == 'rehab'.
  final List<String>? rehabFocusAreas;
  final String? rehabPainLevel; // low, medium, high

  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    this.userId,
    this.name,
    this.phone,
    this.userType,
    this.goal,
    this.height,
    this.weight,
    this.gender,
    this.age,
    this.exerciseFrequencyPerWeek,
    this.trainingDaysPerWeek,
    this.preferredTimeOfDay,
    this.averageSleepHours,
    this.stressLevel,
    this.doctorAdvisedAgainstExercise,
    this.hasHeartConditions,
    this.hasAsthma,
    this.hasDiabetes,
    this.hasActiveInjuries,
    this.hasChronicPain,
    this.takingPrescriptionMedications,
    this.hasRecentSurgeries,
    this.isPregnant,
    this.medicalProfile,
    this.targetWeightKg,
    this.fatLossWeeklyGoal,
    this.rehabFocusAreas,
    this.rehabPainLevel,
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? userId,
    String? name,
    String? phone,
    String? userType,
    String? goal,
    double? height,
    double? weight,
    String? gender,
    int? age,
    int? exerciseFrequencyPerWeek,
    int? trainingDaysPerWeek,
    String? preferredTimeOfDay,
    double? averageSleepHours,
    int? stressLevel,
    bool? doctorAdvisedAgainstExercise,
    bool? hasHeartConditions,
    bool? hasAsthma,
    bool? hasDiabetes,
    bool? hasActiveInjuries,
    bool? hasChronicPain,
    bool? takingPrescriptionMedications,
    bool? hasRecentSurgeries,
    bool? isPregnant,
    MedicalProfile? medicalProfile,
    double? targetWeightKg,
    String? fatLossWeeklyGoal,
    List<String>? rehabFocusAreas,
    String? rehabPainLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      goal: goal ?? this.goal,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      exerciseFrequencyPerWeek: exerciseFrequencyPerWeek ?? this.exerciseFrequencyPerWeek,
      trainingDaysPerWeek: trainingDaysPerWeek ?? this.trainingDaysPerWeek,
      preferredTimeOfDay: preferredTimeOfDay ?? this.preferredTimeOfDay,
      averageSleepHours: averageSleepHours ?? this.averageSleepHours,
      stressLevel: stressLevel ?? this.stressLevel,
      doctorAdvisedAgainstExercise: doctorAdvisedAgainstExercise ?? this.doctorAdvisedAgainstExercise,
      hasHeartConditions: hasHeartConditions ?? this.hasHeartConditions,
      hasAsthma: hasAsthma ?? this.hasAsthma,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      hasActiveInjuries: hasActiveInjuries ?? this.hasActiveInjuries,
      hasChronicPain: hasChronicPain ?? this.hasChronicPain,
      takingPrescriptionMedications: takingPrescriptionMedications ?? this.takingPrescriptionMedications,
      hasRecentSurgeries: hasRecentSurgeries ?? this.hasRecentSurgeries,
      isPregnant: isPregnant ?? this.isPregnant,
      medicalProfile: medicalProfile ?? this.medicalProfile,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      fatLossWeeklyGoal: fatLossWeeklyGoal ?? this.fatLossWeeklyGoal,
      rehabFocusAreas: rehabFocusAreas ?? this.rehabFocusAreas,
      rehabPainLevel: rehabPainLevel ?? this.rehabPainLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mandatory for completion: userType (or legacy goal), height, weight, gender, age.
  bool get isComplete {
    final type = userType ?? goal;
    return type != null &&
        type.isNotEmpty &&
        height != null &&
        weight != null &&
        gender != null &&
        age != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'userType': userType,
      'goal': goal ?? userType,
      'height': height,
      'weight': weight,
      'gender': gender,
      'age': age,
      'exerciseFrequencyPerWeek': exerciseFrequencyPerWeek,
      'trainingDaysPerWeek': trainingDaysPerWeek,
      'preferredTimeOfDay': preferredTimeOfDay,
      'averageSleepHours': averageSleepHours,
      'stressLevel': stressLevel,
      'doctorAdvisedAgainstExercise': doctorAdvisedAgainstExercise,
      'hasHeartConditions': hasHeartConditions,
      'hasAsthma': hasAsthma,
      'hasDiabetes': hasDiabetes,
      'hasActiveInjuries': hasActiveInjuries,
      'hasChronicPain': hasChronicPain,
      'takingPrescriptionMedications': takingPrescriptionMedications,
      'hasRecentSurgeries': hasRecentSurgeries,
      'isPregnant': isPregnant,
      'medicalProfile': medicalProfile?.toJson(),
      'targetWeightKg': targetWeightKg,
      'fatLossWeeklyGoal': fatLossWeeklyGoal,
      'rehabFocusAreas': rehabFocusAreas,
      'rehabPainLevel': rehabPainLevel,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      userType: json['userType'] as String?,
      goal: json['goal'] as String?,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      exerciseFrequencyPerWeek: json['exerciseFrequencyPerWeek'] as int?,
      trainingDaysPerWeek: json['trainingDaysPerWeek'] as int?,
      preferredTimeOfDay: json['preferredTimeOfDay'] as String?,
      averageSleepHours: json['averageSleepHours'] != null ? (json['averageSleepHours'] as num).toDouble() : null,
      stressLevel: json['stressLevel'] as int?,
      doctorAdvisedAgainstExercise: json['doctorAdvisedAgainstExercise'] as bool?,
      hasHeartConditions: json['hasHeartConditions'] as bool?,
      hasAsthma: json['hasAsthma'] as bool?,
      hasDiabetes: json['hasDiabetes'] as bool?,
      hasActiveInjuries: json['hasActiveInjuries'] as bool?,
      hasChronicPain: json['hasChronicPain'] as bool?,
      takingPrescriptionMedications: json['takingPrescriptionMedications'] as bool?,
      hasRecentSurgeries: json['hasRecentSurgeries'] as bool?,
      isPregnant: json['isPregnant'] as bool?,
      medicalProfile: MedicalProfile.fromJson(json['medicalProfile'] as Map<String, dynamic>?),
      targetWeightKg: json['targetWeightKg'] != null ? (json['targetWeightKg'] as num).toDouble() : null,
      fatLossWeeklyGoal: json['fatLossWeeklyGoal'] as String?,
      rehabFocusAreas: json['rehabFocusAreas'] != null ? (json['rehabFocusAreas'] as List).cast<String>() : null,
      rehabPainLevel: json['rehabPainLevel'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
