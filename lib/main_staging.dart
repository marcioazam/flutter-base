import 'package:flutter/material.dart';
import 'package:flutter_base_2025/core/config/app_config.dart';
import 'package:flutter_base_2025/main.dart';
import 'package:flutter_base_2025/shared/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize(Flavor.staging);
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const FlutterBaseApp(),
    ),
  );
}
