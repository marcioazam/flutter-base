import 'package:flutter/material.dart';
import 'package:flutter_base_2025/core/config/app_config.dart';
import 'package:flutter_base_2025/core/router/app_router.dart';
import 'package:flutter_base_2025/core/theme/app_theme.dart';
import 'package:flutter_base_2025/shared/providers/locale_provider.dart';
import 'package:flutter_base_2025/shared/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main entry point - use flavor-specific main files for different environments.
/// 
/// **Feature: flutter-2025-final-enhancements**
/// **Validates: Requirements 3.4**
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Default to development if running main.dart directly
  await AppConfig.initialize(Flavor.development);
  
  // Initialize SharedPreferences before app starts
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const FlutterBaseApp(),
    ),
  );
}

/// Main app widget consuming Python API backend.
class FlutterBaseApp extends ConsumerWidget {
  const FlutterBaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: config.showDebugBanner,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      routerConfig: router,
    );
  }
}
