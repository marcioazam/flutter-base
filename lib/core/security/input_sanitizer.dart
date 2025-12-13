import 'dart:convert';

/// Abstract interface for input sanitization services.
/// Provides methods to sanitize various types of user input to prevent
/// security vulnerabilities like XSS, injection attacks, and path traversal.
///
/// **Security Context:**
/// - OWASP A05: Injection Prevention
/// - OWASP A04: Insecure Design Mitigation
/// - CWE-79: Cross-Site Scripting Prevention
abstract interface class InputSanitizer {
  /// Sanitizes string input to prevent XSS attacks.
  /// Encodes HTML special characters to their entity equivalents.
  ///
  /// Example:
  /// ```dart
  /// final sanitized = sanitizer.sanitizeHtml('<script>alert("XSS")</script>');
  /// // Returns: &lt;script&gt;alert(&quot;XSS&quot;)&lt;&#x2F;script&gt;
  /// ```
  String sanitizeHtml(String input);

  /// Sanitizes input for JSON contexts.
  /// Uses JSON encoding to escape special characters.
  String sanitizeJson(String input);

  /// Sanitizes URL parameter values.
  /// Applies URL encoding to prevent injection.
  String sanitizeUrlParam(String input);

  /// Removes control characters from input.
  /// Strips characters in range 0x00-0x1F and 0x7F.
  String removeControlChars(String input);

  /// Sanitizes filename to prevent path traversal attacks.
  /// Removes special filesystem characters and directory traversal patterns.
  ///
  /// **Security:**
  /// - Prevents path traversal (../ sequences)
  /// - Removes filesystem special characters
  /// - Strips leading/trailing dots
  String sanitizeFilename(String input);

  /// Validates and sanitizes email addresses.
  /// Returns null if email format is invalid.
  ///
  /// **Validation:**
  /// - Applies RFC 5322 simplified regex
  /// - Normalizes to lowercase
  /// - Trims whitespace
  String? sanitizeEmail(String input);

  /// Validates and sanitizes phone numbers.
  /// Returns null if phone format is invalid.
  ///
  /// **Validation:**
  /// - Strips all non-digit characters except +
  /// - Validates length (10-15 digits)
  String? sanitizePhone(String input);

  /// Strips all HTML tags from input.
  /// Useful for converting HTML to plain text.
  String stripHtmlTags(String input);

  /// Limits string length to prevent buffer overflow or DoS.
  /// Truncates input if it exceeds maxLength.
  String limitLength(String input, int maxLength);

  /// Validates input against whitelist pattern.
  /// Returns true if input matches the allowed pattern.
  ///
  /// **Security Best Practice:**
  /// Always use allowlist validation over blocklist.
  bool matchesWhitelist(String input, RegExp pattern);

  /// Extracts only alphanumeric characters.
  /// Removes all non-alphanumeric characters from input.
  String alphanumericOnly(String input);
}

/// Default implementation of InputSanitizer.
///
/// This implementation provides secure input sanitization following
/// OWASP security guidelines and WCAG accessibility standards.
///
/// **Thread Safety:** This class is immutable and thread-safe.
class DefaultInputSanitizer implements InputSanitizer {
  /// Creates a const instance of DefaultInputSanitizer.
  const DefaultInputSanitizer();

  @override
  String sanitizeHtml(String input) => input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;')
      .replaceAll('/', '&#x2F;');

  @override
  String sanitizeJson(String input) =>
      jsonEncode(input).replaceAll(RegExp(r'^"|"$'), '');

  @override
  String sanitizeUrlParam(String input) => Uri.encodeComponent(input);

  @override
  String removeControlChars(String input) =>
      input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

  @override
  String sanitizeFilename(String input) => input
      .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
      .replaceAll(RegExp(r'\.{2,}'), '.')
      .replaceAll(RegExp(r'^\.+|\.+$'), '');

  @override
  String? sanitizeEmail(String input) {
    final trimmed = input.trim().toLowerCase();
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(trimmed)) return null;
    return trimmed;
  }

  @override
  String? sanitizePhone(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) return null;
    return cleaned;
  }

  @override
  String stripHtmlTags(String input) => input.replaceAll(RegExp('<[^>]*>'), '');

  @override
  String limitLength(String input, int maxLength) {
    if (input.length <= maxLength) return input;
    return input.substring(0, maxLength);
  }

  @override
  bool matchesWhitelist(String input, RegExp pattern) =>
      pattern.hasMatch(input);

  @override
  String alphanumericOnly(String input) =>
      input.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
}
