import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/constants/theme_ext.dart';
import 'package:fitzee_new/features/dashboard/presentation/cubit/profile_cubit.dart';
import 'package:fitzee_new/features/dashboard/presentation/cubit/profile_state.dart';
import 'package:fitzee_new/features/dashboard/presentation/pages/edit_profile_page.dart';
import 'package:fitzee_new/features/onboard/domain/entities/medical_profile.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Profile screen: shows user profile and edit button (Bloc/Cubit state management).
/// Uses [ProfileCubit] for load/save; state comes from [BlocBuilder]. No direct service calls.
/// Requires [BlocProvider<ProfileCubit>] above (e.g. from [DashboardNavPanel] or shell).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  /// Opens edit profile screen; on success, reloads profile from cubit.
  void _openEditProfile(UserProfile? currentProfile) async {
    final cubit = context.read<ProfileCubit>();
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialProfile: currentProfile,
          profileCubit: cubit,
        ),
      ),
    );
    if (updated == true && mounted) {
      context.read<ProfileCubit>().loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: context.themeScaffoldBg,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'profile.title'.tr(),
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            buildWhen: (prev, next) =>
                next is ProfileLoaded || next is ProfileInitial,
            builder: (context, state) {
              final profile =
                  state is ProfileLoaded ? state.profile : null;
              return TextButton(
                onPressed: () => _openEditProfile(profile),
                child: Text(
                  'common.edit'.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ProfileCubit>().loadProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.textBlack,
                    ),
                    child: Text('common.retry'.tr()),
                  ),
                ],
              ),
            );
          }
          final profile = state is ProfileLoaded ? state.profile : null;
          final userType = profile?.userType ?? profile?.goal;
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'profile.no_profile_data'.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _openEditProfile(null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.textBlack,
                    ),
                    child: Text('profile.complete_profile'.tr()),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('profile.personal'.tr(), [
                  _row('profile.name'.tr(), profile.name ?? '—'),
                  _row('profile.age'.tr(),
                      profile.age != null ? '${profile.age}' : '—'),
                  _row('profile.gender'.tr(), profile.gender ?? '—'),
                  _row('profile.height'.tr(),
                      profile.height != null
                          ? '${profile.height!.toStringAsFixed(0)} cm'
                          : '—'),
                  _row('profile.weight'.tr(),
                      profile.weight != null
                          ? '${profile.weight!.toStringAsFixed(1)} kg'
                          : '—'),
                  _row('profile.goal'.tr(), profile.userType ?? profile.goal ?? '—'),
                ]),
                const SizedBox(height: 24),
                _buildSection('profile.activity'.tr(), [
                  _row(
                    'profile.training_days_week'.tr(),
                    profile.trainingDaysPerWeek != null
                        ? '${profile.trainingDaysPerWeek}'
                        : '—',
                  ),
                  _row('profile.preferred_time'.tr(),
                      profile.preferredTimeOfDay ?? '—'),
                  _row(
                    'profile.sleep_avg_hrs'.tr(),
                    profile.averageSleepHours != null
                        ? '${profile.averageSleepHours}'
                        : '—',
                  ),
                ]),
                if (userType == 'fat_loss' && (profile.targetWeightKg != null || profile.fatLossWeeklyGoal != null)) ...[
                  const SizedBox(height: 24),
                  _buildSection('Fat loss goals', [
                    _row('Target weight', profile.targetWeightKg != null ? '${profile.targetWeightKg!.toStringAsFixed(1)} kg' : '—'),
                    _row('Weekly goal', _fatLossWeeklyGoalLabel(profile.fatLossWeeklyGoal)),
                  ]),
                ],
                if (userType == 'rehab' && ((profile.rehabFocusAreas?.isNotEmpty ?? false) || profile.rehabPainLevel != null)) ...[
                  const SizedBox(height: 24),
                  _buildSection('Rehab focus', [
                    _row('Focus areas', (profile.rehabFocusAreas?.isNotEmpty ?? false) ? profile.rehabFocusAreas!.join(', ') : '—'),
                    _row('Pain level', profile.rehabPainLevel != null && profile.rehabPainLevel!.isNotEmpty ? '${profile.rehabPainLevel![0].toUpperCase()}${profile.rehabPainLevel!.length > 1 ? profile.rehabPainLevel!.substring(1) : ''}' : '—'),
                  ]),
                ],
                if (userType == 'medical' && profile.medicalProfile != null) ...[
                  const SizedBox(height: 24),
                  _buildMedicalSection(profile.medicalProfile!),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openEditProfile(profile),
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: Text('profile.edit_profile'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.textBlack,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.borderGreen.withOpacity(0.5)),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fatLossWeeklyGoalLabel(String? v) {
    if (v == null || v.isEmpty) return '—';
    switch (v) {
      case 'lose_1kg': return 'Lose ~1 kg/week';
      case 'lose_0_5kg': return 'Lose ~0.5 kg/week';
      case 'maintain': return 'Maintain weight';
      default: return v;
    }
  }

  Widget _buildMedicalSection(MedicalProfile m) {
    final theme = Theme.of(context);
    final rows = <Widget>[
      _row('Conditions', m.conditions.isEmpty ? 'None' : m.conditions.join(', ')),
      _row('Medications', m.takingMedication == true ? (m.medicationsText ?? 'Yes') : (m.takingMedication == false ? 'No' : '—')),
      _row('Allergies', m.allergies.isEmpty ? 'None' : m.allergies.join(', ')),
      _row('Injuries', m.injuries.isEmpty ? 'None' : m.injuries.join(', ')),
      _row('Smoking', m.smoking ?? '—'),
      _row('Alcohol', m.alcohol ?? '—'),
      _row('Family history', m.familyHistory.isEmpty ? 'None' : m.familyHistory.join(', ')),
    ];
    if (m.emergencyContactName != null || m.emergencyContactPhone != null) {
      rows.add(_row('Emergency contact', '${m.emergencyContactName ?? ''} ${m.emergencyContactPhone ?? ''}'.trim()));
    }
    if (m.additionalNotes != null && m.additionalNotes!.isNotEmpty) {
      rows.add(_row('Notes', m.additionalNotes!));
    }
    return _buildSection('Medical details', rows);
  }
}
