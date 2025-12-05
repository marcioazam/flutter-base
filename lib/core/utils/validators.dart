/// Validation utilities.
abstract final class Validators {
  /// Email regex pattern.
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates email format.
  static bool isValidEmail(String email) => _emailRegex.hasMatch(email.trim());

  /// Validates password strength.
  static bool isValidPassword(String password) => password.length >= 6;

  /// Validates strong password (8+ chars, upper, lower, number).
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp('[A-Z]'))) return false;
    if (!password.contains(RegExp('[a-z]'))) return false;
    if (!password.contains(RegExp('[0-9]'))) return false;
    return true;
  }

  /// Validates non-empty string.
  static bool isNotEmpty(String? value) => value != null && value.trim().isNotEmpty;

  /// Validates minimum length.
  static bool hasMinLength(String value, int minLength) => value.length >= minLength;

  /// Validates maximum length.
  static bool hasMaxLength(String value, int maxLength) => value.length <= maxLength;

  /// Validates phone number format.
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned);
  }

  /// Validates URL format.
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }
}

/// Form field validators for Flutter forms.
abstract final class FormValidators {
  static String? required(String? value) {
    if (!Validators.isNotEmpty(value)) {
      return 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (!Validators.isNotEmpty(value)) {
      return 'Email is required';
    }
    if (!Validators.isValidEmail(value!)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? password(String? value) {
    if (!Validators.isNotEmpty(value)) {
      return 'Password is required';
    }
    if (!Validators.isValidPassword(value!)) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? strongPassword(String? value) {
    if (!Validators.isNotEmpty(value)) {
      return 'Password is required';
    }
    if (!Validators.isStrongPassword(value!)) {
      return 'Password must be 8+ chars with upper, lower, and number';
    }
    return null;
  }

  static String? Function(String?) minLength(int min) => (value) {
      if (value != null && !Validators.hasMinLength(value, min)) {
        return 'Must be at least $min characters';
      }
      return null;
    };

  static String? Function(String?) maxLength(int max) => (value) {
      if (value != null && !Validators.hasMaxLength(value, max)) {
        return 'Must be at most $max characters';
      }
      return null;
    };

  static String? phone(String? value) {
    if (!Validators.isNotEmpty(value)) {
      return 'Phone is required';
    }
    if (!Validators.isValidPhone(value!)) {
      return 'Invalid phone format';
    }
    return null;
  }

  static String? url(String? value) {
    if (!Validators.isNotEmpty(value)) {
      return 'URL is required';
    }
    if (!Validators.isValidUrl(value!)) {
      return 'Invalid URL format';
    }
    return null;
  }

  /// Combines multiple validators.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) => (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
}
