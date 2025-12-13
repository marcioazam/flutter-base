import 'package:flutter/material.dart';
import 'package:flutter_base_2025/core/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_base_2025/shared/providers/theme_provider.dart';

/// Bootstrap the application with the specified flavor.
///
/// This function initializes all required services and returns
/// a configured [ProviderScope] ready to run the app.
Future<ProviderScope> bootstrap({
  required Flavor flavor,
  required Widget child,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration
  await AppConfig.initialize(flavor);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: child,
  );
}
