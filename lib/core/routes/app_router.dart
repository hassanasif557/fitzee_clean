/// Central routing configuration (GoRouter). Defines splash, auth, onboard, and main shell routes.
/// [CrashlyticsRouteObserver] tracks screen changes for crash reports.
import 'package:fitzee_new/features/consultants/presentation/pages/my_appointments_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/core/routes/crashlytics_route_observer.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/cubit/onboard_cubit.dart';
import 'package:fitzee_new/features/auth/presentation/pages/phone_auth/phone_number_screen.dart';
import 'package:fitzee_new/features/auth/presentation/pages/phone_auth/otp_screen.dart';
import 'package:fitzee_new/features/splash/presentation/pages/splash_page.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard_page.dart';
import 'package:fitzee_new/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:fitzee_new/features/dashboard/presentation/pages/history_page.dart';
import 'package:fitzee_new/features/leaderboard/presentation/pages/leaderboard_page.dart';

import '../../features/consultants/presentation/pages/consultant_directory_page.dart';
import '../../main_shell.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboard = '/onboard';
  static const String phoneAuth = '/phone_auth';
  static const String otp = '/otp';

  static const String dashboard = '/dashboard';
  static const String leaderboard = '/leaderboard';
  static const String consultantDirectory = '/consultant_directory';
  static const String myAppointments = '/my_appointments';
  static const String history = '/history';

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: splash,
    observers: [CrashlyticsRouteObserver()],
    routes: [
      /// --------------------
      /// AUTH / ONBOARDING (NO BOTTOM NAV)
      /// --------------------
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: onboard,
        name: 'onboard',
        builder: (context, state) => BlocProvider(
          create: (_) => OnboardCubit(),
          child: const OnboardPage(),
        ),
      ),
      GoRoute(
        path: phoneAuth,
        name: 'phone_auth',
        builder: (context, state) => const PhoneNumberScreen(),
      ),
      GoRoute(
        path: otp,
        name: 'otp',
        builder: (context, state) {
          final verificationId = state.extra as String? ?? '';
          return OtpScreen(verificationId: verificationId);
        },
      ),

      /// --------------------
      /// MAIN APP (WITH BOTTOM NAV)
      /// --------------------
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child); // 👈 Bottom Nav Scaffold
        },
        routes: [
          GoRoute(
            path: dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: consultantDirectory,
            name: 'consultant_directory',
            builder: (context, state) => ConsultantDirectoryPage(),
          ),
          GoRoute(
            path: myAppointments,
            name: 'my_appointments',
            builder: (context, state) => MyAppointmentsPage(),
          ),
          GoRoute(
            path: history,
            name: 'history',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: leaderboard,
            name: 'leaderboard',
            builder: (context, state) => const LeaderboardPage(),
          ),
        ],
      ),
    ],
  );
}


