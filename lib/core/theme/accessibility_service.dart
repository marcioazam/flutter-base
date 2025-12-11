import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Abstract interface for accessibility utilities.
///
/// Provides WCAG 2.1 compliance methods for:
/// - Contrast ratio calculation
/// - Touch target size validation
/// - Color accessibility validation
///
/// **Accessibility Context:**
/// - WCAG 2.1 Level AA Compliance
/// - WCAG 2.1 Level AAA Compliance
/// - Section 508 Standards
abstract interface class AccessibilityService {
  /// Minimum touch target size per WCAG (48x48 logical pixels).
  static const double minTouchTargetSize = 48;

  /// Minimum contrast ratio for normal text (WCAG AA).
  static const double minContrastRatioAA = 4.5;

  /// Minimum contrast ratio for large text (WCAG AA).
  static const double minContrastRatioLargeTextAA = 3;

  /// Minimum contrast ratio for enhanced (WCAG AAA).
  static const double minContrastRatioAAA = 7;

  /// Calculates relative luminance of a color.
  ///
  /// Based on WCAG 2.1 formula for relative luminance:
  /// L = 0.2126 * R + 0.7152 * G + 0.0722 * B
  ///
  /// Where R, G, and B are linearized RGB components.
  ///
  /// **Reference:**
  /// https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
  ///
  /// Returns a value between 0 (black) and 1 (white).
  double relativeLuminance(Color color);

  /// Calculates contrast ratio between two colors.
  ///
  /// Based on WCAG 2.1 formula:
  /// Contrast Ratio = (L1 + 0.05) / (L2 + 0.05)
  ///
  /// Where L1 is the lighter luminance and L2 is the darker luminance.
  ///
  /// **Reference:**
  /// https://www.w3.org/TR/WCAG21/#dfn-contrast-ratio
  ///
  /// Returns value between 1 (no contrast) and 21 (maximum contrast).
  double contrastRatio(Color foreground, Color background);

  /// Checks if contrast ratio meets WCAG AA for normal text (4.5:1).
  ///
  /// **WCAG Requirement:**
  /// - Normal text: 4.5:1
  /// - Font size: < 18pt regular or < 14pt bold
  bool meetsContrastAA(Color foreground, Color background);

  /// Checks if contrast ratio meets WCAG AA for large text (3:1).
  ///
  /// **WCAG Requirement:**
  /// - Large text: 3:1
  /// - Font size: >= 18pt regular or >= 14pt bold
  bool meetsContrastAALargeText(Color foreground, Color background);

  /// Checks if contrast ratio meets WCAG AAA (7:1).
  ///
  /// **WCAG Requirement:**
  /// - Enhanced contrast: 7:1
  /// - Recommended for users with vision impairments
  bool meetsContrastAAA(Color foreground, Color background);

  /// Returns a color that meets contrast requirements against background.
  ///
  /// If the foreground color already meets the minimum ratio, returns it unchanged.
  /// Otherwise, returns either black or white (whichever has better contrast).
  ///
  /// **Parameters:**
  /// - `foreground`: Original foreground color
  /// - `background`: Background color
  /// - `minRatio`: Minimum contrast ratio (default: 4.5 for WCAG AA)
  ///
  /// Returns a color that meets the minimum contrast ratio.
  Color ensureContrast(
    Color foreground,
    Color background, {
    double minRatio = minContrastRatioAA,
  });

  /// Validates touch target size meets WCAG requirements.
  ///
  /// **WCAG 2.5.5 Target Size (Level AAA):**
  /// - Minimum 44x44 CSS pixels (we use 48x48 for safety margin)
  ///
  /// Returns true if size meets minimum requirements.
  bool isValidTouchTarget(Size size);

  /// Returns minimum size needed for touch target.
  ///
  /// Ensures the returned size meets WCAG touch target requirements
  /// by expanding to 48x48 if the input is smaller.
  ///
  /// Returns a size that is at least 48x48.
  Size ensureTouchTargetSize(Size size);
}

/// Default implementation of AccessibilityService.
///
/// This implementation provides WCAG 2.1 compliant accessibility utilities
/// for contrast validation and touch target sizing.
///
/// **Thread Safety:** This class is immutable and thread-safe.
class DefaultAccessibilityService implements AccessibilityService {
  /// Creates a const instance of DefaultAccessibilityService.
  const DefaultAccessibilityService();

  @override
  double relativeLuminance(Color color) {
    double linearize(int component) {
      final sRGB = component / 255.0;
      return sRGB <= 0.03928
          ? sRGB / 12.92
          : math.pow((sRGB + 0.055) / 1.055, 2.4).toDouble();
    }

    // Updated to use non-deprecated API
    final r = linearize((color.r * 255.0).round().clamp(0, 255));
    final g = linearize((color.g * 255.0).round().clamp(0, 255));
    final b = linearize((color.b * 255.0).round().clamp(0, 255));

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  @override
  double contrastRatio(Color foreground, Color background) {
    final l1 = relativeLuminance(foreground);
    final l2 = relativeLuminance(background);

    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  @override
  bool meetsContrastAA(Color foreground, Color background) =>
      contrastRatio(foreground, background) >=
      AccessibilityService.minContrastRatioAA;

  @override
  bool meetsContrastAALargeText(Color foreground, Color background) =>
      contrastRatio(foreground, background) >=
      AccessibilityService.minContrastRatioLargeTextAA;

  @override
  bool meetsContrastAAA(Color foreground, Color background) =>
      contrastRatio(foreground, background) >=
      AccessibilityService.minContrastRatioAAA;

  @override
  Color ensureContrast(
    Color foreground,
    Color background, {
    double minRatio = AccessibilityService.minContrastRatioAA,
  }) {
    if (contrastRatio(foreground, background) >= minRatio) {
      return foreground;
    }

    // Try black or white
    final blackContrast = contrastRatio(Colors.black, background);
    final whiteContrast = contrastRatio(Colors.white, background);

    return blackContrast > whiteContrast ? Colors.black : Colors.white;
  }

  @override
  bool isValidTouchTarget(Size size) =>
      size.width >= AccessibilityService.minTouchTargetSize &&
      size.height >= AccessibilityService.minTouchTargetSize;

  @override
  Size ensureTouchTargetSize(Size size) => Size(
        math.max(size.width, AccessibilityService.minTouchTargetSize),
        math.max(size.height, AccessibilityService.minTouchTargetSize),
      );
}
