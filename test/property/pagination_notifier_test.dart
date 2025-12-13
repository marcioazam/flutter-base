import 'package:flutter_base_2025/core/generics/paginated_list.dart';
import 'package:flutter_base_2025/shared/providers/pagination_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-state-of-art-2025-final, Property 8: Pagination Failure Preserves Items**
/// **Validates: Requirements 5.4**

void main() {
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

    test('canLoadMore is true when hasMore and not loading', () {
      final state = PaginationState(
        data: PaginatedList.fromItems(
          ['item'],
          page: 1,
          pageSize: 10,
          totalItems: 100,
        ),
      );

      expect(state.canLoadMore, isTrue);
    });

    test('canLoadMore is false when loading', () {
      final state = PaginationState(
        data: PaginatedList.fromItems(
          ['item'],
          page: 1,
          pageSize: 10,
          totalItems: 100,
        ),
        isLoadingMore: true,
      );

      expect(state.canLoadMore, isFalse);
    });

    test('canLoadMore is false when no more pages', () {
      final state = PaginationState(
        data: PaginatedList.fromItems(
          ['item'],
          page: 1,
          pageSize: 10,
          totalItems: 1,
        ),
      );

      expect(state.canLoadMore, isFalse);
    });

    test('copyWith preserves unchanged values', () {
      final original = PaginationState(
        data: PaginatedList.fromItems(
          ['item'],
          page: 1,
          pageSize: 10,
          totalItems: 1,
        ),
        isLoadingMore: true,
        error: 'error',
      );

      final copied = original.copyWith(isLoadingMore: false);

      expect(copied.data.items, equals(original.data.items));
      expect(copied.isLoadingMore, isFalse);
      expect(copied.isRefreshing, equals(original.isRefreshing));
      expect(copied.error, equals(original.error));
    });

    Glados<List<String>>(any.list(any.nonEmptyLetters), _explore).test(
      'hasData reflects items presence',
      (items) {
        final state = PaginationState(
          data: PaginatedList.fromItems(
            items,
            page: 1,
            pageSize: 10,
            totalItems: items.length,
          ),
        );

        expect(state.hasData, equals(items.isNotEmpty));
      },
    );
  });

  group('PaginationStateExtension Properties', () {
    test('items returns empty list for loading state', () {
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

    test('isLoadingMore returns false for loading state', () {
      const AsyncValue<PaginationState<String>> value = AsyncLoading();
      expect(value.isLoadingMore, isFalse);
    });

    test('canLoadMore returns false for loading state', () {
      const AsyncValue<PaginationState<String>> value = AsyncLoading();
      expect(value.canLoadMore, isFalse);
    });

    test('errorMessage returns null for loading state', () {
      const AsyncValue<PaginationState<String>> value = AsyncLoading();
      expect(value.errorMessage, isNull);
    });

    test('errorMessage returns error for state with error', () {
      final state = PaginationState<String>.initial().copyWith(
        error: 'Test error',
      );
      final value = AsyncData(state);

      expect(value.errorMessage, equals('Test error'));
    });
  });

  group('PaginatedList concat Properties', () {
    test('concat combines two lists', () {
      final list1 = PaginatedList.fromItems(
        ['a', 'b'],
        page: 1,
        pageSize: 2,
        totalItems: 4,
      );

      final list2 = PaginatedList.fromItems(
        ['c', 'd'],
        page: 2,
        pageSize: 2,
        totalItems: 4,
      );

      final combined = list1.concat(list2);

      expect(combined.items, equals(['a', 'b', 'c', 'd']));
      expect(combined.page, equals(2));
      expect(combined.totalItems, equals(4));
    });

    Glados2<List<String>, List<String>>(
      any.list(any.nonEmptyLetters),
      any.list(any.nonEmptyLetters),
      _explore,
    ).test(
      'concat preserves all items from both lists',
      (items1, items2) {
        final list1 = PaginatedList.fromItems(
          items1,
          page: 1,
          pageSize: 10,
          totalItems: items1.length + items2.length,
        );

        final list2 = PaginatedList.fromItems(
          items2,
          page: 2,
          pageSize: 10,
          totalItems: items1.length + items2.length,
        );

        final combined = list1.concat(list2);

        expect(combined.items.length, equals(items1.length + items2.length));
        expect(combined.items.sublist(0, items1.length), equals(items1));
        expect(combined.items.sublist(items1.length), equals(items2));
      },
    );
  });
}
