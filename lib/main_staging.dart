import 'package:flutter/material.dart';
import 'package:flutter_base_2025/core/config/app_config.dart';
import 'package:flutter_base_2025/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize(Flavor.staging);
  runApp(const ProviderScope(child: FlutterBaseApp()));
}
