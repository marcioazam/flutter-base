import 'package:flutter_base_2025/core/utils/mutation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glados_helpers.dart';

void main() {
  group('Mutation State Property Tests', () {
    /// **Feature: flutter-2025-final-enhancements, Property 1: Mutation State Transitions**
    /// **Validates: Requirements 1.2**
    test('MutationController starts in idle state', () {
      final controller = MutationController<String>();
      expect(controller.state, isA<MutationIdle<String>>());
      expect(controller.isIdle, isTrue);
    });

    test('MutationController transitions to loading on mutate', () async {
      final controller = MutationController<String>();
      final states = <MutationState<String>>[];
      controller.addListener(states.add);

      // Start mutation but don't await
      final future = controller.mutate(() async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return 'result';
      });

      // First state should be loading
      expect(states.first, isA<MutationLoading<String>>());
      
      await future;
    });

    Glados(any.lowercaseLetters).test(
      'MutationController transitions to success on successful mutation',
      (value) async {
        final controller = MutationController<String>();
        await controller.mutate(() async => value);

        expect(controller.state, isA<MutationSuccess<String>>());
        expect(controller.isSuccess, isTrue);
        expect(controller.data, equals(value));
      },
    );

    test('MutationController transitions to error on failed mutation', () async {
      final controller = MutationController<String>();
      await controller.mutate(() async => throw Exception('Test error'));

      expect(controller.state, isA<MutationError<String>>());
      expect(controller.isError, isTrue);
      expect(controller.error, isA<Exception>());
    });

    test('MutationController reset returns to idle', () async {
      final controller = MutationController<String>();
      await controller.mutate(() async => 'result');
      expect(controller.isSuccess, isTrue);

      controller.reset();
      expect(controller.isIdle, isTrue);
    });

    test('MutationState.when pattern matching works correctly', () {
      const idle = MutationIdle<String>();
      const loading = MutationLoading<String>();
      const success = MutationSuccess<String>('data');
      const error = MutationError<String>('error', StackTrace.empty);

      expect(idle.when(idle: () => 'idle', loading: (_) => 'loading', success: (_) => 'success', error: (_, __) => 'error'), 'idle');
      expect(loading.when(idle: () => 'idle', loading: (_) => 'loading', success: (_) => 'success', error: (_, __) => 'error'), 'loading');
      expect(success.when(idle: () => 'idle', loading: (_) => 'loading', success: (_) => 'success', error: (_, __) => 'error'), 'success');
      expect(error.when(idle: () => 'idle', loading: (_) => 'loading', success: (_) => 'success', error: (_, __) => 'error'), 'error');
    });
  });
}
