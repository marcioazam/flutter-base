/// Generic validation infrastructure.
/// Provides composable validators following SOLID principles.
library;

/// Result of a validation operation.
class ValidationResult {

  const ValidationResult.valid()
      : isValid = true,
        errors = const {};

  const ValidationResult.invalid(this.errors) : isValid = false;
  final bool isValid;
  final Map<String, List<String>> errors;

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

  const CompositeValidator(this.validators, {this.fieldName = 'value'});
  final List<Validator<T>> validators;

  @override
  final String fieldName;

  @override
  ValidationResult validate(T value) {
    var result = const ValidationResult.valid();
    for (final validator in validators) {
      result = result.merge(validator.validate(value));
    }
    return result;
  }

  /// Creates a new composite with an additional validator.
  CompositeValidator<T> and(Validator<T> validator) => CompositeValidator([...validators, validator], fieldName: fieldName);
}

/// Required field validator.
class RequiredValidator<T> implements Validator<T> {

  const RequiredValidator({
    required this.fieldName,
    this.message = 'This field is required',
  });
  @override
  final String fieldName;
  final String message;

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

  const EmailValidator({
    this.fieldName = 'email',
    this.message = 'Invalid email format',
  });
  @override
  final String fieldName;
  final String message;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

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

  const MinLengthValidator({
    required this.fieldName,
    required this.minLength,
    this.customMessage,
  });
  @override
  final String fieldName;
  final int minLength;
  final String? customMessage;

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

  const MaxLengthValidator({
    required this.fieldName,
    required this.maxLength,
    this.customMessage,
  });
  @override
  final String fieldName;
  final int maxLength;
  final String? customMessage;

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

  const PatternValidator({
    required this.fieldName,
    required this.pattern,
    required this.message,
  });
  @override
  final String fieldName;
  final RegExp pattern;
  final String message;

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

  const RangeValidator({
    required this.fieldName,
    this.min,
    this.max,
    this.customMessage,
  });
  @override
  final String fieldName;
  final T? min;
  final T? max;
  final String? customMessage;

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

  const PredicateValidator({
    required this.fieldName,
    required this.predicate,
    required this.message,
  });
  @override
  final String fieldName;
  final bool Function(T value) predicate;
  final String message;

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

/// Phone number validator.
class PhoneValidator implements Validator<String> {
  const PhoneValidator({
    this.fieldName = 'phone',
    this.message = 'Invalid phone number',
  });

  @override
  final String fieldName;
  final String message;

  static final _phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');

  @override
  ValidationResult validate(String value) {
    if (value.isEmpty || _phoneRegex.hasMatch(value)) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid({
      fieldName: [message]
    });
  }
}

/// Password strength validator.
class PasswordValidator implements Validator<String> {
  const PasswordValidator({
    this.fieldName = 'password',
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireDigit = true,
    this.requireSpecialChar = false,
  });

  @override
  final String fieldName;
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireDigit;
  final bool requireSpecialChar;

  @override
  ValidationResult validate(String value) {
    final errors = <String>[];

    if (value.length < minLength) {
      errors.add('Must be at least $minLength characters');
    }
    if (requireUppercase && !value.contains(RegExp('[A-Z]'))) {
      errors.add('Must contain uppercase letter');
    }
    if (requireLowercase && !value.contains(RegExp('[a-z]'))) {
      errors.add('Must contain lowercase letter');
    }
    if (requireDigit && !value.contains(RegExp('[0-9]'))) {
      errors.add('Must contain digit');
    }
    if (requireSpecialChar && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Must contain special character');
    }

    if (errors.isEmpty) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid({fieldName: errors});
  }
}

/// Or validator that passes if any validator passes.
class OrValidator<T> implements Validator<T> {
  const OrValidator(this.validators, {this.fieldName = 'value'});
  final List<Validator<T>> validators;

  @override
  final String fieldName;

  @override
  ValidationResult validate(T value) {
    for (final validator in validators) {
      final result = validator.validate(value);
      if (result.isValid) {
        return const ValidationResult.valid();
      }
    }
    // Return errors from all validators if none passed
    var result = const ValidationResult.valid();
    for (final validator in validators) {
      result = result.merge(validator.validate(value));
    }
    return result;
  }
}

/// Extension for easy validator chaining.
extension ValidatorExtensions<T> on Validator<T> {
  /// Chains this validator with another (AND logic).
  CompositeValidator<T> and(Validator<T> other) => CompositeValidator([this, other], fieldName: fieldName);

  /// Chains this validator with another (OR logic).
  OrValidator<T> or(Validator<T> other) => OrValidator([this, other], fieldName: fieldName);
}
