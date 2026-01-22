import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitzee_new/core/routes/app_router.dart';
import 'package:fitzee_new/core/constants/theme_config.dart';
import 'package:fitzee_new/core/utils/theme_cubit.dart';
import 'package:fitzee_new/core/utils/locale_cubit.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

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
