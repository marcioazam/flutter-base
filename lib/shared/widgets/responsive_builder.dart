import 'package:flutter/material.dart';

/// Responsive breakpoints.
abstract final class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Screen size categories.
enum ScreenSize { mobile, tablet, desktop }

/// Extension for getting screen size from context.
extension ScreenSizeExtension on BuildContext {
  ScreenSize get screenSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width < Breakpoints.mobile) return ScreenSize.mobile;
    if (width < Breakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;
}

/// Responsive builder widget.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  @override
  Widget build(BuildContext context) => builder(context, context.screenSize);
}

/// Responsive layout widget with different builders for each size.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) => switch (context.screenSize) {
    ScreenSize.desktop => desktop ?? tablet ?? mobile,
    ScreenSize.tablet => tablet ?? mobile,
    ScreenSize.mobile => mobile,
  };
}

/// Responsive value helper.
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
}) => switch (context.screenSize) {
  ScreenSize.desktop => desktop ?? tablet ?? mobile,
  ScreenSize.tablet => tablet ?? mobile,
  ScreenSize.mobile => mobile,
};

/// Responsive padding.
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    required this.child,
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  });
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  @override
  Widget build(BuildContext context) {
    final padding = responsiveValue(
      context,
      mobile: mobile ?? const EdgeInsets.all(16),
      tablet: tablet ?? const EdgeInsets.all(24),
      desktop: desktop ?? const EdgeInsets.all(32),
    );

    return Padding(padding: padding, child: child);
  }
}
