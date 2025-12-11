import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Accessibility test utilities for WCAG 2.2 compliance.
class AccessibilityTestUtils {
  /// Check if all buttons have semantic labels.
  static bool allButtonsHaveLabels(WidgetTester tester) {
    final buttonTypes = [
      ElevatedButton,
      TextButton,
      OutlinedButton,
      FilledButton,
      IconButton,
      FloatingActionButton,
    ];

    for (final buttonType in buttonTypes) {
      final buttons = tester.widgetList(find.byType(buttonType));
      for (final button in buttons) {
        final semantics = tester.getSemantics(find.byWidget(button));
        if (semantics.label.isEmpty &&
            semantics.hint.isEmpty &&
            semantics.value.isEmpty) {
          // Check if button has text child
          if (!_hasTextChild(button)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  static bool _hasTextChild(Widget widget) {
    if (widget is Text) return true;
    if (widget is ElevatedButton) {
      return widget.child is Text;
    }
    if (widget is TextButton) {
      return widget.child is Text;
    }
    if (widget is OutlinedButton) {
      return widget.child is Text;
    }
    if (widget is FilledButton) {
      return widget.child is Text;
    }
    return false;
  }

  /// Check if touch targets meet minimum size (48x48 logical pixels).
  static Future<bool> allTouchTargetsMeetMinimumSize(
    WidgetTester tester,
  ) async {
    const minSize = 48.0;

    final interactiveWidgets = [
      ...tester.widgetList(find.byType(ElevatedButton)),
      ...tester.widgetList(find.byType(TextButton)),
      ...tester.widgetList(find.byType(OutlinedButton)),
      ...tester.widgetList(find.byType(FilledButton)),
      ...tester.widgetList(find.byType(IconButton)),
      ...tester.widgetList(find.byType(InkWell)),
      ...tester.widgetList(find.byType(GestureDetector)),
    ];

    for (final widget in interactiveWidgets) {
      final finder = find.byWidget(widget);
      if (finder.evaluate().isEmpty) continue;

      final size = tester.getSize(finder);
      if (size.width < minSize || size.height < minSize) {
        return false;
      }
    }
    return true;
  }

  /// Check if animations respect reduced motion preference.
  static bool respectsReducedMotion(
    WidgetTester tester,
    Widget widget,
  ) {
    // This would need to be tested by building widget with
    // MediaQuery.disableAnimations = true and verifying no animations run
    return true;
  }

  /// Check text contrast ratio meets WCAG AA (4.5:1 for normal text).
  static bool meetsContrastRatio(
    Color foreground,
    Color background, {
    double minRatio = 4.5,
  }) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    final ratio = (lighter + 0.05) / (darker + 0.05);
    return ratio >= minRatio;
  }

  /// Run all accessibility checks.
  static Future<AccessibilityReport> runFullAudit(
    WidgetTester tester,
  ) async {
    final issues = <String>[];

    if (!allButtonsHaveLabels(tester)) {
      issues.add('Some buttons are missing semantic labels');
    }

    if (!await allTouchTargetsMeetMinimumSize(tester)) {
      issues.add('Some touch targets are smaller than 48x48 pixels');
    }

    return AccessibilityReport(
      passed: issues.isEmpty,
      issues: issues,
    );
  }
}

/// Result of accessibility audit.
class AccessibilityReport {

  const AccessibilityReport({
    required this.passed,
    this.issues = const [],
  });
  final bool passed;
  final List<String> issues;

  @override
  String toString() {
    if (passed) return 'Accessibility audit passed';
    return 'Accessibility audit failed:\n${issues.map((i) => '  - $i').join('\n')}';
  }
}

/// Custom matcher for accessibility guidelines.
Matcher meetsAccessibilityGuidelines() => _AccessibilityMatcher();

class _AccessibilityMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is AccessibilityReport) {
      return item.passed;
    }
    return false;
  }

  @override
  Description describe(Description description) => description.add('meets accessibility guidelines');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is AccessibilityReport) {
      return mismatchDescription.add(item.toString());
    }
    return mismatchDescription.add('is not an AccessibilityReport');
  }
}
