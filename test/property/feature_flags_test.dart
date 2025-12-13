import 'package:flutter_base_2025/core/config/feature_flags.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-modernization-2025, Property 9: Feature Flag Consistency**
/// **Validates: Requirements 21.4**

void main() {
  group('Feature Flag Consistency Properties', () {
    late LocalFeatureFlags featureFlags;

    setUp(() async {
      featureFlags = LocalFeatureFlags();
      await featureFlags.initialize();
    });

    test('isEnabled returns consistent value for same flag', () {
      const flagName = 'test_feature';
      featureFlags.setFlag(flagName, true);

      // Call multiple times
      final results = List.generate(100, (_) => featureFlags.isEnabled(flagName));

      // All results should be the same
      expect(results.every((r) => r == true), isTrue);
    });

    test('isEnabled returns false for undefined flag', () {
      const flagName = 'undefined_flag_xyz';

      final result = featureFlags.isEnabled(flagName);

      expect(result, isFalse);
    });

    Glados<bool>(any.bool, _explore).test(
      'setFlag and isEnabled are consistent',
      (value) {
        const flagName = 'dynamic_flag';
        featureFlags.setFlag(flagName, value);

        expect(featureFlags.isEnabled(flagName), equals(value));
      },
    );

    Glados<int>(any.int, _explore).test(
      'getValue returns correct int value',
      (value) {
        const flagName = 'int_flag';
        featureFlags.setFlag(flagName, value);

        expect(featureFlags.getValue<int>(flagName, 0), equals(value));
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'getValue returns correct string value',
      (value) {
        const flagName = 'string_flag';
        featureFlags.setFlag(flagName, value);

        expect(featureFlags.getValue<String>(flagName, ''), equals(value));
      },
    );

    Glados<double>(any.double, _explore).test(
      'getValue returns correct double value',
      (value) {
        if (value.isNaN || value.isInfinite) return;
        
        const flagName = 'double_flag';
        featureFlags.setFlag(flagName, value);

        expect(featureFlags.getValue<double>(flagName, 0), equals(value));
      },
    );

    test('getValue returns default for wrong type', () {
      const flagName = 'type_mismatch';
      featureFlags.setFlag(flagName, 'string_value');

      // Asking for int should return default
      expect(featureFlags.getValue<int>(flagName, 42), equals(42));
    });

    test('getValue returns default for undefined flag', () {
      const flagName = 'undefined_flag';

      expect(featureFlags.getValue<int>(flagName, 99), equals(99));
      expect(featureFlags.getValue<String>(flagName, 'default'), equals('default'));
      expect(featureFlags.getValue<bool>(flagName, true), isTrue);
    });

    test('getAllFlags returns all flags', () async {
      featureFlags.setFlag('flag1', true);
      featureFlags.setFlag('flag2', 'value');
      featureFlags.setFlag('flag3', 123);

      final allFlags = featureFlags.getAllFlags();

      expect(allFlags['flag1'], isTrue);
      expect(allFlags['flag2'], equals('value'));
      expect(allFlags['flag3'], equals(123));
    });

    test('reset restores default values', () async {
      featureFlags.setFlag('custom_flag', true);
      expect(featureFlags.isEnabled('custom_flag'), isTrue);

      featureFlags.reset();

      // Custom flag should be gone, defaults should be back
      expect(featureFlags.isEnabled('custom_flag'), isFalse);
      expect(featureFlags.isEnabled('dark_mode_enabled'), isTrue); // Default
    });

    test('fetch does not change local flags', () async {
      featureFlags.setFlag('local_flag', true);

      await featureFlags.fetch();

      expect(featureFlags.isEnabled('local_flag'), isTrue);
    });

    test('flags are isolated between instances', () async {
      final flags1 = LocalFeatureFlags();
      final flags2 = LocalFeatureFlags();

      await flags1.initialize();
      await flags2.initialize();

      flags1.setFlag('isolated_flag', true);

      expect(flags1.isEnabled('isolated_flag'), isTrue);
      expect(flags2.isEnabled('isolated_flag'), isFalse);
    });

    test('default flags are loaded on initialize', () async {
      final flags = LocalFeatureFlags();
      await flags.initialize();

      // Check default flags from LocalFeatureFlags
      expect(flags.isEnabled('dark_mode_enabled'), isTrue);
      expect(flags.getValue<int>('max_items_per_page', 0), equals(20));
      expect(flags.getValue<int>('api_timeout_seconds', 0), equals(30));
    });
  });
}
