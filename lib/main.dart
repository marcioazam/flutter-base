import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/theme_provider.dart';

/// Main entry point - use flavor-specific main files for different environments.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Default to development if running main.dart directly
  await AppConfig.initialize(Flavor.development);
  
  runApp(const ProviderScope(child: FlutterBaseApp()));
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
