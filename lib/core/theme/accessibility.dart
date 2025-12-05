import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Accessibility utilities for WCAG compliance.
abstract final class AccessibilityUtils {
  /// Minimum touch target size per WCAG (48x48 logical pixels).
  static const double minTouchTargetSize = 48.0;

  /// Minimum contrast ratio for normal text (WCAG AA).
  static const double minContrastRatioAA = 4.5;

  /// Minimum contrast ratio for large text (WCAG AA).
  static const double minContrastRatioLargeTextAA = 3.0;

  /// Minimum contrast ratio for enhanced (WCAG AAA).
  static const double minContrastRatioAAA = 7.0;

  /// Calculates relative luminance of a color.
  /// Based on WCAG 2.1 formula.
  static double relativeLuminance(Color color) {
    double linearize(int component) {
      final sRGB = component / 255.0;
      return sRGB <= 0.03928
          ? sRGB / 12.92
          : math.pow((sRGB + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = linearize(color.red);
    final g = linearize(color.green);
    final b = linearize(color.blue);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculates contrast ratio between two colors.
  /// Returns value between 1 and 21.
  static double contrastRatio(Color foreground, Color background) {
    final l1 = relativeLuminance(foreground);
    final l2 = relativeLuminance(background);

    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Checks if contrast ratio meets WCAG AA for normal text.
  static bool meetsContrastAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastRatioAA;
  }

  /// Checks if contrast ratio meets WCAG AA for large text.
  static bool meetsContrastAALargeText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastRatioLargeTextAA;
  }

  /// Checks if contrast ratio meets WCAG AAA.
  static bool meetsContrastAAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastRatioAAA;
  }

  /// Returns a color that meets contrast requirements against background.
  static Color ensureContrast(
    Color foreground,
    Color background, {
    double minRatio = minContrastRatioAA,
  }) {
    if (contrastRatio(foreground, background) >= minRatio) {
      return foreground;
    }

    // Try black or white
    final blackContrast = contrastRatio(Colors.black, background);
    final whiteContrast = contrastRatio(Colors.white, background);

    return blackContrast > whiteContrast ? Colors.black : Colors.white;
  }

  /// Validates touch target size.
  static bool isValidTouchTarget(Size size) {
    return size.width >= minTouchTargetSize &&
        size.height >= minTouchTargetSize;
  }

  /// Returns minimum size needed for touch target.
  static Size ensureTouchTargetSize(Size size) {
    return Size(
      math.max(size.width, minTouchTargetSize),
      math.max(size.height, minTouchTargetSize),
    );
  }
}

/// Semantic color tokens for accessibility.
class SemanticColors {
  final Color success;
  final Color successOnSurface;
  final Color warning;
  final Color warningOnSurface;
  final Color error;
  final Color errorOnSurface;
  final Color info;
  final Color infoOnSurface;

  const SemanticColors({
    required this.success,
    required this.successOnSurface,
    required this.warning,
    required this.warningOnSurface,
    required this.error,
    required this.errorOnSurface,
    required this.info,
    required this.infoOnSurface,
  });

  /// Creates semantic colors for light theme.
  factory SemanticColors.light() => const SemanticColors(
        success: Color(0xFF2E7D32),
        successOnSurface: Colors.white,
        warning: Color(0xFFED6C02),
        warningOnSurface: Colors.black,
        error: Color(0xFFD32F2F),
        errorOnSurface: Colors.white,
        info: Color(0xFF0288D1),
        infoOnSurface: Colors.white,
      );

  /// Creates semantic colors for dark theme.
  factory SemanticColors.dark() => const SemanticColors(
        success: Color(0xFF66BB6A),
        successOnSurface: Colors.black,
        warning: Color(0xFFFFA726),
        warningOnSurface: Colors.black,
        error: Color(0xFFEF5350),
        errorOnSurface: Colors.black,
        info: Color(0xFF29B6F6),
        infoOnSurface: Colors.black,
      );
}

/// Extension for easy semantic label access.
extension SemanticsExtension on Widget {
  /// Wraps widget with semantic label.
  Widget withSemanticLabel(String label) {
    return Semantics(
      label: label,
      child: this,
    );
  }

  /// Wraps widget as a button with label.
  Widget asSemanticButton(String label, {VoidCallback? onTap}) {
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: this,
    );
  }

  /// Wraps widget as a header.
  Widget asSemanticHeader(String label) {
    return Semantics(
      header: true,
      label: label,
      child: this,
    );
  }

  /// Excludes widget from semantics tree.
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }
}

/// Widget that ensures minimum touch target size.
class TouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minSize;

  const TouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minSize = AccessibilityUtils.minTouchTargetSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: Center(child: child),
      ),
    );
  }
}
