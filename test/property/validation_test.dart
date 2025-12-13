import 'package:flutter_base_2025/core/utils/validation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-state-of-art-2025-final, Property 14: Validator Composition**
/// **Validates: Requirements 13.2**
void main() {
  group('TypedValidators Composition Properties', () {
    /// **Property 14: Validator Composition**
    /// *For any* list of validators, compose should return invalid
    /// if any validator returns invalid.
    Glados<String>(any.nonEmptyLetters, _explore).test(
      'compose returns invalid if any validator fails',
      (value) {
        // Create a validator that always fails
        ValidationResult<Object?> alwaysFails(Object? _) =>
            Invalid.single('test', 'Always fails');

        // Create a validator that always passes
        ValidationResult<Object?> alwaysPasses(Object? v) => Valid(v);

        // Composite with one failing validator should be invalid
        final composite = TypedValidators.compose([alwaysPasses, alwaysFails]);
        final result = composite(value);

        expect(result.isInvalid, isTrue);
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'compose returns valid only if all validators pass',
      (value) {
        ValidationResult<Object?> validator1(Object? v) => Valid(v);
        ValidationResult<Object?> validator2(Object? v) => Valid(v);

        final composite = TypedValidators.compose([validator1, validator2]);
        final result = composite(value);

        expect(result.isValid, isTrue);
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'compose collects all errors from failing validators',
      (value) {
        ValidationResult<Object?> validator1(Object? _) =>
            Invalid.single('field1', 'Error 1');
        ValidationResult<Object?> validator2(Object? _) =>
            Invalid.single('field2', 'Error 2');

        final composite = TypedValidators.compose([validator1, validator2]);
        final result = composite(value);

        expect(result.isInvalid, isTrue);
        if (result is Invalid<String>) {
          expect(result.errors.keys.length, equals(2));
          expect(result.errors.containsKey('field1'), isTrue);
          expect(result.errors.containsKey('field2'), isTrue);
        }
      },
    );
  });

  group('TypedValidators.required Properties', () {
    test('required fails for empty string', () {
      final validator = TypedValidators.required();
      expect(validator('').isInvalid, isTrue);
      expect(validator('   ').isInvalid, isTrue);
    });

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'required passes for non-empty strings',
      (value) {
        final validator = TypedValidators.required();
        expect(validator(value).isValid, isTrue);
      },
    );
  });

  group('TypedValidators.email Properties', () {
    final validEmails = [
      'test@example.com',
      'user.name@domain.org',
      'user+tag@example.co.uk',
    ];

    final invalidEmails = ['invalid', 'missing@domain', '@nodomain.com'];

    for (final email in validEmails) {
      test('email passes for valid email: $email', () {
        final validator = TypedValidators.email();
        expect(validator(email).isValid, isTrue);
      });
    }

    for (final email in invalidEmails) {
      test('email fails for invalid email: $email', () {
        final validator = TypedValidators.email();
        expect(validator(email).isInvalid, isTrue);
      });
    }
  });

  group('TypedValidators.minLength Properties', () {
    Glados<int>(any.int, _explore).test(
      'minLength passes for strings >= minLength',
      (minLength) {
        final adjustedMin = (minLength.abs() % 20) + 1;
        final validator = TypedValidators.minLength(adjustedMin);

        final validString = 'a' * adjustedMin;
        expect(validator(validString).isValid, isTrue);

        final longerString = 'a' * (adjustedMin + 5);
        expect(validator(longerString).isValid, isTrue);
      },
    );

    Glados<int>(any.int, _explore).test(
      'minLength fails for strings < minLength',
      (minLength) {
        final adjustedMin = (minLength.abs() % 20) + 2;
        final validator = TypedValidators.minLength(adjustedMin);

        final shortString = 'a' * (adjustedMin - 1);
        expect(validator(shortString).isInvalid, isTrue);
      },
    );
  });

  group('TypedValidators.range Properties', () {
    Glados<int>(any.int, _explore).test(
      'range passes for values within range',
      (value) {
        final min = value - 10;
        final max = value + 10;
        final validator = TypedValidators.range(min, max);

        expect(validator(value).isValid, isTrue);
      },
    );

    test('range fails for values below min', () {
      final validator = TypedValidators.range(18, 100);

      expect(validator(17).isInvalid, isTrue);
      expect(validator(18).isValid, isTrue);
    });

    test('range fails for values above max', () {
      final validator = TypedValidators.range(18, 100);

      expect(validator(101).isInvalid, isTrue);
      expect(validator(100).isValid, isTrue);
    });
  });

  group('ValidationResult Properties', () {
    test('Valid and Invalid are exhaustive', () {
      final valid = Valid('test');
      final invalid = Invalid<String>.single('field', 'error');

      expect(valid.isValid, isTrue);
      expect(valid.isInvalid, isFalse);
      expect(invalid.isValid, isFalse);
      expect(invalid.isInvalid, isTrue);
    });

    test('Invalid.merge combines errors from both results', () {
      final result1 = Invalid<String>.single('field1', 'error1');
      final result2 = Invalid<String>.single('field2', 'error2');

      final merged = result1.merge(result2);
      expect(merged.errors.containsKey('field1'), isTrue);
      expect(merged.errors.containsKey('field2'), isTrue);
    });

    test('Invalid.merge combines errors for same field', () {
      final result1 = Invalid<String>.single('field', 'error1');
      final result2 = Invalid<String>.single('field', 'error2');

      final merged = result1.merge(result2);
      expect(merged.errorsFor('field'), contains('error1'));
      expect(merged.errorsFor('field'), contains('error2'));
    });

    test('fold executes correct branch', () {
      final valid = Valid('test');
      final invalid = Invalid<String>.single('field', 'error');

      final validResult = valid.fold(
        (errors) => 'invalid',
        (value) => 'valid: $value',
      );
      expect(validResult, equals('valid: test'));

      final invalidResult = invalid.fold(
        (errors) => 'invalid: ${errors.keys.first}',
        (value) => 'valid',
      );
      expect(invalidResult, equals('invalid: field'));
    });
  });
}
