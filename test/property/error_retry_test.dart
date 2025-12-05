import 'package:flutter/material.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/shared/widgets/error_view.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: flutter-modernization-2025, Property 12: Error State Retry Action**
/// **Validates: Requirements 17.2**

void main() {
  group('Error State Retry Action Properties', () {
    testWidgets('ErrorView displays retry button', (tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: NetworkFailure('Test error'),
              onRetry: () => retryCount++,
            ),
          ),
        ),
      );

      // Find retry button
      final retryButton = find.text('Tentar novamente');
      expect(retryButton, findsOneWidget);
    });

    testWidgets('ErrorView retry button calls onRetry', (tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: NetworkFailure('Test error'),
              onRetry: () => retryCount++,
            ),
          ),
        ),
      );

      // Tap retry button
      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      expect(retryCount, equals(1));
    });

    testWidgets('ErrorView retry can be called multiple times', (tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: NetworkFailure('Test error'),
              onRetry: () => retryCount++,
            ),
          ),
        ),
      );

      // Tap retry button multiple times
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Tentar novamente'));
        await tester.pump();
      }

      expect(retryCount, equals(5));
    });

    testWidgets('ErrorView shows correct icon for NetworkFailure',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: NetworkFailure('No connection'),
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('ErrorView shows correct icon for AuthFailure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: AuthFailure('Session expired'),
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('ErrorView shows correct icon for ServerFailure',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: ServerFailure('Server error'),
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('ErrorView shows correct icon for NotFoundFailure',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: NotFoundFailure('Not found'),
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('ErrorView shows correct icon for ValidationFailure',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: ValidationFailure('Invalid data', fieldErrors: {}),
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('ErrorView shows custom title when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: NetworkFailure('Error'),
              onRetry: () {},
              title: 'Custom Error Title',
            ),
          ),
        ),
      );

      expect(find.text('Custom Error Title'), findsOneWidget);
    });

    testWidgets('AsyncErrorView wraps ErrorView correctly', (tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncErrorView(
              error: NetworkFailure('Async error'),
              stackTrace: StackTrace.current,
              onRetry: () => retryCount++,
            ),
          ),
        ),
      );

      // Find and tap retry button
      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      expect(retryCount, equals(1));
    });

    testWidgets('LoadingView displays correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingView(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingView shows message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingView(message: 'Loading data...'),
          ),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('EmptyView displays message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(message: 'No items found'),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('EmptyView shows action button when provided', (tester) async {
      var actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyView(
              message: 'No items',
              action: () => actionCalled = true,
              actionLabel: 'Add Item',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add Item'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });
  });
}
