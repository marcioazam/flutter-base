import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Minimum touch target size per WCAG guidelines.
const double kMinTouchTargetSize = 48.0;

// Widget Previewer annotations for IDE preview support (Flutter 3.38+)
// @Preview(name: 'Default', width: 200, height: 100)
// @Preview(name: 'Dark Theme', width: 200, height: 100, theme: ThemeMode.dark)

/// Accessible button that ensures minimum touch target size.
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.minWidth = kMinTouchTargetSize,
    this.minHeight = kMinTouchTargetSize,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final double minWidth;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    Widget button = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: minHeight,
      ),
      child: child,
    );

    if (semanticLabel != null && !excludeFromSemantics) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: onPressed != null,
        child: button,
      );
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: button,
    );
  }
}

/// Accessible icon button with tooltip and semantics.
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 24.0,
    this.color,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      button: true,
      enabled: onPressed != null,
      child: IconButton(
        icon: Icon(icon, size: size, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints(
          minWidth: kMinTouchTargetSize,
          minHeight: kMinTouchTargetSize,
        ),
      ),
    );
  }
}

/// Accessible image with semantic label.
class AccessibleImage extends StatelessWidget {
  const AccessibleImage({
    required this.image,
    required this.semanticLabel,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.excludeFromSemantics = false,
    super.key,
  });

  final ImageProvider image;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: excludeFromSemantics,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: excludeFromSemantics ? null : semanticLabel,
      ),
    );
  }
}

/// Accessible text field with proper labels.
class AccessibleTextField extends StatelessWidget {
  const AccessibleTextField({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: labelText,
      textField: true,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          errorMaxLines: 2,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
      ),
    );
  }
}

/// Extension for checking contrast ratio.
extension ColorContrastExtension on Color {
  /// Calculates relative luminance per WCAG 2.1.
  double get relativeLuminance {
    double adjustComponent(int component) {
      final sRGB = component / 255;
      return sRGB <= 0.03928
          ? sRGB / 12.92
          : math.pow((sRGB + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * adjustComponent(red) +
        0.7152 * adjustComponent(green) +
        0.0722 * adjustComponent(blue);
  }

  /// Calculates contrast ratio with another color.
  double contrastRatio(Color other) {
    final l1 = relativeLuminance;
    final l2 = other.relativeLuminance;
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Returns true if contrast ratio meets WCAG AA for normal text (4.5:1).
  bool meetsWcagAA(Color background) => contrastRatio(background) >= 4.5;

  /// Returns true if contrast ratio meets WCAG AA for large text (3:1).
  bool meetsWcagAALargeText(Color background) =>
      contrastRatio(background) >= 3.0;

  /// Returns true if contrast ratio meets WCAG AAA for normal text (7:1).
  bool meetsWcagAAA(Color background) => contrastRatio(background) >= 7.0;
}
