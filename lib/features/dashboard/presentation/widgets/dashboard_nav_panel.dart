import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/constants/theme_ext.dart';
import 'package:fitzee_new/core/utils/theme_cubit.dart';
import 'package:fitzee_new/core/utils/locale_cubit.dart';
import 'package:fitzee_new/features/dashboard/presentation/pages/progress_report_screen.dart';
import 'package:fitzee_new/features/dashboard/presentation/core/di/profile_di.dart';
import 'package:fitzee_new/features/dashboard/presentation/cubit/profile_cubit.dart';
import 'package:fitzee_new/features/dashboard/presentation/pages/profile_page.dart';
import 'package:fitzee_new/features/dashboard/presentation/pages/notifications_page.dart';

/// Unique styled navigation panel (slide-in from right) with menu options.
class DashboardNavPanel extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onSignOut;
  final Future<void> Function() onDeleteAccount;
  /// Context from the parent (e.g. dashboard) for pushing routes after the dialog is closed.
  final BuildContext navigatorContext;

  const DashboardNavPanel({
    super.key,
    required this.onClose,
    required this.onSignOut,
    required this.onDeleteAccount,
    required this.navigatorContext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final surfaceVariant = theme.brightness == Brightness.dark
        ? AppColors.backgroundDarkBlueGreen
        : theme.colorScheme.surface.withValues(alpha: 0.95);
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.black54,
            ),
          ),
          // Panel
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [surface, surfaceVariant],
                ),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(-4, 0),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: SafeArea(
                left: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 8),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            _NavTile(
                              icon: Icons.person_rounded,
                              label: 'nav_panel.profile'.tr(),
                              onTap: () {
                                onClose();
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (navigatorContext.mounted) {
                                    Navigator.of(navigatorContext).push(
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider(
                                          create: (_) => ProfileDi.createCubit(),
                                          child: const ProfilePage(),
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                            _NavTile(
                              icon: Icons.notifications_rounded,
                              label: 'nav_panel.notifications'.tr(),
                              onTap: () {
                                onClose();
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (navigatorContext.mounted) {
                                    Navigator.of(navigatorContext).push(
                                      MaterialPageRoute(
                                        builder: (_) => const NotificationsPage(),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                            _NavTile(
                              icon: Icons.insights_rounded,
                              label: 'nav_panel.progress_report'.tr(),
                              onTap: () {
                                onClose();
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (navigatorContext.mounted) {
                                    Navigator.of(navigatorContext).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ProgressReportScreen(),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                            _ThemeTile(onClose: onClose),
                            _LanguageTile(onClose: onClose),
                            const SizedBox(height: 16),
                            _NavTile(
                              icon: Icons.logout_rounded,
                              label: 'nav_panel.sign_out'.tr(),
                              iconColor: AppColors.primaryGreen,
                              onTap: () {
                                onClose();
                                onSignOut();
                              },
                            ),
                            const SizedBox(height: 8),
                            _NavTile(
                              icon: Icons.delete_forever_rounded,
                              label: 'nav_panel.delete_account'.tr(),
                              iconColor: AppColors.errorRed,
                              onTap: () => _handleDeleteAccount(context),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text(
            'nav_panel.menu'.tr(),
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface, size: 26),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'dashboard.delete_account'.tr(),
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'dashboard.delete_account_message'.tr(),
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr(), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: Text('common.delete'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      onClose();
      await onDeleteAccount();
    }
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final VoidCallback onClose;

  const _ThemeTile({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<ThemeCubit>().toggleTheme();
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      state.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'nav_panel.theme'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    state.isDark ? 'nav_panel.dark'.tr() : 'nav_panel.light'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final VoidCallback onClose;

  const _LanguageTile({required this.onClose});

  static const _locales = [
    ('en', 'English'),
    ('es', 'Español'),
    ('ar', 'العربية'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        final currentCode = localeState.locale.languageCode;
        final currentLabel = _locales.firstWhere(
          (e) => e.$1 == currentCode,
          orElse: () => ('en', 'English'),
        ).$2;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLanguageSheet(context),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Language',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    currentLabel,
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textGray, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDarkLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select language',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ..._locales.map((e) {
                  final isSelected = ctx.read<LocaleCubit>().state.locale.languageCode == e.$1;
                  return ListTile(
                    title: Text(
                      e.$2,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppColors.primaryGreen)
                        : null,
                    onTap: () async {
                      await ctx.read<LocaleCubit>().changeLanguage(e.$1);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      onClose();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
