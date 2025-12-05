/// Widget Previewer Support for Flutter 3.38+
///
/// This file contains preview configurations for shared widgets.
/// The @Preview and @MultiPreview annotations enable IDE preview support.
///
/// Usage:
/// ```dart
/// @Preview(name: 'Default', width: 400, height: 200)
/// @Preview(name: 'Dark', width: 400, height: 200, theme: ThemeMode.dark)
/// class MyWidget extends StatelessWidget { ... }
/// ```
///
/// Note: Preview annotations are currently experimental in Flutter 3.38.
/// Uncomment when the feature becomes stable.
library;

import 'package:flutter/material.dart';

// Preview annotation placeholder (uncomment when Flutter Widget Previewer is stable)
// class Preview {
//   final String name;
//   final double width;
//   final double height;
//   final ThemeMode? theme;
//   final String? group;
//
//   const Preview({
//     required this.name,
//     this.width = 400,
//     this.height = 300,
//     this.theme,
//     this.group,
//   });
// }

// MultiPreview annotation placeholder
// class MultiPreview {
//   final List<Preview> previews;
//
//   const MultiPreview(this.previews);
// }

/// Preview wrapper widget for testing widget previews.
class PreviewWrapper extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final ThemeMode themeMode;

  const PreviewWrapper({
    super.key,
    required this.child,
    this.width = 400,
    this.height = 300,
    this.themeMode = ThemeMode.light,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Preview configurations for AccessibleButton
class AccessibleButtonPreviews {
  static const defaultPreview = (
    name: 'Default',
    width: 200.0,
    height: 100.0,
  );

  static const darkPreview = (
    name: 'Dark Theme',
    width: 200.0,
    height: 100.0,
    theme: ThemeMode.dark,
  );

  static const largePreview = (
    name: 'Large',
    width: 300.0,
    height: 150.0,
  );
}

/// Preview configurations for ErrorBoundary
class ErrorBoundaryPreviews {
  static const errorState = (
    name: 'Error State',
    width: 400.0,
    height: 300.0,
  );

  static const compactError = (
    name: 'Compact Error',
    width: 400.0,
    height: 100.0,
  );

  static const darkError = (
    name: 'Dark Theme Error',
    width: 400.0,
    height: 300.0,
    theme: ThemeMode.dark,
  );
}

/// Preview configurations for PredictivePopScope
class PredictivePopScopePreviews {
  static const defaultPreview = (
    name: 'Default',
    width: 400.0,
    height: 300.0,
  );

  static const withDialog = (
    name: 'With Confirmation Dialog',
    width: 400.0,
    height: 400.0,
  );
}

/// Preview configurations for SkeletonWidget
class SkeletonWidgetPreviews {
  static const card = (
    name: 'Card Skeleton',
    width: 300.0,
    height: 200.0,
    group: 'Loading States',
  );

  static const list = (
    name: 'List Skeleton',
    width: 400.0,
    height: 400.0,
    group: 'Loading States',
  );

  static const avatar = (
    name: 'Avatar Skeleton',
    width: 100.0,
    height: 100.0,
    group: 'Loading States',
  );
}

/// Preview configurations for ResponsiveBuilder
class ResponsiveBuilderPreviews {
  static const mobile = (
    name: 'Mobile',
    width: 375.0,
    height: 667.0,
    group: 'Responsive',
  );

  static const tablet = (
    name: 'Tablet',
    width: 768.0,
    height: 1024.0,
    group: 'Responsive',
  );

  static const desktop = (
    name: 'Desktop',
    width: 1440.0,
    height: 900.0,
    group: 'Responsive',
  );
}
