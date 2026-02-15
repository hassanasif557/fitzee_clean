/// App entry point. Initializes Firebase, Crashlytics, notifications, Stripe, EasyLocalization,
/// and SQLite (Drift) for offline-first. SQLite is the source of truth; Firebase syncs when online.
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitzee_new/core/database/database_provider.dart';
import 'package:fitzee_new/core/routes/app_router.dart';
import 'package:fitzee_new/core/constants/theme_config.dart';
import 'package:fitzee_new/core/services/crashlytics_service.dart';
import 'package:fitzee_new/core/services/notification_service.dart';
import 'package:fitzee_new/core/utils/theme_cubit.dart';
import 'package:fitzee_new/core/utils/locale_cubit.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/services/ai_meal_service.dart';
import 'firebase_options.dart';

String publishedKey = "pk_test_51Stnr9QpjDOMmIK5OiW5L3QHFFeJqZRfuDpvHljZpn5bC5vqI4wuNZLztxweFONAGVRUKA91oc4ygGlV9XFftMpm00BHciDKQO";
String secretKey = "REMOVED";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await CrashlyticsService.init();
  await NotificationService.init();
  NotificationService.setupForegroundHandler();
  await Future.any([
    NotificationService.refreshTokenForCurrentUser(),
    Future.delayed(const Duration(seconds: 5), () {}),
  ]);
  await EasyLocalization.ensureInitialized();
  try {
    await initDatabase();
  } catch (e) {
    assert(false, 'Database init failed: $e');
  }

  Stripe.publishableKey = publishedKey;
  await Stripe.instance.applySettings();




  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<LocaleCubit>(
          // Pass null to let LocaleCubit load from SharedPreferences
          // It will default to 'en' if no saved locale exists
          // This avoids accessing EasyLocalization during provider creation
          create: (_) => LocaleCubit(initialLocale: null),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocListener<LocaleCubit, LocaleState>(
            listener: (context, localeState) {
              // Sync EasyLocalization with saved locale from SharedPreferences
              // This listener runs after LocaleCubit loads, so it's safe
              if (context.mounted) {
                context.setLocale(localeState.locale);
              }
            },
            child: BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, localeState) {
                return MaterialApp.router(
                  title: 'Fitzee',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeConfig.lightTheme,
                  darkTheme: ThemeConfig.darkTheme,
                  themeMode: themeState.isDark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: localeState.locale,
                  routerConfig: AppRouter.router,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
