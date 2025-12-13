import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests for button widgets.
/// Run: flutter test --update-goldens test/golden/
void main() {
  group('Button Golden Tests', () {
    testWidgets('ElevatedButton matches golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ElevatedButton),
        matchesGoldenFile('goldens/elevated_button.png'),
      );
    });

    testWidgets('FilledButton matches golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {},
                child: const Text('Filled'),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FilledButton),
        matchesGoldenFile('goldens/filled_button.png'),
      );
    });

    testWidgets('OutlinedButton matches golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined'),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(OutlinedButton),
        matchesGoldenFile('goldens/outlined_button.png'),
      );
    });

    testWidgets('TextButton matches golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: TextButton(onPressed: () {}, child: const Text('Text')),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(TextButton),
        matchesGoldenFile('goldens/text_button.png'),
      );
    });

    testWidgets('IconButton matches golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(IconButton),
        matchesGoldenFile('goldens/icon_button.png'),
      );
    });
  });
}
