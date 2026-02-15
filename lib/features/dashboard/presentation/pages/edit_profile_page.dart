import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';
import 'package:fitzee_new/features/dashboard/presentation/cubit/profile_cubit.dart';
import 'package:fitzee_new/features/dashboard/presentation/cubit/profile_state.dart';
import 'package:fitzee_new/features/onboard/domain/entities/medical_profile.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_medical_questionnaire_page.dart';

/// Edit profile form: load and save via [ProfileCubit] when provided (Clean Architecture).
/// When [profileCubit] is null, falls back to direct service calls for initial load/save.
class EditProfilePage extends StatefulWidget {
  final UserProfile? initialProfile;
  final ProfileCubit? profileCubit;

  const EditProfilePage({
    super.key,
    this.initialProfile,
    this.profileCubit,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _sleepController = TextEditingController();
  final _stressController = TextEditingController();
  final _trainingDaysController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String? _goal;
  String? _gender;
  String? _preferredTimeOfDay;
  bool? _doctorAdvisedAgainstExercise;
  bool? _hasHeartConditions;
  bool? _hasAsthma;
  bool? _hasDiabetes;
  bool? _hasActiveInjuries;
  bool? _hasChronicPain;
  bool? _takingPrescriptionMedications;
  bool? _hasRecentSurgeries;
  bool? _isPregnant;

  MedicalProfile? _medicalProfile;
  String? _fatLossWeeklyGoal;
  List<String> _rehabFocusAreas = [];
  String? _rehabPainLevel;

  String? _userId;
  bool _loading = true;
  bool _saving = false;

  static const _goals = ['fat_loss', 'medical', 'rehab'];
  static const _genders = ['male', 'female', 'other'];
  static const _times = ['morning', 'afternoon', 'evening'];
  static const _fatLossWeeklyOptions = ['lose_1kg', 'lose_0_5kg', 'maintain'];
  static const _fatLossWeeklyLabels = {
    'lose_1kg': 'Lose ~1 kg/week',
    'lose_0_5kg': 'Lose ~0.5 kg/week',
    'maintain': 'Maintain weight',
  };
  static const _rehabAreas = ['lower_back', 'knee', 'shoulder', 'neck', 'hip', 'ankle', 'general_mobility'];
  static const _rehabAreaLabels = {
    'lower_back': 'Lower back',
    'knee': 'Knee',
    'shoulder': 'Shoulder',
    'neck': 'Neck',
    'hip': 'Hip',
    'ankle': 'Ankle',
    'general_mobility': 'General mobility',
  };
  static const _rehabPainOptions = ['low', 'medium', 'high'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _userId = await LocalStorageService.getUserId();
    UserProfile? profile = widget.initialProfile;
    if (profile == null && _userId != null) {
      profile = await UserProfileService.getUserProfile(_userId);
    }
    if (profile != null) {
      _nameController.text = profile.name ?? '';
      _phoneController.text = profile.phone ?? '';
      _heightController.text = profile.height?.toString() ?? '';
      _weightController.text = profile.weight?.toString() ?? '';
      _ageController.text = profile.age?.toString() ?? '';
      _sleepController.text = profile.averageSleepHours?.toString() ?? '';
      _stressController.text = profile.stressLevel?.toString() ?? '';
      _trainingDaysController.text = profile.trainingDaysPerWeek?.toString() ?? '';
      _goal = profile.userType ?? profile.goal;
      _gender = profile.gender;
      _preferredTimeOfDay = profile.preferredTimeOfDay;
      _doctorAdvisedAgainstExercise = profile.doctorAdvisedAgainstExercise;
      _hasHeartConditions = profile.hasHeartConditions;
      _hasAsthma = profile.hasAsthma;
      _hasDiabetes = profile.hasDiabetes;
      _hasActiveInjuries = profile.hasActiveInjuries;
      _hasChronicPain = profile.hasChronicPain;
      _takingPrescriptionMedications = profile.takingPrescriptionMedications;
      _hasRecentSurgeries = profile.hasRecentSurgeries;
      _isPregnant = profile.isPregnant;
      _medicalProfile = profile.medicalProfile;
      _targetWeightController.text = profile.targetWeightKg?.toString() ?? '';
      _fatLossWeeklyGoal = profile.fatLossWeeklyGoal;
      _rehabFocusAreas = List.from(profile.rehabFocusAreas ?? []);
      _rehabPainLevel = profile.rehabPainLevel;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _sleepController.dispose();
    _stressController.dispose();
    _trainingDaysController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  /// Builds [UserProfile] from form fields and saves via [ProfileCubit] or [UserProfileService].
  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _userId == null) return;
    setState(() => _saving = true);
    final profile = UserProfile(
      userId: _userId,
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      userType: _goal,
      goal: _goal,
      height: double.tryParse(_heightController.text.trim()),
      weight: double.tryParse(_weightController.text.trim()),
      gender: _gender,
      age: int.tryParse(_ageController.text.trim()),
      trainingDaysPerWeek: int.tryParse(_trainingDaysController.text.trim()),
      preferredTimeOfDay: _preferredTimeOfDay,
      averageSleepHours: double.tryParse(_sleepController.text.trim()),
      stressLevel: int.tryParse(_stressController.text.trim()),
      doctorAdvisedAgainstExercise: _doctorAdvisedAgainstExercise,
      hasHeartConditions: _hasHeartConditions,
      hasAsthma: _hasAsthma,
      hasDiabetes: _hasDiabetes,
      hasActiveInjuries: _hasActiveInjuries,
      hasChronicPain: _hasChronicPain,
      takingPrescriptionMedications: _takingPrescriptionMedications,
      hasRecentSurgeries: _hasRecentSurgeries,
      isPregnant: _isPregnant,
      medicalProfile: _medicalProfile,
      targetWeightKg: double.tryParse(_targetWeightController.text.trim()),
      fatLossWeeklyGoal: _fatLossWeeklyGoal,
      rehabFocusAreas: _rehabFocusAreas.isEmpty ? null : _rehabFocusAreas,
      rehabPainLevel: _rehabPainLevel,
      updatedAt: DateTime.now(),
    );
    try {
      if (widget.profileCubit != null) {
        final success = await widget.profileCubit!.saveProfile(profile);
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (mounted && widget.profileCubit!.state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((widget.profileCubit!.state as ProfileError).message),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      } else {
        await UserProfileService.saveUserProfile(profile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDarkBlueGreen,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDarkLight,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Edit Profile', style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDarkLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen))
                : const Text('Save', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Personal', [
                _textField(_nameController, 'Name', optional: true),
                _textField(_phoneController, 'Phone', optional: true, keyboardType: TextInputType.phone),
                _dropdown('User type', _goal, _goals, (v) => setState(() => _goal = v)),
                _textField(_heightController, 'Height (cm)', optional: true, keyboardType: TextInputType.number),
                _textField(_weightController, 'Weight (kg)', optional: true, keyboardType: TextInputType.number),
                _dropdown('Gender', _gender, _genders, (v) => setState(() => _gender = v)),
                _textField(_ageController, 'Age', optional: true, keyboardType: TextInputType.number),
              ]),
              const SizedBox(height: 24),
              _section('Activity', [
                _textField(_trainingDaysController, 'Training days per week', optional: true, keyboardType: TextInputType.number),
                _dropdown('Preferred time', _preferredTimeOfDay, _times, (v) => setState(() => _preferredTimeOfDay = v)),
                _textField(_sleepController, 'Average sleep (hours)', optional: true, keyboardType: TextInputType.number),
                _textField(_stressController, 'Stress level (1-10)', optional: true, keyboardType: TextInputType.number),
              ]),
              if (_goal == 'fat_loss') ...[
                const SizedBox(height: 24),
                _section('Fat loss goals', [
                  _textField(_targetWeightController, 'Target weight (kg)', optional: true, keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  const Text('Weekly goal', style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _fatLossWeeklyOptions.map((v) {
                      final selected = _fatLossWeeklyGoal == v;
                      return ChoiceChip(
                        label: Text(_fatLossWeeklyLabels[v] ?? v),
                        selected: selected,
                        onSelected: (_) => setState(() => _fatLossWeeklyGoal = v),
                        selectedColor: AppColors.primaryGreen.withOpacity(0.4),
                      );
                    }).toList(),
                  ),
                ]),
              ],
              if (_goal == 'rehab') ...[
                const SizedBox(height: 24),
                _section('Rehab focus', [
                  const Text('Focus areas', style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _rehabAreas.map((v) {
                      final selected = _rehabFocusAreas.contains(v);
                      return FilterChip(
                        label: Text(_rehabAreaLabels[v] ?? v),
                        selected: selected,
                        onSelected: (sel) {
                          setState(() {
                            if (sel) _rehabFocusAreas.add(v);
                            else _rehabFocusAreas.remove(v);
                          });
                        },
                        selectedColor: AppColors.primaryGreen.withOpacity(0.4),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Pain level', style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _rehabPainOptions.map((v) {
                      final selected = _rehabPainLevel == v;
                      return ChoiceChip(
                        label: Text(v[0].toUpperCase() + v.substring(1)),
                        selected: selected,
                        onSelected: (_) => setState(() => _rehabPainLevel = v),
                        selectedColor: AppColors.primaryGreen.withOpacity(0.4),
                      );
                    }).toList(),
                  ),
                ]),
              ],
              if (_goal == 'medical') ...[
                const SizedBox(height: 24),
                _section('Medical details', [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final updated = await Navigator.of(context).push<MedicalProfile>(
                            MaterialPageRoute(
                              builder: (_) => OnboardMedicalQuestionnairePage(
                                forEditProfile: true,
                                initialMedical: _medicalProfile,
                              ),
                            ),
                          );
                          if (updated != null && mounted) {
                            setState(() => _medicalProfile = updated);
                          }
                        },
                        icon: const Icon(Icons.medical_services_outlined, color: AppColors.primaryGreen),
                        label: const Text('Edit medical details (questionnaire)', style: TextStyle(color: AppColors.primaryGreen)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  if (_medicalProfile != null)
                    Text(
                      'Conditions: ${(_medicalProfile!.conditions.isEmpty ? ['None'] : _medicalProfile!.conditions).join(', ')}',
                      style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                    ),
                ]),
              ],
              const SizedBox(height: 24),
              _section('Medical (optional)', [
                _switchTile('Doctor advised against exercise', _doctorAdvisedAgainstExercise ?? false, (v) => setState(() => _doctorAdvisedAgainstExercise = v)),
                _switchTile('Heart conditions', _hasHeartConditions ?? false, (v) => setState(() => _hasHeartConditions = v)),
                _switchTile('Asthma', _hasAsthma ?? false, (v) => setState(() => _hasAsthma = v)),
                _switchTile('Diabetes', _hasDiabetes ?? false, (v) => setState(() => _hasDiabetes = v)),
                _switchTile('Active injuries', _hasActiveInjuries ?? false, (v) => setState(() => _hasActiveInjuries = v)),
                _switchTile('Chronic pain', _hasChronicPain ?? false, (v) => setState(() => _hasChronicPain = v)),
                _switchTile('Prescription medications', _takingPrescriptionMedications ?? false, (v) => setState(() => _takingPrescriptionMedications = v)),
                _switchTile('Recent surgeries', _hasRecentSurgeries ?? false, (v) => setState(() => _hasRecentSurgeries = v)),
                _switchTile('Pregnant', _isPregnant ?? false, (v) => setState(() => _isPregnant = v)),
              ]),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.textBlack,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textBlack)) : const Text('Save profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDarkLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGreen.withOpacity(0.5)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _textField(TextEditingController c, String label, {bool optional = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textWhite),
        decoration: InputDecoration(
          labelText: optional ? '$label (optional)' : label,
          labelStyle: const TextStyle(color: AppColors.textGray),
          filled: true,
          fillColor: AppColors.backgroundDark,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
        ),
        validator: optional ? null : (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value != null && options.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textGray),
          filled: true,
          fillColor: AppColors.backgroundDark,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
        ),
        dropdownColor: AppColors.backgroundDarkLight,
        style: const TextStyle(color: AppColors.textWhite),
        items: [const DropdownMenuItem<String>(value: null, child: Text('—'))] +
            options.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 14))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primaryGreen),
        ],
      ),
    );
  }
}
