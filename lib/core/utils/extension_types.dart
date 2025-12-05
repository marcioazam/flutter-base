/// Extension types for domain safety (Dart 3.6+).
/// Zero-cost type wrappers for compile-time type safety.
library;

/// User identifier extension type.
extension type const UserId(String value) {
  /// Creates UserId from string with validation.
  factory UserId.fromString(String s) {
    if (s.isEmpty) {
      throw ArgumentError.value(s, 'value', 'UserId cannot be empty');
    }
    return UserId(s);
  }

  /// Creates UserId or returns null if invalid.
  static UserId? tryParse(String s) {
    if (s.isEmpty) return null;
    return UserId(s);
  }

  /// Check if valid.
  bool get isValid => value.isNotEmpty;
}

/// Email extension type with validation.
extension type const Email(String value) {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Creates Email from string with validation.
  factory Email.fromString(String s) {
    final trimmed = s.trim().toLowerCase();
    if (!_emailRegex.hasMatch(trimmed)) {
      throw ArgumentError.value(s, 'value', 'Invalid email format');
    }
    return Email(trimmed);
  }

  /// Creates Email or returns null if invalid.
  static Email? tryParse(String s) {
    final trimmed = s.trim().toLowerCase();
    if (!_emailRegex.hasMatch(trimmed)) return null;
    return Email(trimmed);
  }

  /// Returns the domain part of the email.
  String get domain => value.split('@').last;

  /// Returns the local part of the email.
  String get localPart => value.split('@').first;

  /// Check if valid.
  bool get isValid => _emailRegex.hasMatch(value);
}

/// API path extension type for type-safe URL building.
extension type const ApiPath(String value) {
  /// Creates ApiPath from string.
  factory ApiPath.fromString(String s) {
    if (s.isEmpty) {
      throw ArgumentError.value(s, 'value', 'ApiPath cannot be empty');
    }
    return ApiPath(s.startsWith('/') ? s : '/$s');
  }

  /// Concatenates path segments.
  ApiPath operator /(String segment) {
    final cleanSegment = segment.startsWith('/') ? segment.substring(1) : segment;
    return ApiPath('$value/$cleanSegment');
  }

  /// Adds query parameters.
  String withQuery(Map<String, dynamic> params) {
    if (params.isEmpty) return value;
    final query = params.entries
        .where((e) => e.value != null)
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    return '$value?$query';
  }
}

/// Phone number extension type.
extension type const PhoneNumber(String value) {
  static final _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  /// Creates PhoneNumber from string with validation.
  factory PhoneNumber.fromString(String s) {
    final cleaned = s.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!_phoneRegex.hasMatch(cleaned)) {
      throw ArgumentError.value(s, 'value', 'Invalid phone format');
    }
    return PhoneNumber(cleaned);
  }

  /// Creates PhoneNumber or returns null if invalid.
  static PhoneNumber? tryParse(String s) {
    final cleaned = s.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!_phoneRegex.hasMatch(cleaned)) return null;
    return PhoneNumber(cleaned);
  }

  /// Check if valid.
  bool get isValid => _phoneRegex.hasMatch(value);
}

/// Positive integer extension type.
extension type const PositiveInt(int value) {
  /// Creates PositiveInt with validation.
  factory PositiveInt.fromInt(int n) {
    if (n < 0) {
      throw ArgumentError.value(n, 'value', 'Must be non-negative');
    }
    return PositiveInt(n);
  }

  /// Creates PositiveInt or returns null if invalid.
  static PositiveInt? tryParse(int n) {
    if (n < 0) return null;
    return PositiveInt(n);
  }
}

/// Non-empty string extension type.
extension type const NonEmptyString(String value) {
  /// Creates NonEmptyString with validation.
  factory NonEmptyString.fromString(String s) {
    if (s.trim().isEmpty) {
      throw ArgumentError.value(s, 'value', 'String cannot be empty');
    }
    return NonEmptyString(s.trim());
  }

  /// Creates NonEmptyString or returns null if invalid.
  static NonEmptyString? tryParse(String s) {
    if (s.trim().isEmpty) return null;
    return NonEmptyString(s.trim());
  }
}
