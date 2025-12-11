/// Shared validation patterns to avoid duplication.
/// 
/// Use these patterns with lib/core/utils/validation.dart
library;

/// Common regex patterns for validation.
abstract final class ValidationPatterns {
  /// Email validation pattern (RFC 5322 simplified).
  static final email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone number pattern (international format).
  static final phone = RegExp(
    r'^\+?[\d\s\-\(\)]{10,}$',
  );

  /// Strong password pattern (8+ chars, upper, lower, digit).
  static final strongPassword = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
  );

  /// URL pattern (http/https).
  static final url = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// UUID v4 pattern.
  static final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Alphanumeric pattern.
  static final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

  /// Slug pattern (lowercase, numbers, hyphens).
  static final slug = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  /// Credit card pattern (basic validation).
  static final creditCard = RegExp(r'^\d{13,19}$');

  /// Brazilian CPF pattern.
  static final cpf = RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$');

  /// Brazilian CNPJ pattern.
  static final cnpj = RegExp(r'^\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}$');

  /// Brazilian CEP pattern.
  static final cep = RegExp(r'^\d{5}-?\d{3}$');
}
