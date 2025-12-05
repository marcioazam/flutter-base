import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// App theme configuration with Material 3.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 32.1, 32.2, 32.4, 32.5**
abstract final class AppTheme {
  /// Light theme.
  static ThemeData get light => _buildTheme(Brightness.light);

  /// Dark theme.
  static ThemeData get dark => _buildTheme(Brightness.dark);

  /// High contrast light theme.
  static ThemeData get highContrastLight =>
      _buildTheme(Brightness.light, highContrast: true);

  /// High contrast dark theme.
  static ThemeData get highContrastDark =>
      _buildTheme(Brightness.dark, highContrast: true);

  /// Builds theme with optional dynamic color scheme.
  static ThemeData fromDynamicColors({
    required Brightness brightness,
    ColorScheme? lightDynamic,
    ColorScheme? darkDynamic,
    bool highContrast = false,
  }) {
    final isDark = brightness == Brightness.dark;
    final dynamicScheme = isDark ? darkDynamic : lightDynamic;

    if (dynamicScheme != null) {
      return _buildThemeWithScheme(
        dynamicScheme,
        brightness,
        highContrast: highContrast,
      );
    }

    return _buildTheme(brightness, highContrast: highContrast);
  }

  static ThemeData _buildTheme(
    Brightness brightness, {
    bool highContrast = false,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = highContrast
        ? _buildHighContrastScheme(brightness)
        : ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: brightness,
          );

    return _buildThemeWithScheme(colorScheme, brightness,
        highContrast: highContrast);
  }

  static ColorScheme _buildHighContrastScheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    if (isDark) {
      return const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.yellow,
        onSecondary: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        outline: Colors.white,
      );
    }

    return const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Color(0xFF0000AA),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Color(0xFFAA0000),
      onError: Colors.white,
      outline: Colors.black,
    );
  }

  static ThemeData _buildThemeWithScheme(
    ColorScheme colorScheme,
    Brightness brightness, {
    bool highContrast = false,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      extensions: [
        AppThemeExtension(
          isDark: isDark,
          isHighContrast: highContrast,
          success: isDark ? Colors.green.shade300 : Colors.green.shade600,
          warning: isDark ? Colors.orange.shade300 : Colors.orange.shade600,
          info: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
        ),
      ],
    );
  }
}

/// Animated theme wrapper for smooth transitions.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 32.4**
class AnimatedAppTheme extends StatelessWidget {
  final ThemeData theme;
  final Duration duration;
  final Curve curve;
  final Widget child;

  const AnimatedAppTheme({
    super.key,
    required this.theme,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: theme,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// Custom theme extension for additional colors.
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final bool isDark;
  final bool isHighContrast;
  final Color success;
  final Color warning;
  final Color info;

  AppThemeExtension({
    required this.isDark,
    this.isHighContrast = false,
    required this.success,
    required this.warning,
    required this.info,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    bool? isDark,
    bool? isHighContrast,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppThemeExtension(
      isDark: isDark ?? this.isDark,
      isHighContrast: isHighContrast ?? this.isHighContrast,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      isDark: t < 0.5 ? isDark : other.isDark,
      isHighContrast: t < 0.5 ? isHighContrast : other.isHighContrast,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// Extension for easy access to custom theme.
extension AppThemeExtensionAccess on ThemeData {
  AppThemeExtension get app => extension<AppThemeExtension>()!;
}
