import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_base_2025/shared/providers/locale_provider.dart';

/// **Feature: flutter-modernization-2025, Property 8: Locale Change String Update**
/// **Validates: Requirements 16.2**

void main() {
  group('Locale Change String Update Properties', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('LocaleNotifier initializes with default locale', () {
      final notifier = LocaleNotifier(prefs);

      expect(notifier.state.languageCode, equals('en'));
    });

    test('LocaleNotifier loads saved locale from preferences', () async {
      SharedPreferences.setMockInitialValues({'locale': 'pt'});
      final savedPrefs = await SharedPreferences.getInstance();
      final notifier = LocaleNotifier(savedPrefs);

      expect(notifier.state.languageCode, equals('pt'));
    });

    test('setLocale updates state immediately', () async {
      final notifier = LocaleNotifier(prefs);

      await notifier.setLocale(const Locale('pt'));

      expect(notifier.state.languageCode, equals('pt'));
    });

    test('setLocale persists to SharedPreferences', () async {
      final notifier = LocaleNotifier(prefs);

      await notifier.setLocale(const Locale('pt'));

      expect(prefs.getString('locale'), equals('pt'));
    });

    test('setLocaleByCode updates locale correctly', () async {
      final notifier = LocaleNotifier(prefs);

      await notifier.setLocaleByCode('pt');

      expect(notifier.state.languageCode, equals('pt'));
    });

    test('locale change is immediate without restart', () async {
      final notifier = LocaleNotifier(prefs);
      final states = <Locale>[];

      // Track state changes
      notifier.addListener(() {
        states.add(notifier.state);
      });

      await notifier.setLocale(const Locale('pt'));
      await notifier.setLocale(const Locale('en'));
      await notifier.setLocale(const Locale('pt'));

      expect(states.length, equals(3));
      expect(states[0].languageCode, equals('pt'));
      expect(states[1].languageCode, equals('en'));
      expect(states[2].languageCode, equals('pt'));
    });

    test('invalid locale is rejected', () async {
      final notifier = LocaleNotifier(prefs);

      // Try to set unsupported locale
      await notifier.setLocale(const Locale('xx'));

      // Should remain at default
      expect(notifier.state.languageCode, equals('en'));
    });

    test('supported locales are accepted', () async {
      final notifier = LocaleNotifier(prefs);

      // English
      await notifier.setLocale(const Locale('en'));
      expect(notifier.state.languageCode, equals('en'));

      // Portuguese
      await notifier.setLocale(const Locale('pt'));
      expect(notifier.state.languageCode, equals('pt'));
    });

    test('locale persists across notifier instances', () async {
      final notifier1 = LocaleNotifier(prefs);
      await notifier1.setLocale(const Locale('pt'));

      // Create new notifier with same prefs
      final notifier2 = LocaleNotifier(prefs);

      expect(notifier2.state.languageCode, equals('pt'));
    });

    test('multiple rapid locale changes work correctly', () async {
      final notifier = LocaleNotifier(prefs);

      // Rapid changes
      await notifier.setLocale(const Locale('pt'));
      await notifier.setLocale(const Locale('en'));
      await notifier.setLocale(const Locale('pt'));
      await notifier.setLocale(const Locale('en'));

      // Final state should be 'en'
      expect(notifier.state.languageCode, equals('en'));
      expect(prefs.getString('locale'), equals('en'));
    });
  });
}
