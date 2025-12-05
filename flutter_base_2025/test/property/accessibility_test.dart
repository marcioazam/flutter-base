import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart';

import 'package:flutter_base_2025/core/theme/accessibility.dart';
import '../helpers/generators.dart';

/// **Feature: flutter-state-of-art-2025-final, Property 12: Theme Contrast Ratio**
/// **Validates: Requirements 11.3**
void main() {
  group('Contrast Ratio Properties', () {
    /// **Property 12: Theme Contrast Ratio**
    /// *For any* foreground/background color pair in the theme, the contrast
    /// ratio should be at least 4.5:1 for WCAG AA.
    test('Black on white meets WCAG AA', () {
      final ratio = AccessibilityUtils.contrastRatio(Colors.black, Colors.white);
      expect(ratio, greaterThanOrEqualTo(AccessibilityUtils.minContrastRatioAA));
      expect(AccessibilityUtils.meetsContrastAA(Colors.black, Colors.white), isTrue);
    });

    test('White on black meets WCAG AA', () {
      final ratio = AccessibilityUtils.contrastRatio(Colors.white, Colors.black);
      expect(ratio, greaterThanOrEqualTo(AccessibilityUtils.minContrastRatioAA));
      expect(AccessibilityUtils.meetsContrastAA(Colors.white, Colors.black), isTrue);
    });

    test('Black on white has maximum contrast ratio of 21', () {
      final ratio = AccessibilityUtils.contrastRatio(Colors.black, Colors.white);
      expect(ratio, closeTo(21.0, 0.1));
    });

    test('Same color has contrast ratio of 1', () {
      final ratio = AccessibilityUtils.contrastRatio(Colors.red, Colors.red);
      expect(ratio, closeTo(1.0, 0.01));
    });

    Glados(any.rgbColor, iterations: 100).test(
      'Contrast ratio is always between 1 and 21',
      (rgb) {
        final (r, g, b) = rgb;
        final color = Color.fromARGB(255, r, g, b);
        
        final ratioWithWhite = AccessibilityUtils.contrastRatio(color, Colors.white);
        final ratioWithBlack = AccessibilityUtils.contrastRatio(color, Colors.black);

        expect(ratioWithWhite, greaterThanOrEqualTo(1.0));
        expect(ratioWithWhite, lessThanOrEqualTo(21.0));
        expect(ratioWithBlack, greaterThanOrEqualTo(1.0));
        expect(ratioWithBlack, lessThanOrEqualTo(21.0));
      },
    );

    Glados(any.rgbColor, iterations: 100).test(
      'ensureContrast returns color meeting minimum ratio',
      (rgb) {
        final (r, g, b) = rgb;
        final background = Color.fromARGB(255, r, g, b);
        final foreground = Color.fromARGB(255, 128, 128, 128);

        final ensured = AccessibilityUtils.ensureContrast(
          foreground,
          background,
          minRatio: AccessibilityUtils.minContrastRatioAA,
        );

        final ratio = AccessibilityUtils.contrastRatio(ensured, background);
        expect(ratio, greaterThanOrEqualTo(AccessibilityUtils.minContrastRatioAA));
      },
    );
  });

  group('Relative Luminance Properties', () {
    test('White has luminance of 1', () {
      final luminance = AccessibilityUtils.relativeLuminance(Colors.white);
      expect(luminance, closeTo(1.0, 0.01));
    });

    test('Black has luminance of 0', () {
      final luminance = AccessibilityUtils.relativeLuminance(Colors.black);
      expect(luminance, closeTo(0.0, 0.01));
    });

    Glados(any.rgbColor, iterations: 100).test(
      'Luminance is always between 0 and 1',
      (rgb) {
        final (r, g, b) = rgb;
        final color = Color.fromARGB(255, r, g, b);
        final luminance = AccessibilityUtils.relativeLuminance(color);

        expect(luminance, greaterThanOrEqualTo(0.0));
        expect(luminance, lessThanOrEqualTo(1.0));
      },
    );
  });

  group('Touch Target Properties', () {
    test('48x48 is valid touch target', () {
      expect(
        AccessibilityUtils.isValidTouchTarget(const Size(48, 48)),
        isTrue,
      );
    });

    test('Smaller than 48x48 is invalid touch target', () {
      expect(
        AccessibilityUtils.isValidTouchTarget(const Size(40, 40)),
        isFalse,
      );
    });

    test('ensureTouchTargetSize returns at least 48x48', () {
      final small = AccessibilityUtils.ensureTouchTargetSize(const Size(20, 20));
      expect(small.width, equals(48.0));
      expect(small.height, equals(48.0));

      final large = AccessibilityUtils.ensureTouchTargetSize(const Size(100, 100));
      expect(large.width, equals(100.0));
      expect(large.height, equals(100.0));
    });

    Glados(
      combine2(
        any.int.map((i) => (i.abs() % 100).toDouble()),
        any.int.map((i) => (i.abs() % 100).toDouble()),
        (w, h) => Size(w, h),
      ),
      iterations: 100,
    ).test(
      'ensureTouchTargetSize always returns valid size',
      (size) {
        final ensured = AccessibilityUtils.ensureTouchTargetSize(size);
        expect(AccessibilityUtils.isValidTouchTarget(ensured), isTrue);
      },
    );
  });

  group('Semantic Colors', () {
    test('Light semantic colors have sufficient contrast', () {
      final colors = SemanticColors.light();

      expect(
        AccessibilityUtils.meetsContrastAA(
          colors.successOnSurface,
          colors.success,
        ),
        isTrue,
      );
      expect(
        AccessibilityUtils.meetsContrastAA(
          colors.errorOnSurface,
          colors.error,
        ),
        isTrue,
      );
      expect(
        AccessibilityUtils.meetsContrastAA(
          colors.infoOnSurface,
          colors.info,
        ),
        isTrue,
      );
    });

    test('Dark semantic colors have sufficient contrast', () {
      final colors = SemanticColors.dark();

      expect(
        AccessibilityUtils.meetsContrastAA(
          colors.successOnSurface,
          colors.success,
        ),
        isTrue,
      );
      expect(
        AccessibilityUtils.meetsContrastAA(
          colors.errorOnSurface,
          colors.error,
        ),
        isTrue,
      );
      expect(
        AccessibilityUtils.meetsContrastAA(
          colors.infoOnSurface,
          colors.info,
        ),
        isTrue,
      );
    });
  });
}
