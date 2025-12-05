import 'dart:ui';

import 'package:flutter_base_2025/core/constants/app_constants.dart';
import 'package:flutter_base_2025/shared/providers/locale_provider.dart';
import 'package:flutter_base_2025/shared/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **Feature: flutter-modernization-2025, Property 8: Locale Change String Update**
/// **Validates: Requirements 16.2**

void main() {
  group('Locale Change String Update Properties', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('LocaleNotifier initializes with default locale', () {
      final locale = container.read(localeProvider);
      expect(locale.languageCode, equals(AppConstants.defaultLocale));
    });

    test('LocaleNotifier loads saved locale from preferences', () async {
      SharedPreferences.setMockInitialValues({'locale': 'pt'});
      final savedPrefs = await SharedPreferences.getInstance();
      final testContainer = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(savedPrefs),
        ],
      );
      addTearDown(testContainer.dispose);

      final locale = testContainer.read(localeProvider);
      expect(locale.languageCode, equals('pt'));
    });

    test('setLocale updates state immediately', () async {
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('pt'));

      expect(container.read(localeProvider).languageCode, equals('pt'));
    });

    test('setLocale persists to SharedPreferences', () async {
      final notifier = container.read(localeProvider.notifier);
      final prefs = container.read(sharedPreferencesProvider);

      await notifier.setLocale(const Locale('pt'));

      expect(prefs.getString('locale'), equals('pt'));
    });

    test('setLocaleByCode updates locale correctly', () async {
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocaleByCode('pt');

      expect(container.read(localeProvider).languageCode, equals('pt'));
    });

    test('locale change is immediate without restart', () async {
      final notifier = container.read(localeProvider.notifier);
      final states = <Locale>[];

      // Track state changes using listen
      container.listen(
        localeProvider,
        (_, next) => states.add(next),
        fireImmediately: false,
      );

      await notifier.setLocale(const Locale('pt'));
      await notifier.setLocale(const Locale('en'));
      await notifier.setLocale(const Locale('pt'));

      expect(states.length, equals(3));
      expect(states[0].languageCode, equals('pt'));
      expect(states[1].languageCode, equals('en'));
      expect(states[2].languageCode, equals('pt'));
    });

    test('unsupported locale is rejected', () async {
      final notifier = container.read(localeProvider.notifier);
      final initialLocale = container.read(localeProvider);

      await notifier.setLocale(const Locale('xx'));

      // Should remain unchanged
      expect(
        container.read(localeProvider).languageCode,
        equals(initialLocale.languageCode),
      );
    });

    test('supported locales are accepted', () async {
      final notifier = container.read(localeProvider.notifier);

      for (final code in AppConstants.supportedLocales) {
        await notifier.setLocaleByCode(code);
        expect(container.read(localeProvider).languageCode, equals(code));
      }
    });
  });
}
