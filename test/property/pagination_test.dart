import 'package:flutter_base_2025/core/base/paginated_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-state-of-art-2025-final, Property 7: PaginatedList hasMore Calculation**
/// **Validates: Requirements 5.1, 5.3**
void main() {
  group('PaginatedList hasMore Properties', () {
    /// **Property 7: PaginatedList hasMore Calculation**
    /// *For any* PaginatedList with page, pageSize, and totalItems,
    /// hasMore should be true if and only if page < totalPages.
    Glados(
      any.combine3(
        any.positiveIntOrZero.map((i) => (i % 100) + 1),
        any.positiveIntOrZero.map((i) => (i % 50) + 1),
        any.positiveIntOrZero.map((i) => i % 1001),
        (page, pageSize, totalItems) => (page, pageSize, totalItems),
      ),
      _explore,
    ).test('hasMore is true iff page < totalPages', (params) {
      final (page, pageSize, totalItems) = params;
      final totalPages = pageSize > 0 ? (totalItems / pageSize).ceil() : 0;

      final list = PaginatedList.fromItems(
        List.generate(pageSize.clamp(0, totalItems), (i) => i),
        page: page.clamp(1, totalPages.clamp(1, 100)),
        pageSize: pageSize,
        totalItems: totalItems,
      );

      final expectedHasMore = list.page < list.totalPages;
      expect(list.hasMore, equals(expectedHasMore));
    });

    test('hasMore is false when on last page', () {
      final list = PaginatedList.fromItems(
        [1, 2, 3],
        page: 5,
        pageSize: 10,
        totalItems: 50,
      );

      expect(list.hasMore, isFalse);
      expect(list.isLastPage, isTrue);
    });

    test('hasMore is true when not on last page', () {
      final list = PaginatedList.fromItems(
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        page: 1,
        pageSize: 10,
        totalItems: 50,
      );

      expect(list.hasMore, isTrue);
      expect(list.isLastPage, isFalse);
    });

    test('empty list has hasMore false', () {
      final list = PaginatedList<int>.empty();

      expect(list.hasMore, isFalse);
      expect(list.isEmpty, isTrue);
    });
  });

  group('PaginatedList map Properties', () {
    Glados<List<int>>(any.list(any.int), _explore).test(
      'map preserves pagination metadata',
      (items) {
        final list = PaginatedList.fromItems(
          items,
          page: 1,
          pageSize: 20,
          totalItems: items.length + 100,
        );

        final mapped = list.map((i) => i.toString());

        expect(mapped.page, equals(list.page));
        expect(mapped.pageSize, equals(list.pageSize));
        expect(mapped.totalItems, equals(list.totalItems));
        expect(mapped.totalPages, equals(list.totalPages));
        expect(mapped.hasMore, equals(list.hasMore));
        expect(mapped.items.length, equals(list.items.length));
      },
    );

    Glados<List<int>>(any.list(any.int), _explore).test(
      'map transforms all items',
      (items) {
        final list = PaginatedList.fromItems(
          items,
          page: 1,
          pageSize: 20,
          totalItems: items.length,
        );

        final mapped = list.map((i) => i * 2);

        for (var i = 0; i < items.length; i++) {
          expect(mapped.items[i], equals(items[i] * 2));
        }
      },
    );
  });

  group('PaginatedList concat Properties', () {
    test('concat combines items from both lists', () {
      final list1 = PaginatedList.fromItems(
        [1, 2, 3],
        page: 1,
        pageSize: 3,
        totalItems: 6,
      );

      final list2 = PaginatedList.fromItems(
        [4, 5, 6],
        page: 2,
        pageSize: 3,
        totalItems: 6,
      );

      final combined = list1.concat(list2);

      expect(combined.items, equals([1, 2, 3, 4, 5, 6]));
      expect(combined.page, equals(2));
      expect(combined.hasMore, equals(list2.hasMore));
    });

    test('concat updates pagination from second list', () {
      final list1 = PaginatedList.fromItems(
        [1, 2, 3],
        page: 1,
        pageSize: 3,
        totalItems: 9,
      );

      final list2 = PaginatedList.fromItems(
        [4, 5, 6],
        page: 2,
        pageSize: 3,
        totalItems: 9,
      );

      final combined = list1.concat(list2);

      expect(combined.page, equals(2));
      expect(combined.totalItems, equals(9));
      expect(combined.hasMore, isTrue);
    });
  });

  group('PaginatedList utility methods', () {
    test('isEmpty returns true for empty list', () {
      final list = PaginatedList<int>.empty();
      expect(list.isEmpty, isTrue);
      expect(list.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true for non-empty list', () {
      final list = PaginatedList.fromItems(
        [1, 2, 3],
        page: 1,
        pageSize: 10,
        totalItems: 3,
      );
      expect(list.isEmpty, isFalse);
      expect(list.isNotEmpty, isTrue);
    });

    test('isFirstPage returns true for page 1', () {
      final list = PaginatedList.fromItems(
        [1, 2, 3],
        page: 1,
        pageSize: 10,
        totalItems: 30,
      );
      expect(list.isFirstPage, isTrue);
    });

    test('isFirstPage returns false for page > 1', () {
      final list = PaginatedList.fromItems(
        [1, 2, 3],
        page: 2,
        pageSize: 10,
        totalItems: 30,
      );
      expect(list.isFirstPage, isFalse);
    });

    test('itemAt returns item at valid index', () {
      final list = PaginatedList.fromItems(
        [1, 2, 3],
        page: 1,
        pageSize: 10,
        totalItems: 3,
      );
      expect(list.itemAt(0), equals(1));
      expect(list.itemAt(1), equals(2));
      expect(list.itemAt(2), equals(3));
    });

    test('itemAt returns null for invalid index', () {
      final list = PaginatedList.fromItems(
        [1, 2, 3],
        page: 1,
        pageSize: 10,
        totalItems: 3,
      );
      expect(list.itemAt(-1), isNull);
      expect(list.itemAt(3), isNull);
      expect(list.itemAt(100), isNull);
    });

    test('where filters items preserving metadata', () {
      final list = PaginatedList.fromItems(
        [1, 2, 3, 4, 5],
        page: 1,
        pageSize: 10,
        totalItems: 5,
      );

      final filtered = list.where((i) => i.isEven);

      expect(filtered.items, equals([2, 4]));
      expect(filtered.page, equals(list.page));
      expect(filtered.totalItems, equals(list.totalItems));
    });
  });
}
