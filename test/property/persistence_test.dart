import 'package:flutter_base_2025/core/storage/persistence_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glados_helpers.dart';

/// Generator for UserPreferences.
extension UserPreferencesGenerator on Any {
  Generator<UserPreferences> get userPreferences => combine4(
    choose(['light', 'dark', 'system']),
    choose(['en', 'pt', 'es', 'fr']),
    any.bool,
    doubleInRange(10, 24),
    (theme, locale, notifications, fontSize) => UserPreferences(
      theme: theme,
      locale: locale,
      notificationsEnabled: notifications,
      fontSize: fontSize,
    ),
  );
}

void main() {
  group('Persistence Property Tests', () {
    /// **Feature: flutter-2025-final-enhancements, Property 2: Persistence Round-Trip**
    /// **Validates: Requirements 2.3**
    Glados(
      any.userPreferences,
    ).test('UserPreferences JSON round-trip preserves data', (prefs) {
      final json = prefs.toJson();
      final restored = UserPreferences.fromJson(json);

      expect(restored.theme, equals(prefs.theme));
      expect(restored.locale, equals(prefs.locale));
      expect(restored.notificationsEnabled, equals(prefs.notificationsEnabled));
      expect(restored.fontSize, equals(prefs.fontSize));
      expect(restored, equals(prefs));
    });

    Glados(any.userPreferences).test('UserPreferences equality is consistent', (
      prefs,
    ) {
      final copy = UserPreferences(
        theme: prefs.theme,
        locale: prefs.locale,
        notificationsEnabled: prefs.notificationsEnabled,
        fontSize: prefs.fontSize,
      );

      expect(prefs, equals(copy));
      expect(prefs.hashCode, equals(copy.hashCode));
    });

    /// **Feature: flutter-2025-final-enhancements, Property 3: Persistence Restoration**
    /// **Validates: Requirements 2.4**
    test('UserPreferences.fromJson handles missing fields with defaults', () {
      final prefs = UserPreferences.fromJson({});

      expect(prefs.theme, equals('system'));
      expect(prefs.locale, equals('en'));
      expect(prefs.notificationsEnabled, isTrue);
      expect(prefs.fontSize, equals(14.0));
    });

    test('UserPreferences.fromJson handles partial data', () {
      final prefs = UserPreferences.fromJson({'theme': 'dark', 'locale': 'pt'});

      expect(prefs.theme, equals('dark'));
      expect(prefs.locale, equals('pt'));
      expect(prefs.notificationsEnabled, isTrue); // default
      expect(prefs.fontSize, equals(14.0)); // default
    });
  });
}
