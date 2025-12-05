import 'package:flutter_base_2025/core/validation/validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown, setUpAll, tearDownAll;

// Configure Glados for 100 iterations
final _explore = ExploreConfig(numRuns: 100);

/// **Feature: flutter-state-of-art-2025-final, Property 14: Validator Composition**
/// **Validates: Requirements 13.2**
void main() {
  group('Validator Composition Properties', () {
    /// **Property 14: Validator Composition**
    /// *For any* list of validators, CompositeValidator should return invalid
    /// if any validator returns invalid.
    Glados<String>(any.nonEmptyLetters, _explore).test(
      'CompositeValidator returns invalid if any validator fails',
      (value) {
        // Create a validator that always fails
        final alwaysFails = PredicateValidator<String>(
          fieldName: 'test',
          predicate: (_) => false,
          message: 'Always fails',
        );

        // Create a validator that always passes
        final alwaysPasses = PredicateValidator<String>(
          fieldName: 'test',
          predicate: (_) => true,
          message: 'Always passes',
        );

        // Composite with one failing validator should be invalid
        final composite = CompositeValidator([alwaysPasses, alwaysFails]);
        final result = composite.validate(value);

        expect(result.isValid, isFalse);
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'CompositeValidator returns valid only if all validators pass',
      (value) {
        final validator1 = PredicateValidator<String>(
          fieldName: 'test',
          predicate: (_) => true,
          message: 'Pass 1',
        );

        final validator2 = PredicateValidator<String>(
          fieldName: 'test',
          predicate: (_) => true,
          message: 'Pass 2',
        );

        final composite = CompositeValidator([validator1, validator2]);
        final result = composite.validate(value);

        expect(result.isValid, isTrue);
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'CompositeValidator collects all errors from failing validators',
      (value) {
        final validator1 = PredicateValidator<String>(
          fieldName: 'field1',
          predicate: (_) => false,
          message: 'Error 1',
        );

        final validator2 = PredicateValidator<String>(
          fieldName: 'field2',
          predicate: (_) => false,
          message: 'Error 2',
        );

        final composite = CompositeValidator([validator1, validator2]);
        final result = composite.validate(value);

        expect(result.isValid, isFalse);
        expect(result.errors.keys.length, equals(2));
        expect(result.hasErrorFor('field1'), isTrue);
        expect(result.hasErrorFor('field2'), isTrue);
      },
    );
  });

  group('RequiredValidator Properties', () {
    test('RequiredValidator fails for empty string', () {
      final validator = RequiredValidator<String>(fieldName: 'name');
      expect(validator.validate('').isValid, isFalse);
      expect(validator.validate('   ').isValid, isFalse);
    });

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'RequiredValidator passes for non-empty strings',
      (value) {
        final validator = RequiredValidator<String>(fieldName: 'name');
        expect(validator.validate(value).isValid, isTrue);
      },
    );

    test('RequiredValidator fails for null', () {
      final validator = RequiredValidator<String?>(fieldName: 'name');
      expect(validator.validate(null).isValid, isFalse);
    });
  });

  group('EmailValidator Properties', () {
    final validEmails = [
      'test@example.com',
      'user.name@domain.org',
      'user+tag@example.co.uk',
    ];

    final invalidEmails = [
      'invalid',
      'missing@domain',
      '@nodomain.com',
      'spaces in@email.com',
    ];

    for (final email in validEmails) {
      test('EmailValidator passes for valid email: $email', () {
        final validator = EmailValidator();
        expect(validator.validate(email).isValid, isTrue);
      });
    }

    for (final email in invalidEmails) {
      test('EmailValidator fails for invalid email: $email', () {
        final validator = EmailValidator();
        expect(validator.validate(email).isValid, isFalse);
      });
    }

    test('EmailValidator passes for empty string (optional field)', () {
      final validator = EmailValidator();
      expect(validator.validate('').isValid, isTrue);
    });
  });

  group('MinLengthValidator Properties', () {
    Glados<int>(any.int, _explore).test(
      'MinLengthValidator passes for strings >= minLength',
      (minLength) {
        final adjustedMin = (minLength.abs() % 20) + 1;
        final validator = MinLengthValidator(
          fieldName: 'password',
          minLength: adjustedMin,
        );

        final validString = 'a' * adjustedMin;
        expect(validator.validate(validString).isValid, isTrue);

        final longerString = 'a' * (adjustedMin + 5);
        expect(validator.validate(longerString).isValid, isTrue);
      },
    );

    Glados<int>(any.int, _explore).test(
      'MinLengthValidator fails for strings < minLength',
      (minLength) {
        final adjustedMin = (minLength.abs() % 20) + 2;
        final validator = MinLengthValidator(
          fieldName: 'password',
          minLength: adjustedMin,
        );

        final shortString = 'a' * (adjustedMin - 1);
        expect(validator.validate(shortString).isValid, isFalse);
      },
    );
  });

  group('RangeValidator Properties', () {
    Glados<int>(any.int, _explore).test(
      'RangeValidator passes for values within range',
      (value) {
        final min = value - 10;
        final max = value + 10;
        final validator = RangeValidator<int>(
          fieldName: 'age',
          min: min,
          max: max,
        );

        expect(validator.validate(value).isValid, isTrue);
      },
    );

    test('RangeValidator fails for values below min', () {
      final validator = RangeValidator<int>(
        fieldName: 'age',
        min: 18,
        max: 100,
      );

      expect(validator.validate(17).isValid, isFalse);
      expect(validator.validate(18).isValid, isTrue);
    });

    test('RangeValidator fails for values above max', () {
      final validator = RangeValidator<int>(
        fieldName: 'age',
        min: 18,
        max: 100,
      );

      expect(validator.validate(101).isValid, isFalse);
      expect(validator.validate(100).isValid, isTrue);
    });
  });

  group('ValidationResult Merge Properties', () {
    test('Merging two valid results produces valid result', () {
      const result1 = ValidationResult.valid();
      const result2 = ValidationResult.valid();

      final merged = result1.merge(result2);
      expect(merged.isValid, isTrue);
    });

    test('Merging valid with invalid produces invalid result', () {
      const result1 = ValidationResult.valid();
      final result2 = ValidationResult.invalid({
        'field': ['error']
      });

      final merged = result1.merge(result2);
      expect(merged.isValid, isFalse);
      expect(merged.hasErrorFor('field'), isTrue);
    });

    test('Merging combines errors from both results', () {
      final result1 = ValidationResult.invalid({
        'field1': ['error1']
      });
      final result2 = ValidationResult.invalid({
        'field2': ['error2']
      });

      final merged = result1.merge(result2);
      expect(merged.isValid, isFalse);
      expect(merged.hasErrorFor('field1'), isTrue);
      expect(merged.hasErrorFor('field2'), isTrue);
    });

    test('Merging combines errors for same field', () {
      final result1 = ValidationResult.invalid({
        'field': ['error1']
      });
      final result2 = ValidationResult.invalid({
        'field': ['error2']
      });

      final merged = result1.merge(result2);
      expect(merged.errorsFor('field'), contains('error1'));
      expect(merged.errorsFor('field'), contains('error2'));
    });
  });
}
