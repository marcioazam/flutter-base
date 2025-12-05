/// Generic validation infrastructure.
/// Provides composable validators following SOLID principles.

/// Result of a validation operation.
class ValidationResult {
  final bool isValid;
  final Map<String, List<String>> errors;

  const ValidationResult.valid()
      : isValid = true,
        errors = const {};

  const ValidationResult.invalid(this.errors) : isValid = false;

  /// Combines two validation results.
  ValidationResult merge(ValidationResult other) {
    if (isValid && other.isValid) {
      return const ValidationResult.valid();
    }
    final mergedErrors = <String, List<String>>{};
    for (final entry in errors.entries) {
      mergedErrors[entry.key] = [...entry.value];
    }
    for (final entry in other.errors.entries) {
      mergedErrors.update(
        entry.key,
        (existing) => [...existing, ...entry.value],
        ifAbsent: () => [...entry.value],
      );
    }
    return ValidationResult.invalid(mergedErrors);
  }

  /// Returns errors for a specific field.
  List<String> errorsFor(String field) => errors[field] ?? [];

  /// Returns first error for a field, or null.
  String? firstErrorFor(String field) => errorsFor(field).firstOrNull;

  /// Returns true if field has errors.
  bool hasErrorFor(String field) => errors.containsKey(field);
}

/// Generic validator interface.
/// T = Type being validated
abstract interface class Validator<T> {
  /// Validates the value and returns result.
  ValidationResult validate(T value);

  /// Field name for error reporting.
  String get fieldName;
}

/// Async validator for server-side validation.
abstract interface class AsyncValidator<T> {
  /// Validates the value asynchronously.
  Future<ValidationResult> validate(T value);

  /// Field name for error reporting.
  String get fieldName;
}

/// Composite validator that chains multiple validators.
class CompositeValidator<T> implements Validator<T> {
  final List<Validator<T>> validators;

  @override
  final String fieldName;

  const CompositeValidator(this.validators, {this.fieldName = 'value'});

  @override
  ValidationResult validate(T value) {
    var result = const ValidationResult.valid();
    for (final validator in validators) {
      result = result.merge(validator.validate(value));
    }
    return result;
  }

  /// Creates a new composite with an additional validator.
  CompositeValidator<T> and(Validator<T> validator) {
    return CompositeValidator([...validators, validator], fieldName: fieldName);
  }
}

/// Required field validator.
class RequiredValidator<T> implements Validator<T> {
  @override
  final String fieldName;
  final String message;

  const RequiredValidator({
    required this.fieldName,
    this.message = 'This field is required',
  });

  @override
  ValidationResult validate(T value) {
    final isEmpty = value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is Iterable && value.isEmpty) ||
        (value is Map && value.isEmpty);

    if (isEmpty) {
      return ValidationResult.invalid({
        fieldName: [message]
      });
    }
    return const ValidationResult.valid();
  }
}

/// Email format validator.
class EmailValidator implements Validator<String> {
  @override
  final String fieldName;
  final String message;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  const EmailValidator({
    this.fieldName = 'email',
    this.message = 'Invalid email format',
  });

  @override
  ValidationResult validate(String value) {
    if (value.isEmpty || _emailRegex.hasMatch(value)) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid({
      fieldName: [message]
    });
  }
}

/// Minimum length validator for strings.
class MinLengthValidator implements Validator<String> {
  @override
  final String fieldName;
  final int minLength;
  final String? customMessage;

  const MinLengthValidator({
    required this.fieldName,
    required this.minLength,
    this.customMessage,
  });

  @override
  ValidationResult validate(String value) {
    if (value.length >= minLength) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid({
      fieldName: [customMessage ?? 'Must be at least $minLength characters']
    });
  }
}

/// Maximum length validator for strings.
class MaxLengthValidator implements Validator<String> {
  @override
  final String fieldName;
  final int maxLength;
  final String? customMessage;

  const MaxLengthValidator({
    required this.fieldName,
    required this.maxLength,
    this.customMessage,
  });

  @override
  ValidationResult validate(String value) {
    if (value.length <= maxLength) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid({
      fieldName: [customMessage ?? 'Must be at most $maxLength characters']
    });
  }
}

/// Pattern validator using regex.
class PatternValidator implements Validator<String> {
  @override
  final String fieldName;
  final RegExp pattern;
  final String message;

  const PatternValidator({
    required this.fieldName,
    required this.pattern,
    required this.message,
  });

  @override
  ValidationResult validate(String value) {
    if (value.isEmpty || pattern.hasMatch(value)) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid({
      fieldName: [message]
    });
  }
}

/// Range validator for numbers.
class RangeValidator<T extends num> implements Validator<T> {
  @override
  final String fieldName;
  final T? min;
  final T? max;
  final String? customMessage;

  const RangeValidator({
    required this.fieldName,
    this.min,
    this.max,
    this.customMessage,
  });

  @override
  ValidationResult validate(T value) {
    if (min != null && value < min!) {
      return ValidationResult.invalid({
        fieldName: [customMessage ?? 'Must be at least $min']
      });
    }
    if (max != null && value > max!) {
      return ValidationResult.invalid({
        fieldName: [customMessage ?? 'Must be at most $max']
      });
    }
    return const ValidationResult.valid();
  }
}

/// Custom validator with predicate function.
class PredicateValidator<T> implements Validator<T> {
  @override
  final String fieldName;
  final bool Function(T value) predicate;
  final String message;

  const PredicateValidator({
    required this.fieldName,
    required this.predicate,
    required this.message,
  });

  @override
  ValidationResult validate(T value) {
    if (predicate(value)) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid({
      fieldName: [message]
    });
  }
}

/// Extension for easy validator chaining.
extension ValidatorExtensions<T> on Validator<T> {
  /// Chains this validator with another.
  CompositeValidator<T> and(Validator<T> other) {
    return CompositeValidator([this, other], fieldName: fieldName);
  }
}
