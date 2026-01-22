import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/features/auth/presentation/pages/phone_auth/phone_number_screen.dart';
import 'package:fitzee_new/features/auth/presentation/pages/phone_auth/otp_screen.dart';
import 'package:fitzee_new/features/splash/presentation/pages/splash_page.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard_page.dart';
import 'package:fitzee_new/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:fitzee_new/features/leaderboard/presentation/pages/leaderboard_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboard = '/onboard';
  static const String phoneAuth = '/phone_auth';
  static const String otp = '/otp';
  static const String dashboard = '/dashboard';
  static const String leaderboard = '/leaderboard';

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: onboard,
        name: 'onboard',
        builder: (context, state) => const OnboardPage(),
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
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: leaderboard,
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardPage(),
      ),
    ],
  );
}

