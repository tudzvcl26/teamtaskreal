import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  static const _localeKey = 'app_locale';

  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('vi'));

  static const supportedLocales = [Locale('vi'), Locale('en'), Locale('ja')];

  static Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);

    if (languageCode == null) return;

    locale.value = _localeFromCode(languageCode);
  }

  static Future<void> setLocale(Locale newLocale) async {
    locale.value = _localeFromCode(newLocale.languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.value.languageCode);
  }

  static Locale _localeFromCode(String languageCode) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => const Locale('vi'),
    );
  }
}
