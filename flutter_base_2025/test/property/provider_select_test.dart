import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: flutter-modernization-2025, Property 7: Provider Select Rebuild Optimization**
/// **Validates: Requirements 12.4**

/// Test state with multiple fields.
class TestState {
  final int count;
  final String name;
  final bool active;

  const TestState({
    required this.count,
    required this.name,
    required this.active,
  });

  TestState copyWith({int? count, String? name, bool? active}) => TestState(
        count: count ?? this.count,
        name: name ?? this.name,
        active: active ?? this.active,
      );
}

/// Test notifier for state management.
class TestStateNotifier extends Notifier<TestState> {
  @override
  TestState build() => const TestState(count: 0, name: 'initial', active: false);

  void incrementCount() {
    state = state.copyWith(count: state.count + 1);
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void toggleActive() {
    state = state.copyWith(active: !state.active);
  }
}

final testStateProvider =
    NotifierProvider<TestStateNotifier, TestState>(TestStateNotifier.new);

void main() {
  group('Provider Select Rebuild Optimization Properties', () {
    test('select only rebuilds when selected value changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var countRebuildCount = 0;
      var nameRebuildCount = 0;

      // Listen to count only
      container.listen(
        testStateProvider.select((s) => s.count),
        (_, __) => countRebuildCount++,
        fireImmediately: true,
      );

      // Listen to name only
      container.listen(
        testStateProvider.select((s) => s.name),
        (_, __) => nameRebuildCount++,
        fireImmediately: true,
      );

      // Initial fire
      expect(countRebuildCount, equals(1));
      expect(nameRebuildCount, equals(1));

      // Update count - only count listener should rebuild
      container.read(testStateProvider.notifier).incrementCount();
      expect(countRebuildCount, equals(2));
      expect(nameRebuildCount, equals(1)); // No rebuild

      // Update name - only name listener should rebuild
      container.read(testStateProvider.notifier).updateName('updated');
      expect(countRebuildCount, equals(2)); // No rebuild
      expect(nameRebuildCount, equals(2));

      // Update active - neither should rebuild
      container.read(testStateProvider.notifier).toggleActive();
      expect(countRebuildCount, equals(2)); // No rebuild
      expect(nameRebuildCount, equals(2)); // No rebuild
    });

    test('select with same value does not trigger rebuild', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var rebuildCount = 0;

      container.listen(
        testStateProvider.select((s) => s.count),
        (_, __) => rebuildCount++,
        fireImmediately: true,
      );

      expect(rebuildCount, equals(1));

      // Update name (count stays same)
      container.read(testStateProvider.notifier).updateName('new name');
      expect(rebuildCount, equals(1)); // No rebuild

      // Update active (count stays same)
      container.read(testStateProvider.notifier).toggleActive();
      expect(rebuildCount, equals(1)); // No rebuild
    });

    test('multiple selects on same provider work independently', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var countRebuilds = 0;
      var nameRebuilds = 0;
      var activeRebuilds = 0;

      container.listen(
        testStateProvider.select((s) => s.count),
        (_, __) => countRebuilds++,
        fireImmediately: true,
      );

      container.listen(
        testStateProvider.select((s) => s.name),
        (_, __) => nameRebuilds++,
        fireImmediately: true,
      );

      container.listen(
        testStateProvider.select((s) => s.active),
        (_, __) => activeRebuilds++,
        fireImmediately: true,
      );

      // All start at 1 (fireImmediately)
      expect(countRebuilds, equals(1));
      expect(nameRebuilds, equals(1));
      expect(activeRebuilds, equals(1));

      // Update each field
      container.read(testStateProvider.notifier).incrementCount();
      expect(countRebuilds, equals(2));
      expect(nameRebuilds, equals(1));
      expect(activeRebuilds, equals(1));

      container.read(testStateProvider.notifier).updateName('test');
      expect(countRebuilds, equals(2));
      expect(nameRebuilds, equals(2));
      expect(activeRebuilds, equals(1));

      container.read(testStateProvider.notifier).toggleActive();
      expect(countRebuilds, equals(2));
      expect(nameRebuilds, equals(2));
      expect(activeRebuilds, equals(2));
    });

    test('computed select only rebuilds when computed value changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var rebuildCount = 0;

      // Select computed value (count > 5)
      container.listen(
        testStateProvider.select((s) => s.count > 5),
        (_, __) => rebuildCount++,
        fireImmediately: true,
      );

      expect(rebuildCount, equals(1));

      // Increment from 0 to 1 (still false, no rebuild)
      container.read(testStateProvider.notifier).incrementCount();
      expect(rebuildCount, equals(1));

      // Increment to 6 (now true, should rebuild)
      for (var i = 0; i < 5; i++) {
        container.read(testStateProvider.notifier).incrementCount();
      }
      expect(rebuildCount, equals(2));

      // Increment to 7 (still true, no rebuild)
      container.read(testStateProvider.notifier).incrementCount();
      expect(rebuildCount, equals(2));
    });
  });
}
