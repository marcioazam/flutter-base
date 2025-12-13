import 'dart:ui';

import 'package:flutter_base_2025/core/constants/app_constants.dart';
import 'package:flutter_base_2025/shared/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for current locale using Riverpod 3.0 Notifier pattern.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

/// Notifier for locale state using Riverpod 3.0 pattern.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _loadLocale(prefs);
  }

  static Locale _loadLocale(SharedPreferences prefs) {
    final value = prefs.getString(StorageKeys.locale);
    if (value != null && AppConstants.supportedLocales.contains(value)) {
      return Locale(value);
    }
    return Locale(AppConstants.defaultLocale);
  }

  Future<void> setLocale(Locale locale) async {
    if (AppConstants.supportedLocales.contains(locale.languageCode)) {
      state = locale;
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(StorageKeys.locale, locale.languageCode);
    }
  }

  Future<void> setLocaleByCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }
}
