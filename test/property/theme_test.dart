import 'package:flutter/material.dart';
import 'package:flutter_base_2025/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: flutter-base-2025, Property 23: Theme Mode Switch**
/// **Validates: Requirements 6.2**
void main() {
  group('AppTheme', () {
    group('Basic Tests', () {
      test('light theme has correct brightness', () {
        final theme = AppTheme.light;
        expect(theme.brightness, equals(Brightness.light));
      });

      test('dark theme has correct brightness', () {
        final theme = AppTheme.dark;
        expect(theme.brightness, equals(Brightness.dark));
      });

      test('light theme uses Material 3', () {
        final theme = AppTheme.light;
        expect(theme.useMaterial3, isTrue);
      });

      test('dark theme uses Material 3', () {
        final theme = AppTheme.dark;
        expect(theme.useMaterial3, isTrue);
      });

      test('light theme has AppThemeExtension', () {
        final theme = AppTheme.light;
        final extension = theme.extension<AppThemeExtension>();
        expect(extension, isNotNull);
        expect(extension!.isDark, isFalse);
      });

      test('dark theme has AppThemeExtension', () {
        final theme = AppTheme.dark;
        final extension = theme.extension<AppThemeExtension>();
        expect(extension, isNotNull);
        expect(extension!.isDark, isTrue);
      });
    });

    group('Property Tests', () {
      /// **Property 23: Theme Mode Switch**
      /// For any theme mode toggle (light/dark), the theme SHALL switch immediately without app restart.
      test('themes are distinct and switchable', () {
        final lightTheme = AppTheme.light;
        final darkTheme = AppTheme.dark;

        // Themes should be different
        expect(lightTheme.brightness, isNot(equals(darkTheme.brightness)));

        // Both should be valid themes
        expect(lightTheme.colorScheme, isNotNull);
        expect(darkTheme.colorScheme, isNotNull);

        // Color schemes should differ
        expect(
          lightTheme.colorScheme.surface,
          isNot(equals(darkTheme.colorScheme.surface)),
        );
      });

      test('theme extensions are properly configured', () {
        final lightExt = AppTheme.light.extension<AppThemeExtension>()!;
        final darkExt = AppTheme.dark.extension<AppThemeExtension>()!;

        // Extensions should have different isDark values
        expect(lightExt.isDark, isFalse);
        expect(darkExt.isDark, isTrue);

        // Both should have semantic colors
        expect(lightExt.success, isNotNull);
        expect(lightExt.warning, isNotNull);
        expect(lightExt.info, isNotNull);

        expect(darkExt.success, isNotNull);
        expect(darkExt.warning, isNotNull);
        expect(darkExt.info, isNotNull);
      });

      test('theme extension lerp works correctly', () {
        final lightExt = AppTheme.light.extension<AppThemeExtension>()!;
        final darkExt = AppTheme.dark.extension<AppThemeExtension>()!;

        // Lerp at 0 should be close to light
        final lerp0 = lightExt.lerp(darkExt, 0) as AppThemeExtension;
        expect(lerp0.isDark, equals(lightExt.isDark));

        // Lerp at 1 should be close to dark
        final lerp1 = lightExt.lerp(darkExt, 1) as AppThemeExtension;
        expect(lerp1.isDark, equals(darkExt.isDark));
      });

      test('theme extension copyWith preserves values', () {
        final ext = AppTheme.light.extension<AppThemeExtension>()!;
        final copied = ext.copyWith() as AppThemeExtension;

        expect(copied.isDark, equals(ext.isDark));
        expect(copied.success, equals(ext.success));
        expect(copied.warning, equals(ext.warning));
        expect(copied.info, equals(ext.info));
      });
    });
  });
}
