import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: flutter-modernization-2025, Property 6: AsyncNotifier State Preservation**
/// **Validates: Requirements 3.12**

/// Test notifier that preserves previous data.
class TestAsyncNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async => 0;

  Future<void> increment() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading<int>().copyWithPrevious(state);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    state = AsyncData((previous ?? 0) + 1);
  }

  Future<void> setError() async {
    state = const AsyncLoading<int>().copyWithPrevious(state);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    state = AsyncError('Test error', StackTrace.current);
  }
}

final testNotifierProvider =
    AsyncNotifierProvider<TestAsyncNotifier, int>(TestAsyncNotifier.new);

void main() {
  group('AsyncNotifier State Preservation Properties', () {
    test('AsyncLoading preserves previous data with copyWithPrevious', () {
      const data = AsyncData(42);
      final loading = const AsyncLoading<int>().copyWithPrevious(data);

      expect(loading.isLoading, isTrue);
      expect(loading.valueOrNull, equals(42));
      expect(loading.hasValue, isTrue);
    });

    test('AsyncLoading preserves previous error with copyWithPrevious', () {
      final error = AsyncError<int>('error', StackTrace.current);
      final loading = const AsyncLoading<int>().copyWithPrevious(error);

      expect(loading.isLoading, isTrue);
      expect(loading.hasError, isTrue);
    });

    test('AsyncNotifier preserves data during loading transition', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(testNotifierProvider.notifier);
      await container.read(testNotifierProvider.future);

      expect(container.read(testNotifierProvider).valueOrNull, equals(0));

      final future = notifier.increment();
      expect(container.read(testNotifierProvider).isLoading, isTrue);
      expect(container.read(testNotifierProvider).valueOrNull, equals(0));

      await future;
      expect(container.read(testNotifierProvider).valueOrNull, equals(1));
    });

    test('AsyncValue.when handles all states', () {
      const data = AsyncData(42);
      const loading = AsyncLoading<int>();
      final error = AsyncError<int>('error', StackTrace.current);

      expect(
        data.when(
          data: (v) => 'data:$v',
          loading: () => 'loading',
          error: (e, s) => 'error:$e',
        ),
        equals('data:42'),
      );

      expect(
        loading.when(
          data: (v) => 'data:$v',
          loading: () => 'loading',
          error: (e, s) => 'error:$e',
        ),
        equals('loading'),
      );

      expect(
        error.when(
          data: (v) => 'data:$v',
          loading: () => 'loading',
          error: (e, s) => 'error:$e',
        ),
        equals('error:error'),
      );
    });

    test('AsyncValue.maybeWhen provides orElse fallback', () {
      const data = AsyncData(42);
      const loading = AsyncLoading<int>();

      expect(
        data.maybeWhen(
          data: (v) => 'data:$v',
          orElse: () => 'other',
        ),
        equals('data:42'),
      );

      expect(
        loading.maybeWhen(
          data: (v) => 'data:$v',
          orElse: () => 'other',
        ),
        equals('other'),
      );
    });

    test('AsyncValue.map handles all states', () {
      const data = AsyncData(42);
      const loading = AsyncLoading<int>();
      final error = AsyncError<int>('error', StackTrace.current);

      expect(
        data.map(
          data: (d) => 'data',
          loading: (l) => 'loading',
          error: (e) => 'error',
        ),
        equals('data'),
      );

      expect(
        loading.map(
          data: (d) => 'data',
          loading: (l) => 'loading',
          error: (e) => 'error',
        ),
        equals('loading'),
      );

      expect(
        error.map(
          data: (d) => 'data',
          loading: (l) => 'loading',
          error: (e) => 'error',
        ),
        equals('error'),
      );
    });
  });
}
