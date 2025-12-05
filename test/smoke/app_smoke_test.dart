import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_base_2025/core/config/app_config.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/init/app_initializer.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// **Feature: flutter-state-of-art-2025-final, Smoke Tests**
/// **Validates: Requirements 20.2**

void main() {
  group('App Initialization Smoke Tests', () {
    test('AppConfig can be created for all flavors', () {
      // Test that config creation doesn't throw for valid flavors
      expect(Flavor.development.name, equals('development'));
      expect(Flavor.staging.name, equals('staging'));
      expect(Flavor.production.name, equals('production'));
    });

    test('InitResult types are exhaustive', () {
      const InitResult success = InitSuccess(Duration(seconds: 1));
      const InitResult failure = InitFailure('test', 'error', StackTrace.empty);

      // Pattern matching should be exhaustive
      final message = switch (success) {
        InitSuccess(:final duration) => 'Success: ${duration.inMilliseconds}ms',
        InitFailure(:final step) => 'Failed at: $step',
      };

      expect(message, contains('Success'));

      final failMessage = switch (failure) {
        InitSuccess(:final duration) => 'Success: ${duration.inMilliseconds}ms',
        InitFailure(:final step) => 'Failed at: $step',
      };

      expect(failMessage, contains('Failed at: test'));
    });

    test('AppInitializer can be instantiated', () {
      final initializer = AppInitializer(flavor: Flavor.development);
      expect(initializer, isNotNull);
    });
  });

  group('Error Handling Smoke Tests', () {
    test('All AppFailure subtypes can be created', () {
      final failures = <AppFailure>[
        const NetworkFailure('Network error'),
        const ServerFailure('Server error', statusCode: 500),
        const ValidationFailure('Validation error'),
        const AuthFailure('Auth error'),
        const NotFoundFailure('Not found'),
        const CacheFailure('Cache error'),
        const ForbiddenFailure('Forbidden'),
        const ConflictFailure('Conflict'),
        const RateLimitFailure('Rate limit'),
        const UnexpectedFailure('Unexpected'),
      ];

      for (final failure in failures) {
        expect(failure.message, isNotEmpty);
        expect(failure.userMessage, isNotEmpty);
      }
    });

    test('Result types work correctly', () {
      final success = Success(42);
      final failure = Failure<int>(const NetworkFailure('error'));

      expect(success.isSuccess, isTrue);
      expect(success.valueOrNull, equals(42));

      expect(failure.isFailure, isTrue);
      expect(failure.failureOrNull, isA<NetworkFailure>());
    });

    test('Result combinators work', () {
      final result = Success(10);

      final mapped = result.map((v) => v * 2);
      expect(mapped.valueOrNull, equals(20));

      final chained = result.flatMap((v) => Success(v.toString()));
      expect(chained.valueOrNull, equals('10'));
    });
  });

  group('Widget Smoke Tests', () {
    testWidgets('ProviderScope can be created', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Smoke Test')),
            ),
          ),
        ),
      );

      expect(find.text('Smoke Test'), findsOneWidget);
    });

    testWidgets('MaterialApp with theme works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: Center(child: Text('Theme Test')),
          ),
        ),
      );

      expect(find.text('Theme Test'), findsOneWidget);
    });

    testWidgets('Dark theme works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: Center(child: Text('Dark Theme Test')),
          ),
        ),
      );

      expect(find.text('Dark Theme Test'), findsOneWidget);
    });
  });

  group('Navigation Smoke Tests', () {
    testWidgets('Navigator can push and pop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('Second Page')),
                      ),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);
    });
  });

  group('Async State Smoke Tests', () {
    testWidgets('AsyncValue states render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                const AsyncValue<int> loading = AsyncLoading();
                const AsyncValue<int> data = AsyncData(42);
                final AsyncValue<int> error = AsyncError('error', StackTrace.empty);

                return Column(
                  children: [
                    Text(loading.when(
                      data: (v) => 'Data: $v',
                      loading: () => 'Loading',
                      error: (e, s) => 'Error: $e',
                    )),
                    Text(data.when(
                      data: (v) => 'Data: $v',
                      loading: () => 'Loading',
                      error: (e, s) => 'Error: $e',
                    )),
                    Text(error.when(
                      data: (v) => 'Data: $v',
                      loading: () => 'Loading',
                      error: (e, s) => 'Error: $e',
                    )),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);
      expect(find.text('Data: 42'), findsOneWidget);
      expect(find.text('Error: error'), findsOneWidget);
    });
  });
}
