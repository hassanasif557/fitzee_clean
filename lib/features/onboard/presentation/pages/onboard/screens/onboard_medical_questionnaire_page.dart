import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/features/onboard/domain/entities/medical_profile.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/cubit/onboard_cubit.dart';

/// 6-step medical questionnaire for userType == 'medical'. Progress: Step X of 6.
/// Only some questions are mandatory; most are optional.
/// When [forEditProfile] is true, [initialMedical] is used and on submit pops with [MedicalProfile] (no cubit).
class OnboardMedicalQuestionnairePage extends StatefulWidget {
  final VoidCallback? onComplete;
  /// When true, used from Edit Profile: no OnboardCubit; initial state from [initialMedical]; pop with MedicalProfile on submit.
  final bool forEditProfile;
  /// Pre-fill when editing from profile.
  final MedicalProfile? initialMedical;

  const OnboardMedicalQuestionnairePage({
    super.key,
    this.onComplete,
    this.forEditProfile = false,
    this.initialMedical,
  });

  @override
  State<OnboardMedicalQuestionnairePage> createState() =>
      _OnboardMedicalQuestionnairePageState();
}

class _OnboardMedicalQuestionnairePageState
    extends State<OnboardMedicalQuestionnairePage> {
  final PageController _pageController = PageController();
  int _step = 0;
  static const int totalSteps = 6;
  late MedicalProfile _medical;

  @override
  void initState() {
    super.initState();
    _medical = widget.initialMedical ?? const MedicalProfile();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < totalSteps - 1) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop(false);
    }
  }

  void _submit() {
    if (widget.forEditProfile) {
      Navigator.of(context).pop(_medical);
      return;
    }
    context.read<OnboardCubit>().setMedicalProfile(_medical);
    widget.onComplete?.call();
    Navigator.of(context).pop(true);
  }

  void _updateMedical(MedicalProfile Function(MedicalProfile) update) {
    setState(() => _medical = update(_medical));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: _back,
        ),
        title: Text(
          'Step ${_step + 1} of $totalSteps',
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: (_step + 1) / totalSteps,
                backgroundColor: AppColors.textGray.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Conditions(medical: _medical, onUpdate: _updateMedical),
                  _Step2MedicationsAllergies(
                      medical: _medical, onUpdate: _updateMedical),
                  _Step3Injuries(medical: _medical, onUpdate: _updateMedical),
                  _Step4Lifestyle(medical: _medical, onUpdate: _updateMedical),
                  _Step5FamilyHistory(
                      medical: _medical, onUpdate: _updateMedical),
                  _Step6EmergencyNotes(
                      medical: _medical, onUpdate: _updateMedical),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.textBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _step < totalSteps - 1 ? 'Continue' : 'Review & Submit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Section 1: Existing Medical Conditions ---
class _Step1Conditions extends StatelessWidget {
  final MedicalProfile medical;
  final void Function(MedicalProfile Function(MedicalProfile)) onUpdate;

  const _Step1Conditions({required this.medical, required this.onUpdate});

  static const _options = [
    'diabetes',
    'hypertension',
    'heart_disease',
    'asthma',
    'thyroid',
    'pcos',
    'arthritis',
    'mental_health',
    'none',
  ];

  static const _labels = {
    'diabetes': 'Diabetes',
    'hypertension': 'High Blood Pressure',
    'heart_disease': 'Heart Disease',
    'asthma': 'Asthma / Respiratory',
    'thyroid': 'Thyroid Disorder',
    'pcos': 'PCOS / Hormonal',
    'arthritis': 'Arthritis / Joint Pain',
    'mental_health': 'Mental Health (Anxiety/Depression)',
    'none': 'None',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Existing Medical Conditions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select any that apply (optional)',
            style: TextStyle(color: AppColors.textGray, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((value) {
              final selected = medical.conditions.contains(value);
              return FilterChip(
                label: Text(_labels[value] ?? value),
                selected: selected,
                onSelected: (v) {
                  var next = List<String>.from(medical.conditions);
                  if (v) {
                    if (value == 'none') {
                      next = ['none'];
                    } else {
                      next.remove('none');
                      next.add(value);
                    }
                  } else {
                    next.remove(value);
                  }
                  onUpdate((m) => m.copyWith(conditions: next));
                },
                selectedColor: AppColors.primaryGreen.withOpacity(0.4),
                checkmarkColor: AppColors.primaryGreen,
              );
            }).toList(),
          ),
          if (medical.conditions.contains('diabetes') &&
              !medical.conditions.contains('none')) ...[
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text(
                'Diabetes details (optional)',
                style: TextStyle(color: AppColors.textWhite),
              ),
              children: [
                DropdownButtonFormField<String>(
                  value: medical.diabetesType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['type1', 'type2', 'prediabetic']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e == 'type1'
                                ? 'Type 1'
                                : e == 'type2'
                                    ? 'Type 2'
                                    : 'Pre-diabetic'),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      onUpdate((m) => m.copyWith(diabetesType: v)),
                ),
                TextFormField(
                  initialValue: medical.lastHbA1c,
                  decoration: const InputDecoration(
                    labelText: 'Last HbA1c (optional)',
                  ),
                  onChanged: (v) => onUpdate((m) => m.copyWith(lastHbA1c: v)),
                ),
                SwitchListTile(
                  title: const Text('Taking medication?'),
                  value: medical.diabetesOnMedication ?? false,
                  onChanged: (v) =>
                      onUpdate((m) => m.copyWith(diabetesOnMedication: v)),
                ),
                if (medical.diabetesOnMedication == true) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: medical.diabetesMedicationsText,
                    decoration: const InputDecoration(
                      labelText: 'Which medicines are you taking for diabetes?',
                      hintText: 'e.g. Metformin 500mg',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        onUpdate((m) => m.copyWith(diabetesMedicationsText: v)),
                  ),
                ],
              ],
            ),
          ],
          if (medical.conditions.contains('hypertension') &&
              !medical.conditions.contains('none')) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Blood pressure details (optional)',
                style: TextStyle(color: AppColors.textWhite),
              ),
              children: [
                DropdownButtonFormField<String>(
                  value: medical.bpType,
                  decoration: const InputDecoration(labelText: 'High / Low'),
                  items: ['high', 'low']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e == 'high' ? 'High' : 'Low'),
                          ))
                      .toList(),
                  onChanged: (v) => onUpdate((m) => m.copyWith(bpType: v)),
                ),
                SwitchListTile(
                  title: const Text('On medication?'),
                  value: medical.bpOnMedication ?? false,
                  onChanged: (v) =>
                      onUpdate((m) => m.copyWith(bpOnMedication: v)),
                ),
                if (medical.bpOnMedication == true) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: medical.bpMedicationsText,
                    decoration: const InputDecoration(
                      labelText: 'Which medicines are you taking for blood pressure?',
                      hintText: 'e.g. Amlodipine 5mg',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        onUpdate((m) => m.copyWith(bpMedicationsText: v)),
                  ),
                ],
              ],
            ),
          ],
          if (medical.conditions.contains('heart_disease') &&
              !medical.conditions.contains('none')) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Heart disease details (optional)',
                style: TextStyle(color: AppColors.textWhite),
              ),
              children: [
                SwitchListTile(
                  title: const Text('Taking medication?'),
                  value: medical.heartDiseaseOnMedication ?? false,
                  onChanged: (v) => onUpdate(
                      (m) => m.copyWith(heartDiseaseOnMedication: v)),
                ),
                if (medical.heartDiseaseOnMedication == true) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: medical.heartDiseaseMedicationsText,
                    decoration: const InputDecoration(
                      labelText:
                          'Which medicines are you taking for heart condition?',
                      hintText: 'e.g. Aspirin 75mg',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => onUpdate(
                        (m) => m.copyWith(heartDiseaseMedicationsText: v)),
                  ),
                ],
              ],
            ),
          ],
          if (medical.conditions.contains('asthma') &&
              !medical.conditions.contains('none')) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Asthma / respiratory details (optional)',
                style: TextStyle(color: AppColors.textWhite),
              ),
              children: [
                SwitchListTile(
                  title: const Text('Taking medication?'),
                  value: medical.asthmaOnMedication ?? false,
                  onChanged: (v) =>
                      onUpdate((m) => m.copyWith(asthmaOnMedication: v)),
                ),
                if (medical.asthmaOnMedication == true) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: medical.asthmaMedicationsText,
                    decoration: const InputDecoration(
                      labelText:
                          'Which medicines are you taking for asthma?',
                      hintText: 'e.g. Inhaler, Salbutamol',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => onUpdate(
                        (m) => m.copyWith(asthmaMedicationsText: v)),
                  ),
                ],
              ],
            ),
          ],
          if (medical.conditions.contains('thyroid') &&
              !medical.conditions.contains('none')) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Thyroid disorder details (optional)',
                style: TextStyle(color: AppColors.textWhite),
              ),
              children: [
                SwitchListTile(
                  title: const Text('Taking medication?'),
                  value: medical.thyroidOnMedication ?? false,
                  onChanged: (v) =>
                      onUpdate((m) => m.copyWith(thyroidOnMedication: v)),
                ),
                if (medical.thyroidOnMedication == true) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: medical.thyroidMedicationsText,
                    decoration: const InputDecoration(
                      labelText:
                          'Which medicines are you taking for thyroid?',
                      hintText: 'e.g. Levothyroxine',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => onUpdate(
                        (m) => m.copyWith(thyroidMedicationsText: v)),
                  ),
                ],
              ],
            ),
          ],
          if (medical.conditions.contains('pcos') &&
              !medical.conditions.contains('none')) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'PCOS / hormonal details (optional)',
                style: TextStyle(color: AppColors.textWhite),
              ),
              children: [
                SwitchListTile(
                  title: const Text('Taking medication?'),
                  value: medical.pcosOnMedication ?? false,
                  onChanged: (v) =>
                      onUpdate((m) => m.copyWith(pcosOnMedication: v)),
                ),
                if (medical.pcosOnMedication == true) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: medical.pcosMedicationsText,
                    decoration: const InputDecoration(
                      labelText:
                          'Which medicines are you taking for PCOS/hormonal?',
                      hintText: 'e.g. Metformin, birth control',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => onUpdate(
                        (m) => m.copyWith(pcosMedicationsText: v)),
                  ),
                ],
              ],
            ),
          ],
          if (medical.conditions.contains('arthritis') &&
              !medical.conditions.contains('none')) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Arthritis / joint pain details (optional)',
                style: TextStyle(color: AppColors.textWhite),
              ),
              children: [
                SwitchListTile(
                  title: const Text('Taking medication?'),
                  value: medical.arthritisOnMedication ?? false,
                  onChanged: (v) => onUpdate(
                      (m) => m.copyWith(arthritisOnMedication: v)),
                ),
                if (medical.arthritisOnMedication == true) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: medical.arthritisMedicationsText,
                    decoration: const InputDecoration(
                      labelText:
                          'Which medicines are you taking for arthritis/joint pain?',
                      hintText: 'e.g. Ibuprofen, Paracetamol',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => onUpdate(
                        (m) => m.copyWith(arthritisMedicationsText: v)),
                  ),
                ],
              ],
            ),
          ],
          if (medical.conditions.contains('mental_health') &&
              !medical.conditions.contains('none')) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Mental health details (optional)',
                style: TextStyle(color: AppColors.textWhite),
              ),
              children: [
                SwitchListTile(
                  title: const Text('Taking medication?'),
                  value: medical.mentalHealthOnMedication ?? false,
                  onChanged: (v) => onUpdate(
                      (m) => m.copyWith(mentalHealthOnMedication: v)),
                ),
                if (medical.mentalHealthOnMedication == true) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: medical.mentalHealthMedicationsText,
                    decoration: const InputDecoration(
                      labelText:
                          'Which medicines are you taking (e.g. for anxiety/depression)?',
                      hintText: 'e.g. Sertraline, Escitalopram',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => onUpdate(
                        (m) => m.copyWith(mentalHealthMedicationsText: v)),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- Section 2: Medications & Allergies ---
class _Step2MedicationsAllergies extends StatelessWidget {
  final MedicalProfile medical;
  final void Function(MedicalProfile Function(MedicalProfile)) onUpdate;

  const _Step2MedicationsAllergies(
      {required this.medical, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medications & Allergies',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Are you currently taking any medication?',
              style: TextStyle(color: AppColors.textWhite)),
          Row(
            children: [
              ChoiceChip(
                label: const Text('No'),
                selected: medical.takingMedication == false,
                onSelected: (v) =>
                    onUpdate((m) => m.copyWith(takingMedication: false)),
                selectedColor: AppColors.primaryGreen.withOpacity(0.4),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Yes'),
                selected: medical.takingMedication == true,
                onSelected: (v) =>
                    onUpdate((m) => m.copyWith(takingMedication: true)),
                selectedColor: AppColors.primaryGreen.withOpacity(0.4),
              ),
            ],
          ),
          if (medical.takingMedication == true) ...[
            const SizedBox(height: 16),
            TextFormField(
              initialValue: medical.medicationsText,
              decoration: const InputDecoration(
                labelText: 'Medications (e.g. Metformin 500mg)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (v) =>
                  onUpdate((m) => m.copyWith(medicationsText: v)),
            ),
          ],
          const SizedBox(height: 24),
          const Text('Allergies (optional)',
              style: TextStyle(color: AppColors.textWhite)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['food', 'medicine', 'dust', 'none'].map((value) {
              final selected = medical.allergies.contains(value);
              return FilterChip(
                label: Text(value == 'dust'
                    ? 'Dust / Environment'
                    : value[0].toUpperCase() + value.substring(1)),
                selected: selected,
                onSelected: (v) {
                  var next = List<String>.from(medical.allergies);
                  if (v) {
                    if (value == 'none') next = ['none'];
                    else {
                      next.remove('none');
                      next.add(value);
                    }
                  } else
                    next.remove(value);
                  onUpdate((m) => m.copyWith(allergies: next));
                },
                selectedColor: AppColors.primaryGreen.withOpacity(0.4),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: medical.allergiesText,
            decoration: const InputDecoration(
              labelText: 'Details if yes',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => onUpdate((m) => m.copyWith(allergiesText: v)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- Section 3: Injuries ---
class _Step3Injuries extends StatelessWidget {
  final MedicalProfile medical;
  final void Function(MedicalProfile Function(MedicalProfile)) onUpdate;

  const _Step3Injuries({required this.medical, required this.onUpdate});

  static const _options = [
    'back_pain',
    'knee_pain',
    'shoulder',
    'neck_pain',
    'recent_surgery',
    'none',
  ];
  static const _labels = {
    'back_pain': 'Back Pain',
    'knee_pain': 'Knee Pain',
    'shoulder': 'Shoulder Injury',
    'neck_pain': 'Neck Pain',
    'recent_surgery': 'Recent Surgery',
    'none': 'None',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Injury & Physical Limitations',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select any that apply (optional)',
            style: TextStyle(color: AppColors.textGray),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((value) {
              final selected = medical.injuries.contains(value);
              return FilterChip(
                label: Text(_labels[value] ?? value),
                selected: selected,
                onSelected: (v) {
                  var next = List<String>.from(medical.injuries);
                  if (v) {
                    if (value == 'none') next = ['none'];
                    else {
                      next.remove('none');
                      next.add(value);
                    }
                  } else
                    next.remove(value);
                  onUpdate((m) => m.copyWith(injuries: next));
                },
                selectedColor: AppColors.primaryGreen.withOpacity(0.4),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- Section 4: Lifestyle ---
class _Step4Lifestyle extends StatelessWidget {
  final MedicalProfile medical;
  final void Function(MedicalProfile Function(MedicalProfile)) onUpdate;

  const _Step4Lifestyle({required this.medical, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lifestyle (optional)',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Smoking',
              style: TextStyle(color: AppColors.textWhite)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['never', 'occasionally', 'daily', 'former'].map((v) {
              return ChoiceChip(
                label: Text(v[0].toUpperCase() + v.substring(1)),
                selected: medical.smoking == v,
                onSelected: (_) => onUpdate((m) => m.copyWith(smoking: v)),
                selectedColor: AppColors.primaryGreen.withOpacity(0.4),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Alcohol',
              style: TextStyle(color: AppColors.textWhite)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['never', 'social', 'weekly', 'daily'].map((v) {
              return ChoiceChip(
                label: Text(v[0].toUpperCase() + v.substring(1)),
                selected: medical.alcohol == v,
                onSelected: (_) => onUpdate((m) => m.copyWith(alcohol: v)),
                selectedColor: AppColors.primaryGreen.withOpacity(0.4),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- Section 5: Family History ---
class _Step5FamilyHistory extends StatelessWidget {
  final MedicalProfile medical;
  final void Function(MedicalProfile Function(MedicalProfile)) onUpdate;

  const _Step5FamilyHistory({required this.medical, required this.onUpdate});

  static const _options = [
    'diabetes',
    'heart_disease',
    'stroke',
    'obesity',
    'cancer',
    'none',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Family Medical History (optional)',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((value) {
              final selected = medical.familyHistory.contains(value);
              return FilterChip(
                label: Text(value[0].toUpperCase() + value.substring(1)),
                selected: selected,
                onSelected: (v) {
                  var next = List<String>.from(medical.familyHistory);
                  if (v) {
                    if (value == 'none') next = ['none'];
                    else {
                      next.remove('none');
                      next.add(value);
                    }
                  } else
                    next.remove(value);
                  onUpdate((m) => m.copyWith(familyHistory: next));
                },
                selectedColor: AppColors.primaryGreen.withOpacity(0.4),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- Section 6: Emergency & Notes ---
class _Step6EmergencyNotes extends StatelessWidget {
  final MedicalProfile medical;
  final void Function(MedicalProfile Function(MedicalProfile)) onUpdate;

  const _Step6EmergencyNotes(
      {required this.medical, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency & Notes',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Emergency contact is recommended but optional.',
            style: TextStyle(color: AppColors.textGray),
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: medical.emergencyContactName,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) =>
                onUpdate((m) => m.copyWith(emergencyContactName: v)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: medical.emergencyContactPhone,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Phone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (v) =>
                onUpdate((m) => m.copyWith(emergencyContactPhone: v)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: medical.additionalNotes,
            decoration: const InputDecoration(
              labelText: 'Additional Medical Notes',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            onChanged: (v) =>
                onUpdate((m) => m.copyWith(additionalNotes: v)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
