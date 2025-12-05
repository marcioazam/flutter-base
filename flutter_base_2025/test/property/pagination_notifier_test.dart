import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart';

import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/generics/paginated_list.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_base_2025/shared/providers/pagination_notifier.dart';

/// **Feature: flutter-state-of-art-2025-final, Property 8: Pagination Failure Preserves Items**
/// **Validates: Requirements 5.4**

/// Test implementation of PaginationNotifier.
class TestPaginationNotifier extends PaginationNotifier<String> {
  final List<Result<PaginatedList<String>>> _responses;
  int _callCount = 0;

  TestPaginationNotifier(this._responses) : super(pageSize: 10);

  @override
  Future<Result<PaginatedList<String>>> fetchPage(int page, int pageSize) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (_callCount < _responses.length) {
      return _responses[_callCount++];
    }
    return Failure(const NetworkFailure('No more responses'));
  }

  int get callCount => _callCount;
}

final testPaginationProvider = AsyncNotifierProvider.autoDispose<
    TestPaginationNotifier, PaginationState<String>>(
  () => throw UnimplementedError('Override in test'),
);

void main() {
  group('PaginationNotifier Properties', () {
    /// **Property 8: Pagination Failure Preserves Items**
    /// *For any* PaginationNotifier with loaded items, a failed loadMore
    /// should preserve the existing items.
    test('loadMore failure preserves existing items', () async {
      final initialData = PaginatedList.fromItems(
        ['item1', 'item2', 'item3'],
        page: 1,
        pageSize: 10,
        totalItems: 30,
      );

      final notifier = TestPaginationNotifier([
        Success(initialData),
        Failure(const NetworkFailure('Network error')),
      ]);

      final container = ProviderContainer(
        overrides: [
          testPaginationProvider.overrideWith(() => notifier),
        ],
      );
      addTearDown(container.dispose);

      // Wait for initial load
      await container.read(testPaginationProvider.future);

      final stateAfterLoad = container.read(testPaginationProvider).valueOrNull;
      expect(stateAfterLoad?.data.items, equals(['item1', 'item2', 'item3']));

      // Trigger loadMore which will fail
      await notifier.loadMore();

      final stateAfterFailure = container.read(testPaginationProvider).valueOrNull;

      // Items should be preserved
      expect(stateAfterFailure?.data.items, equals(['item1', 'item2', 'item3']));
      expect(stateAfterFailure?.hasError, isTrue);
      expect(stateAfterFailure?.isLoadingMore, isFalse);
    });

    Glados<List<String>>(iterations: 50).test(
      'loadMore failure always preserves all existing items',
      (items) async {
        if (items.isEmpty) return;

        final initialData = PaginatedList.fromItems(
          items,
          page: 1,
          pageSize: 10,
          totalItems: items.length + 20,
        );

        final notifier = TestPaginationNotifier([
          Success(initialData),
          Failure(const ServerFailure('Server error', statusCode: 500)),
        ]);

        final container = ProviderContainer(
          overrides: [
            testPaginationProvider.overrideWith(() => notifier),
          ],
        );
        addTearDown(container.dispose);

        await container.read(testPaginationProvider.future);
        await notifier.loadMore();

        final state = container.read(testPaginationProvider).valueOrNull;

        // All original items must be preserved
        expect(state?.data.items.length, equals(items.length));
        for (var i = 0; i < items.length; i++) {
          expect(state?.data.items[i], equals(items[i]));
        }
      },
    );

    test('refresh failure preserves existing items', () async {
      final initialData = PaginatedList.fromItems(
        ['item1', 'item2'],
        page: 1,
        pageSize: 10,
        totalItems: 20,
      );

      final notifier = TestPaginationNotifier([
        Success(initialData),
        Failure(const NetworkFailure('Refresh failed')),
      ]);

      final container = ProviderContainer(
        overrides: [
          testPaginationProvider.overrideWith(() => notifier),
        ],
      );
      addTearDown(container.dispose);

      await container.read(testPaginationProvider.future);
      await notifier.refresh();

      final state = container.read(testPaginationProvider).valueOrNull;

      expect(state?.data.items, equals(['item1', 'item2']));
      expect(state?.hasError, isTrue);
    });

    test('successful loadMore appends items', () async {
      final page1 = PaginatedList.fromItems(
        ['a', 'b'],
        page: 1,
        pageSize: 2,
        totalItems: 4,
      );

      final page2 = PaginatedList.fromItems(
        ['c', 'd'],
        page: 2,
        pageSize: 2,
        totalItems: 4,
      );

      final notifier = TestPaginationNotifier([
        Success(page1),
        Success(page2),
      ]);

      final container = ProviderContainer(
        overrides: [
          testPaginationProvider.overrideWith(() => notifier),
        ],
      );
      addTearDown(container.dispose);

      await container.read(testPaginationProvider.future);
      await notifier.loadMore();

      final state = container.read(testPaginationProvider).valueOrNull;

      expect(state?.data.items, equals(['a', 'b', 'c', 'd']));
      expect(state?.hasError, isFalse);
    });

    test('canLoadMore is false when no more pages', () async {
      final lastPage = PaginatedList.fromItems(
        ['item1'],
        page: 1,
        pageSize: 10,
        totalItems: 1,
      );

      final notifier = TestPaginationNotifier([Success(lastPage)]);

      final container = ProviderContainer(
        overrides: [
          testPaginationProvider.overrideWith(() => notifier),
        ],
      );
      addTearDown(container.dispose);

      await container.read(testPaginationProvider.future);

      final state = container.read(testPaginationProvider).valueOrNull;

      expect(state?.canLoadMore, isFalse);
      expect(state?.data.hasMore, isFalse);
    });

    test('clearError removes error state', () async {
      final initialData = PaginatedList.fromItems(
        ['item1'],
        page: 1,
        pageSize: 10,
        totalItems: 20,
      );

      final notifier = TestPaginationNotifier([
        Success(initialData),
        Failure(const NetworkFailure('Error')),
      ]);

      final container = ProviderContainer(
        overrides: [
          testPaginationProvider.overrideWith(() => notifier),
        ],
      );
      addTearDown(container.dispose);

      await container.read(testPaginationProvider.future);
      await notifier.loadMore();

      expect(
        container.read(testPaginationProvider).valueOrNull?.hasError,
        isTrue,
      );

      notifier.clearError();

      expect(
        container.read(testPaginationProvider).valueOrNull?.hasError,
        isFalse,
      );
    });
  });

  group('PaginationState Properties', () {
    test('initial state has correct defaults', () {
      final state = PaginationState<String>.initial();

      expect(state.data.isEmpty, isTrue);
      expect(state.isLoadingMore, isFalse);
      expect(state.isRefreshing, isFalse);
      expect(state.error, isNull);
    });

    test('hasData returns true when items exist', () {
      final state = PaginationState(
        data: PaginatedList.fromItems(
          ['item'],
          page: 1,
          pageSize: 10,
          totalItems: 1,
        ),
      );

      expect(state.hasData, isTrue);
    });

    test('isLoading returns true during loadMore or refresh', () {
      final loadingMore = PaginationState<String>.initial().copyWith(
        isLoadingMore: true,
      );
      final refreshing = PaginationState<String>.initial().copyWith(
        isRefreshing: true,
      );

      expect(loadingMore.isLoading, isTrue);
      expect(refreshing.isLoading, isTrue);
    });
  });

  group('PaginationStateExtension Properties', () {
    test('items returns empty list for null state', () {
      const AsyncValue<PaginationState<String>> value = AsyncLoading();
      expect(value.items, isEmpty);
    });

    test('items returns data items for loaded state', () {
      final state = PaginationState(
        data: PaginatedList.fromItems(
          ['a', 'b'],
          page: 1,
          pageSize: 10,
          totalItems: 2,
        ),
      );
      final value = AsyncData(state);

      expect(value.items, equals(['a', 'b']));
    });
  });
}
