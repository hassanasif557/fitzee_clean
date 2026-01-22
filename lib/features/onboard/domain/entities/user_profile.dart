class UserProfile {
  final String? userId;
  final String? name;
  final String? phone;
  final String? goal; // 'fat_loss', 'muscle_gain', 'rehab'
  final double? height; // in cm
  final double? weight; // in kg
  final String? gender; // 'male', 'female', 'other'
  final int? age;
  
  // Activity History
  final int? exerciseFrequencyPerWeek; // How often exercise per week
  
  // Availability
  final int? trainingDaysPerWeek; // Days per week for training
  final String? preferredTimeOfDay; // 'morning', 'afternoon', 'evening'
  
  // Daily Habits
  final double? averageSleepHours; // Average hours of sleep
  final int? stressLevel; // Stress level 1-10
  
  // Medical Conditions
  final bool? doctorAdvisedAgainstExercise;
  final bool? hasHeartConditions;
  final bool? hasAsthma;
  final bool? hasDiabetes;
  
  // Current Physical State
  final bool? hasActiveInjuries;
  final bool? hasChronicPain;
  final bool? takingPrescriptionMedications;
  
  // Recent Events
  final bool? hasRecentSurgeries;
  final bool? isPregnant;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    this.userId,
    this.name,
    this.phone,
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
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? userId,
    String? name,
    String? phone,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isComplete {
    return goal != null &&
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
      'goal': goal,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
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
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
