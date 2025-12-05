// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_base_2025/shared/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test - theme provider works', (tester) async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build a simple test widget with theme provider
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final themeMode = ref.watch(themeModeProvider);
            return MaterialApp(
              themeMode: themeMode,
              home: Scaffold(
                body: Center(
                  child: Text('Theme: ${themeMode.name}'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Verify that the app renders
    expect(find.text('Theme: system'), findsOneWidget);
  });
}
