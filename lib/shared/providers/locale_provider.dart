import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'theme_provider.dart';

/// Provider for current locale.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

/// Notifier for locale state.
class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_loadLocale(_prefs));

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
      await _prefs.setString(StorageKeys.locale, locale.languageCode);
    }
  }

  Future<void> setLocaleByCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }
}
