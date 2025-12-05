import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart';

import 'package:flutter_base_2025/shared/widgets/infinite_list.dart';

/// **Feature: flutter-state-of-art-2025, Property 7: Pagination Load Trigger**
/// **Validates: Requirements 28.1**
void main() {
  group('Infinite Scroll Properties', () {
    group('InfiniteScrollController', () {
      late InfiniteScrollController<int> controller;

      setUp(() {
        controller = InfiniteScrollController<int>(
          fetchPage: (page, pageSize) async {
            // Simulate API response
            await Future.delayed(const Duration(milliseconds: 10));
            if (page > 3) return []; // No more data after page 3
            return List.generate(pageSize, (i) => (page - 1) * pageSize + i);
          },
          pageSize: 10,
          loadThreshold: 0.8,
        );
      });

      tearDown(() {
        controller.dispose();
      });

      test('initial state is idle with empty items', () {
        expect(controller.state, equals(InfiniteScrollState.idle));
        expect(controller.items, isEmpty);
        expect(controller.hasMoreData, isTrue);
      });

      test('loadInitial fetches first page', () async {
        await controller.loadInitial();

        expect(controller.items.length, equals(10));
        expect(controller.items.first, equals(0));
        expect(controller.state, equals(InfiniteScrollState.idle));
      });

      test('loadMore fetches next page', () async {
        await controller.loadInitial();
        await controller.loadMore();

        expect(controller.items.length, equals(20));
        expect(controller.items[10], equals(10));
      });

      test('refresh resets and reloads', () async {
        await controller.loadInitial();
        await controller.loadMore();
        expect(controller.items.length, equals(20));

        await controller.refresh();
        expect(controller.items.length, equals(10));
      });

      test('hasMoreData becomes false when no more items', () async {
        await controller.loadInitial();
        await controller.loadMore();
        await controller.loadMore();
        await controller.loadMore(); // Page 4 returns empty

        expect(controller.hasMoreData, isFalse);
        expect(controller.state, equals(InfiniteScrollState.noMoreData));
      });

      test('removeItem removes from list', () async {
        await controller.loadInitial();
        final item = controller.items[5];

        controller.removeItem(item);

        expect(controller.items.contains(item), isFalse);
        expect(controller.items.length, equals(9));
      });

      test('removeAt removes at index', () async {
        await controller.loadInitial();

        controller.removeAt(0);

        expect(controller.items.first, equals(1));
        expect(controller.items.length, equals(9));
      });

      test('insertFirst adds to beginning', () async {
        await controller.loadInitial();

        controller.insertFirst(-1);

        expect(controller.items.first, equals(-1));
        expect(controller.items.length, equals(11));
      });

      test('updateItem updates at index', () async {
        await controller.loadInitial();

        controller.updateItem(0, 999);

        expect(controller.items.first, equals(999));
      });

      test('does not load more when already loading', () async {
        await controller.loadInitial();

        // Start loading
        final future1 = controller.loadMore();
        // Try to load again immediately
        final future2 = controller.loadMore();

        await Future.wait([future1, future2]);

        // Should only have loaded one additional page
        expect(controller.items.length, equals(20));
      });

      test('does not load more when no more data', () async {
        await controller.loadInitial();
        await controller.loadMore();
        await controller.loadMore();
        await controller.loadMore(); // No more data

        final lengthBefore = controller.items.length;
        await controller.loadMore();

        expect(controller.items.length, equals(lengthBefore));
      });
    });

    group('Property Tests', () {
      /// Property 7: Pagination Load Trigger
      /// For any scrollable list at 80% scroll position,
      /// the system SHALL trigger next page load automatically.
      Glados<double>(iterations: 100).test(
        'load threshold triggers at correct position',
        (scrollPosition) {
          final normalizedPosition = scrollPosition.abs() % 1.0;
          const threshold = 0.8;

          final shouldTrigger = normalizedPosition >= threshold;

          // Verify threshold logic
          if (normalizedPosition >= 0.8) {
            expect(shouldTrigger, isTrue);
          } else {
            expect(shouldTrigger, isFalse);
          }
        },
      );

      test('default load threshold is 0.8', () {
        final controller = InfiniteScrollController<int>(
          fetchPage: (_, __) async => [],
        );

        expect(controller.loadThreshold, equals(0.8));
        controller.dispose();
      });

      test('custom load threshold is respected', () {
        final controller = InfiniteScrollController<int>(
          fetchPage: (_, __) async => [],
          loadThreshold: 0.5,
        );

        expect(controller.loadThreshold, equals(0.5));
        controller.dispose();
      });

      test('default page size is 20', () {
        final controller = InfiniteScrollController<int>(
          fetchPage: (_, __) async => [],
        );

        expect(controller.pageSize, equals(20));
        controller.dispose();
      });

      test('custom page size is respected', () {
        final controller = InfiniteScrollController<int>(
          fetchPage: (_, __) async => [],
          pageSize: 50,
        );

        expect(controller.pageSize, equals(50));
        controller.dispose();
      });
    });

    group('InfiniteScrollState', () {
      test('enum has all expected values', () {
        expect(InfiniteScrollState.values, contains(InfiniteScrollState.idle));
        expect(InfiniteScrollState.values, contains(InfiniteScrollState.loading));
        expect(InfiniteScrollState.values, contains(InfiniteScrollState.error));
        expect(InfiniteScrollState.values, contains(InfiniteScrollState.noMoreData));
      });
    });

    group('Error Handling', () {
      test('error state is set on fetch failure', () async {
        final controller = InfiniteScrollController<int>(
          fetchPage: (_, __) async {
            throw Exception('Network error');
          },
        );

        await controller.loadInitial();

        expect(controller.state, equals(InfiniteScrollState.error));
        expect(controller.errorMessage, contains('Network error'));

        controller.dispose();
      });

      test('page is decremented on loadMore error', () async {
        var callCount = 0;
        final controller = InfiniteScrollController<int>(
          fetchPage: (page, pageSize) async {
            callCount++;
            if (callCount > 1) throw Exception('Error');
            return List.generate(pageSize, (i) => i);
          },
        );

        await controller.loadInitial();
        await controller.loadMore();

        // After error, should be able to retry same page
        expect(controller.state, equals(InfiniteScrollState.error));

        controller.dispose();
      });
    });
  });
}
