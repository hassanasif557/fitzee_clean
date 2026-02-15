/// Shell for the main app: bottom navigation (dashboard, consultants, appointments, history, leaderboard).
/// Wraps [child] with [Scaffold] and [BottomNavigationBar]; [child] is the current route content.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/theme_ext.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/consultant_directory')) return 1;
    if (location.startsWith('/my_appointments')) return 2;
    if (location.startsWith('/history')) return 3;
    if (location.startsWith('/leaderboard')) return 4;
    return 0; // dashboard
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getIndex(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.themeScaffoldBg,
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/consultant_directory');
              break;
            case 2:
              context.go('/my_appointments');
              break;
            case 3:
              context.go('/history');
              break;
            case 4:
              context.go('/leaderboard');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'nav.dashboard'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.medical_services),
            label: 'nav.consultants'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_available),
            label: 'nav.appointments'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: 'nav.history'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.leaderboard),
            label: 'nav.leaderboard'.tr(),
          ),
        ],
      ),
    );
  }
}
