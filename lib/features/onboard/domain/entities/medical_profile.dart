/// Medical questionnaire data (6 sections). Stored under user profile or users/{userId}/medical_profile.
/// Only some fields are mandatory; most are optional for better completion rates.
class MedicalProfile {
  // SECTION 1 — Existing Medical Conditions (multi-select)
  final List<String> conditions; // diabetes, hypertension, heart_disease, asthma, thyroid, pcos, arthritis, mental_health, none
  final String? diabetesType; // type1, type2, prediabetic
  final String? lastHbA1c;
  final bool? diabetesOnMedication;
  final String? diabetesMedicationsText; // which medicines (when diabetesOnMedication == true)
  final String? bpType; // high, low
  final bool? bpOnMedication;
  final String? bpMedicationsText; // which medicines (when bpOnMedication == true)
  // Other conditions: optional "on medication?" + medications text
  final bool? heartDiseaseOnMedication;
  final String? heartDiseaseMedicationsText;
  final bool? asthmaOnMedication;
  final String? asthmaMedicationsText;
  final bool? thyroidOnMedication;
  final String? thyroidMedicationsText;
  final bool? pcosOnMedication;
  final String? pcosMedicationsText;
  final bool? arthritisOnMedication;
  final String? arthritisMedicationsText;
  final bool? mentalHealthOnMedication;
  final String? mentalHealthMedicationsText;

  // SECTION 2 — Medications & Allergies
  final bool? takingMedication;
  final String? medicationsText;
  final List<String> allergies; // food, medicine, dust, none
  final String? allergiesText;

  // SECTION 3 — Injury & Physical Limitations
  final List<String> injuries; // back_pain, knee_pain, shoulder, neck_pain, recent_surgery, none

  // SECTION 4 — Lifestyle
  final String? smoking; // never, occasionally, daily, former
  final String? alcohol; // never, social, weekly, daily

  // SECTION 5 — Family Medical History
  final List<String> familyHistory; // diabetes, heart_disease, stroke, obesity, cancer, none

  // SECTION 6 — Emergency & Notes
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? additionalNotes;

  const MedicalProfile({
    this.conditions = const [],
    this.diabetesType,
    this.lastHbA1c,
    this.diabetesOnMedication,
    this.diabetesMedicationsText,
    this.bpType,
    this.bpOnMedication,
    this.bpMedicationsText,
    this.heartDiseaseOnMedication,
    this.heartDiseaseMedicationsText,
    this.asthmaOnMedication,
    this.asthmaMedicationsText,
    this.thyroidOnMedication,
    this.thyroidMedicationsText,
    this.pcosOnMedication,
    this.pcosMedicationsText,
    this.arthritisOnMedication,
    this.arthritisMedicationsText,
    this.mentalHealthOnMedication,
    this.mentalHealthMedicationsText,
    this.takingMedication,
    this.medicationsText,
    this.allergies = const [],
    this.allergiesText,
    this.injuries = const [],
    this.smoking,
    this.alcohol,
    this.familyHistory = const [],
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.additionalNotes,
  });

  MedicalProfile copyWith({
    List<String>? conditions,
    String? diabetesType,
    String? lastHbA1c,
    bool? diabetesOnMedication,
    String? diabetesMedicationsText,
    String? bpType,
    bool? bpOnMedication,
    String? bpMedicationsText,
    bool? heartDiseaseOnMedication,
    String? heartDiseaseMedicationsText,
    bool? asthmaOnMedication,
    String? asthmaMedicationsText,
    bool? thyroidOnMedication,
    String? thyroidMedicationsText,
    bool? pcosOnMedication,
    String? pcosMedicationsText,
    bool? arthritisOnMedication,
    String? arthritisMedicationsText,
    bool? mentalHealthOnMedication,
    String? mentalHealthMedicationsText,
    bool? takingMedication,
    String? medicationsText,
    List<String>? allergies,
    String? allergiesText,
    List<String>? injuries,
    String? smoking,
    String? alcohol,
    List<String>? familyHistory,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? additionalNotes,
  }) {
    return MedicalProfile(
      conditions: conditions ?? this.conditions,
      diabetesType: diabetesType ?? this.diabetesType,
      lastHbA1c: lastHbA1c ?? this.lastHbA1c,
      diabetesOnMedication: diabetesOnMedication ?? this.diabetesOnMedication,
      diabetesMedicationsText: diabetesMedicationsText ?? this.diabetesMedicationsText,
      bpType: bpType ?? this.bpType,
      bpOnMedication: bpOnMedication ?? this.bpOnMedication,
      bpMedicationsText: bpMedicationsText ?? this.bpMedicationsText,
      heartDiseaseOnMedication: heartDiseaseOnMedication ?? this.heartDiseaseOnMedication,
      heartDiseaseMedicationsText: heartDiseaseMedicationsText ?? this.heartDiseaseMedicationsText,
      asthmaOnMedication: asthmaOnMedication ?? this.asthmaOnMedication,
      asthmaMedicationsText: asthmaMedicationsText ?? this.asthmaMedicationsText,
      thyroidOnMedication: thyroidOnMedication ?? this.thyroidOnMedication,
      thyroidMedicationsText: thyroidMedicationsText ?? this.thyroidMedicationsText,
      pcosOnMedication: pcosOnMedication ?? this.pcosOnMedication,
      pcosMedicationsText: pcosMedicationsText ?? this.pcosMedicationsText,
      arthritisOnMedication: arthritisOnMedication ?? this.arthritisOnMedication,
      arthritisMedicationsText: arthritisMedicationsText ?? this.arthritisMedicationsText,
      mentalHealthOnMedication: mentalHealthOnMedication ?? this.mentalHealthOnMedication,
      mentalHealthMedicationsText: mentalHealthMedicationsText ?? this.mentalHealthMedicationsText,
      takingMedication: takingMedication ?? this.takingMedication,
      medicationsText: medicationsText ?? this.medicationsText,
      allergies: allergies ?? this.allergies,
      allergiesText: allergiesText ?? this.allergiesText,
      injuries: injuries ?? this.injuries,
      smoking: smoking ?? this.smoking,
      alcohol: alcohol ?? this.alcohol,
      familyHistory: familyHistory ?? this.familyHistory,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditions': conditions,
      'diabetesType': diabetesType,
      'lastHbA1c': lastHbA1c,
      'diabetesOnMedication': diabetesOnMedication,
      'diabetesMedicationsText': diabetesMedicationsText,
      'bpType': bpType,
      'bpOnMedication': bpOnMedication,
      'bpMedicationsText': bpMedicationsText,
      'heartDiseaseOnMedication': heartDiseaseOnMedication,
      'heartDiseaseMedicationsText': heartDiseaseMedicationsText,
      'asthmaOnMedication': asthmaOnMedication,
      'asthmaMedicationsText': asthmaMedicationsText,
      'thyroidOnMedication': thyroidOnMedication,
      'thyroidMedicationsText': thyroidMedicationsText,
      'pcosOnMedication': pcosOnMedication,
      'pcosMedicationsText': pcosMedicationsText,
      'arthritisOnMedication': arthritisOnMedication,
      'arthritisMedicationsText': arthritisMedicationsText,
      'mentalHealthOnMedication': mentalHealthOnMedication,
      'mentalHealthMedicationsText': mentalHealthMedicationsText,
      'takingMedication': takingMedication,
      'medicationsText': medicationsText,
      'allergies': allergies,
      'allergiesText': allergiesText,
      'injuries': injuries,
      'smoking': smoking,
      'alcohol': alcohol,
      'familyHistory': familyHistory,
      'emergencyContact': (emergencyContactName != null || emergencyContactPhone != null)
          ? {
              'name': emergencyContactName,
              'phone': emergencyContactPhone,
            }
          : null,
      'notes': additionalNotes,
    };
  }

  factory MedicalProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MedicalProfile();
    final ec = json['emergencyContact'] as Map<String, dynamic>?;
    return MedicalProfile(
      conditions: (json['conditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      diabetesType: json['diabetesType'] as String?,
      lastHbA1c: json['lastHbA1c'] as String?,
      diabetesOnMedication: json['diabetesOnMedication'] as bool?,
      diabetesMedicationsText: json['diabetesMedicationsText'] as String?,
      bpType: json['bpType'] as String?,
      bpOnMedication: json['bpOnMedication'] as bool?,
      bpMedicationsText: json['bpMedicationsText'] as String?,
      heartDiseaseOnMedication: json['heartDiseaseOnMedication'] as bool?,
      heartDiseaseMedicationsText: json['heartDiseaseMedicationsText'] as String?,
      asthmaOnMedication: json['asthmaOnMedication'] as bool?,
      asthmaMedicationsText: json['asthmaMedicationsText'] as String?,
      thyroidOnMedication: json['thyroidOnMedication'] as bool?,
      thyroidMedicationsText: json['thyroidMedicationsText'] as String?,
      pcosOnMedication: json['pcosOnMedication'] as bool?,
      pcosMedicationsText: json['pcosMedicationsText'] as String?,
      arthritisOnMedication: json['arthritisOnMedication'] as bool?,
      arthritisMedicationsText: json['arthritisMedicationsText'] as String?,
      mentalHealthOnMedication: json['mentalHealthOnMedication'] as bool?,
      mentalHealthMedicationsText: json['mentalHealthMedicationsText'] as String?,
      takingMedication: json['takingMedication'] as bool?,
      medicationsText: json['medicationsText'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      allergiesText: json['allergiesText'] as String?,
      injuries: (json['injuries'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      smoking: json['smoking'] as String?,
      alcohol: json['alcohol'] as String?,
      familyHistory: (json['familyHistory'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      emergencyContactName: ec?['name'] as String?,
      emergencyContactPhone: ec?['phone'] as String?,
      additionalNotes: json['notes'] as String?,
    );
  }
}
