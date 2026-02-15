/// Global locale state. Loads/saves locale and syncs with EasyLocalization for app language.
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit({Locale? initialLocale}) : super(LocaleState(locale: initialLocale ?? const Locale('en'))) {
    _loadLocale(initialLocale);
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadLocale(Locale? initialLocale) async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    
    if (localeCode != null) {
      emit(LocaleState(locale: Locale(localeCode)));
    } else if (initialLocale != null) {
      emit(LocaleState(locale: initialLocale));
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    emit(LocaleState(locale: locale));
  }

  Future<void> changeLanguage(String languageCode) async {
    final locale = Locale(languageCode);
    await setLocale(locale);
  }
}

