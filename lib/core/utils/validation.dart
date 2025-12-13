/// Generic validation system with type-safe validators and composable rules.
/// 
/// This is the primary validation module for the application.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 6.1, 6.2, 6.3, 6.4, 6.5**
library;

import 'package:flutter_base_2025/core/constants/validation_patterns.dart';
import 'package:meta/meta.dart';

/// Validator function type that returns a ValidationResult.
typedef Validator<T> = ValidationResult<T> Function(T value);

/// Validation result sealed class for exhaustive pattern matching.
sealed class ValidationResult<T> {
  const ValidationResult();

  /// Returns true if validation passed.
  bool get isValid;

  /// Returns true if validation failed.
  bool get isInvalid => !isValid;

  /// Folds the result into a single value.
  R fold<R>(
    R Function(Map<String, List<String>> errors) onInvalid,
    R Function(T value) onValid,
  );

  /// Maps the value if valid.
  ValidationResult<R> map<R>(R Function(T) mapper);

  /// Chains validation results.
  ValidationResult<R> flatMap<R>(ValidationResult<R> Function(T) mapper);
}

/// Represents a successful validation with the validated value.
@immutable
final class Valid<T> extends ValidationResult<T> {
  const Valid(this.value);
  final T value;

  @override
  bool get isValid => true;

  @override
  R fold<R>(
    R Function(Map<String, List<String>> errors) onInvalid,
    R Function(T value) onValid,
  ) => onValid(value);

  @override
  ValidationResult<R> map<R>(R Function(T) mapper) => Valid(mapper(value));

  @override
  ValidationResult<R> flatMap<R>(ValidationResult<R> Function(T) mapper) =>
      mapper(value);


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Valid<T> && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Valid($value)';
}

/// Represents a failed validation with field-specific errors.
@immutable
final class Invalid<T> extends ValidationResult<T> {
  const Invalid(this.errors);

  /// Creates Invalid with a single field error.
  factory Invalid.single(String field, String message) =>
      Invalid({field: [message]});

  /// Creates Invalid with multiple errors for a single field.
  factory Invalid.field(String field, List<String> messages) =>
      Invalid({field: messages});

  final Map<String, List<String>> errors;

  @override
  bool get isValid => false;

  @override
  R fold<R>(
    R Function(Map<String, List<String>> errors) onInvalid,
    R Function(T value) onValid,
  ) => onInvalid(errors);

  @override
  ValidationResult<R> map<R>(R Function(T) mapper) => Invalid<R>(errors);

  @override
  ValidationResult<R> flatMap<R>(ValidationResult<R> Function(T) mapper) =>
      Invalid<R>(errors);

  /// Gets all error messages as a flat list.
  List<String> get allErrors => errors.values.expand((e) => e).toList();

  /// Gets error messages for a specific field.
  List<String> errorsFor(String field) => errors[field] ?? [];

  /// Merges errors from another Invalid result.
  Invalid<T> merge(Invalid<T> other) {
    final merged = Map<String, List<String>>.from(errors);
    for (final entry in other.errors.entries) {
      merged.update(
        entry.key,
        (existing) => [...existing, ...entry.value],
        ifAbsent: () => entry.value,
      );
    }
    return Invalid(merged);
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invalid<T> &&
          runtimeType == other.runtimeType &&
          _mapsEqual(errors, other.errors);

  static bool _mapsEqual(
    Map<String, List<String>> a,
    Map<String, List<String>> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final listA = a[key]!;
      final listB = b[key]!;
      if (listA.length != listB.length) return false;
      for (var i = 0; i < listA.length; i++) {
        if (listA[i] != listB[i]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(errors.entries);

  @override
  String toString() => 'Invalid($errors)';
}

/// Composable validators with common validation rules.
abstract final class TypedValidators {
  /// Validates that a string is not empty or whitespace-only.
  static Validator<String> required({
    String field = 'value',
    String? message,
  }) => (value) {
      if (value.trim().isEmpty) {
        return Invalid.single(field, message ?? 'This field is required');
      }
      return Valid(value);
    };

  /// Validates email format using shared pattern.
  static Validator<String> email({
    String field = 'email',
    String? message,
  }) => (value) {
      if (!ValidationPatterns.email.hasMatch(value.trim())) {
        return Invalid.single(field, message ?? 'Invalid email format');
      }
      return Valid(value);
    };


  /// Validates phone format using shared pattern.
  static Validator<String> phone({
    String field = 'phone',
    String? message,
  }) => (value) {
      if (!ValidationPatterns.phone.hasMatch(value.trim())) {
        return Invalid.single(field, message ?? 'Invalid phone format');
      }
      return Valid(value);
    };

  /// Validates URL format using shared pattern.
  static Validator<String> url({
    String field = 'url',
    String? message,
  }) => (value) {
      if (!ValidationPatterns.url.hasMatch(value.trim())) {
        return Invalid.single(field, message ?? 'Invalid URL format');
      }
      return Valid(value);
    };

  /// Validates minimum length.
  static Validator<String> minLength(
    int length, {
    String field = 'value',
    String? message,
  }) => (value) {
      if (value.length < length) {
        return Invalid.single(
          field,
          message ?? 'Must be at least $length characters',
        );
      }
      return Valid(value);
    };

  /// Validates maximum length.
  static Validator<String> maxLength(
    int length, {
    String field = 'value',
    String? message,
  }) => (value) {
      if (value.length > length) {
        return Invalid.single(
          field,
          message ?? 'Must be at most $length characters',
        );
      }
      return Valid(value);
    };


  /// Validates against a regex pattern.
  static Validator<String> pattern(
    RegExp regex, {
    String field = 'value',
    String? message,
  }) => (value) {
      if (!regex.hasMatch(value)) {
        return Invalid.single(field, message ?? 'Invalid format');
      }
      return Valid(value);
    };

  /// Validates that a number is within a range.
  static Validator<num> range(
    num min,
    num max, {
    String field = 'value',
    String? message,
  }) => (value) {
      if (value < min || value > max) {
        return Invalid.single(
          field,
          message ?? 'Must be between $min and $max',
        );
      }
      return Valid(value);
    };

  /// Validates that a value is not null.
  static Validator<T?> notNull<T>({
    String field = 'value',
    String? message,
  }) => (value) {
      if (value == null) {
        return Invalid.single(field, message ?? 'Value cannot be null');
      }
      return Valid(value);
    };

  /// Composes multiple validators, aggregating all errors.
  static Validator<T> compose<T>(List<Validator<T>> validators) => (value) {
      Invalid<T>? accumulated;

      for (final validator in validators) {
        final result = validator(value);
        if (result is Invalid<T>) {
          accumulated = accumulated?.merge(result) ?? result;
        }
      }

      return accumulated ?? Valid(value);
    };


  /// Composes validators, stopping at first failure.
  static Validator<T> composeFailFast<T>(List<Validator<T>> validators) => (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result.isInvalid) {
          return result;
        }
      }
      return Valid(value);
    };

  /// Creates a conditional validator.
  static Validator<T> when<T>(
    bool Function(T) condition,
    Validator<T> validator,
  ) => (value) {
      if (condition(value)) {
        return validator(value);
      }
      return Valid(value);
    };

  /// Validates a list of items.
  static Validator<List<T>> listOf<T>(Validator<T> itemValidator) => (items) {
      final errors = <String, List<String>>{};

      for (var i = 0; i < items.length; i++) {
        final result = itemValidator(items[i]);
        if (result is Invalid<T>) {
          for (final entry in result.errors.entries) {
            final key = '[$i].${entry.key}';
            errors[key] = entry.value;
          }
        }
      }

      if (errors.isEmpty) {
        return Valid(items);
      }
      return Invalid(errors);
    };
}

/// Extension for chaining validation results.
extension ValidationResultExtensions<T> on ValidationResult<T> {
  /// Combines with another validation result.
  ValidationResult<(T, R)> and<R>(ValidationResult<R> other) => switch ((this, other)) {
      (Valid(value: final a), Valid(value: final b)) => Valid((a, b)),
      (Invalid(errors: final e1), Invalid(errors: final e2)) =>
        Invalid(_mergeErrors(e1, e2)),
      (Invalid(errors: final e), _) => Invalid(e),
      (_, Invalid(errors: final e)) => Invalid(e),
    };

  static Map<String, List<String>> _mergeErrors(
    Map<String, List<String>> a,
    Map<String, List<String>> b,
  ) {
    final merged = Map<String, List<String>>.from(a);
    for (final entry in b.entries) {
      merged.update(
        entry.key,
        (existing) => [...existing, ...entry.value],
        ifAbsent: () => entry.value,
      );
    }
    return merged;
  }
}
