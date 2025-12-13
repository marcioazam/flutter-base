import 'package:flutter/material.dart';
import 'package:flutter_base_2025/shared/widgets/error_boundary_widget.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: flutter-2025-final-polish, Property 9: Error Boundary Recovery**
/// **Validates: Requirements 14.1, 14.2, 14.4**
void main() {
  group('Error Boundary Properties', () {
    testWidgets('displays child when no error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ErrorBoundary(child: Text('Normal content'))),
      );

      expect(find.text('Normal content'), findsOneWidget);
      expect(find.byType(DefaultErrorWidget), findsNothing);
    });

    testWidgets('DefaultErrorWidget shows error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultErrorWidget(
            error: Exception('Test error'),
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Algo deu errado'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('DefaultErrorWidget has retry button', (tester) async {
      var retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: DefaultErrorWidget(
            error: Exception('Test error'),
            onRetry: () => retryPressed = true,
          ),
        ),
      );

      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('CompactErrorWidget displays message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CompactErrorWidget(message: 'Compact error')),
        ),
      );

      expect(find.text('Compact error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('CompactErrorWidget shows retry when provided', (tester) async {
      var retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactErrorWidget(
              message: 'Error',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('CompactErrorWidget hides retry when not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CompactErrorWidget(message: 'Error')),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    test('long error messages are truncated', () {
      final longError = 'A' * 200;
      final widget = DefaultErrorWidget(
        error: Exception(longError),
        onRetry: () {},
      );

      expect(widget.error.toString().length, greaterThan(100));
    });
  });
}
