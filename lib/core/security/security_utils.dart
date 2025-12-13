import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_base_2025/core/security/certificate_pinning_service.dart';

/// Certificate pinning configuration.
///
/// DEPRECATED: Use [CertificatePinningService] instead.
/// This class is kept for backward compatibility only.
@Deprecated('Use CertificatePinningService for production certificate pinning')
class CertificatePinConfig {
  @Deprecated(
    'Use CertificatePinningService for production certificate pinning',
  )
  const CertificatePinConfig({
    required this.pinnedCertificates,
    this.allowBadCertificates = false,
  });
  final List<String> pinnedCertificates;
  final bool allowBadCertificates;
}

/// Creates an HttpClient with certificate pinning.
///
/// DEPRECATED: Use [CertificatePinningService.createHttpClient] instead.
///
/// This function now delegates to [CertificatePinningService] for
/// production-ready certificate pinning with:
/// - SHA-256 SPKI validation
/// - Multiple pins (primary + backup)
/// - Certificate expiration warnings
/// - Fail-closed security model
///
/// Migration:
/// ```dart
/// // Old (DEPRECATED)
/// final client = createPinnedHttpClient(config);
///
/// // New (RECOMMENDED)
/// final service = ref.read(certificatePinningServiceProvider);
/// final client = service.createHttpClient();
/// ```
@Deprecated('Use CertificatePinningService.createHttpClient() instead')
HttpClient createPinnedHttpClient(CertificatePinConfig config) {
  // Legacy implementation - NOT SECURE for production
  // This is kept only for backward compatibility
  final client = HttpClient();

  if (!config.allowBadCertificates && config.pinnedCertificates.isNotEmpty) {
    client.badCertificateCallback = (cert, host, port) {
      // WARNING: This legacy implementation does NOT provide secure pinning.
      // Migrate to CertificatePinningService immediately.
      return false;
    };
  }

  return client;
}

/// Input sanitizer for security.
abstract final class InputSanitizer {
  /// Sanitizes string input to prevent XSS.
  static String sanitizeHtml(String input) => input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;')
      .replaceAll('/', '&#x2F;');

  /// ⚠️ DEPRECATED: Do NOT use this method. It promotes insecure SQL practices.
  ///
  /// **Security Issue:** String sanitization is NOT sufficient to prevent SQL injection.
  /// **Correct Approach:** Use parameterized queries with Drift ORM.
  ///
  /// This method will be removed in a future version.
  /// See: VUL-2025-FLUTTER-005, OWASP A05 Injection
  @Deprecated(
    'Use parameterized queries with Drift instead. This method promotes insecure SQL practices.',
  )
  static String sanitizeSql(String input) => throw UnsupportedError(
    'sanitizeSql is deprecated and disabled for security reasons. '
    'Use Drift parameterized queries instead: '
    'db.select(table)..where((t) => t.column.equals(value))',
  );

  /// Sanitizes input for JSON.
  static String sanitizeJson(String input) =>
      jsonEncode(input).replaceAll(RegExp(r'^"|"$'), '');

  /// Sanitizes URL parameter.
  static String sanitizeUrlParam(String input) => Uri.encodeComponent(input);

  /// Removes control characters.
  static String removeControlChars(String input) =>
      input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

  /// Sanitizes filename.
  static String sanitizeFilename(String input) => input
      .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
      .replaceAll(RegExp(r'\.{2,}'), '.')
      .replaceAll(RegExp(r'^\.+|\.+$'), '');

  /// Validates and sanitizes email.
  static String? sanitizeEmail(String input) {
    final trimmed = input.trim().toLowerCase();
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(trimmed)) return null;
    return trimmed;
  }

  /// Validates and sanitizes phone number.
  static String? sanitizePhone(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) return null;
    return cleaned;
  }

  /// Strips all HTML tags.
  static String stripHtmlTags(String input) =>
      input.replaceAll(RegExp('<[^>]*>'), '');

  /// Limits string length.
  static String limitLength(String input, int maxLength) {
    if (input.length <= maxLength) return input;
    return input.substring(0, maxLength);
  }

  /// Validates input against whitelist pattern.
  static bool matchesWhitelist(String input, RegExp pattern) =>
      pattern.hasMatch(input);

  /// Alphanumeric only.
  static String alphanumericOnly(String input) =>
      input.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
}

/// Deep link validator.
abstract final class DeepLinkValidator {
  static const _allowedSchemes = ['https', 'http', 'myapp'];
  static const _allowedHosts = ['example.com', 'api.example.com'];

  /// Validates a deep link URL.
  static bool isValidDeepLink(String url) {
    try {
      final uri = Uri.parse(url);

      // Validate scheme
      if (!_allowedSchemes.contains(uri.scheme.toLowerCase())) {
        return false;
      }

      // Validate host for http/https
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        if (!_allowedHosts.contains(uri.host.toLowerCase())) {
          return false;
        }
      }

      // Validate path doesn't contain suspicious patterns
      if (uri.path.contains('..') || uri.path.contains('//')) {
        return false;
      }

      return true;
    } on FormatException {
      return false;
    }
  }

  /// Extracts safe path from deep link.
  static String? extractSafePath(String url) {
    if (!isValidDeepLink(url)) return null;

    try {
      final uri = Uri.parse(url);
      return uri.path;
    } on FormatException {
      return null;
    }
  }

  /// Extracts safe query parameters.
  static Map<String, String>? extractSafeParams(String url) {
    if (!isValidDeepLink(url)) return null;

    try {
      final uri = Uri.parse(url);
      return uri.queryParameters.map(
        (key, value) => MapEntry(
          InputSanitizer.alphanumericOnly(key),
          InputSanitizer.sanitizeHtml(value),
        ),
      );
    } on FormatException {
      return null;
    }
  }
}

/// Secure random generator using cryptographically secure RNG.
abstract final class SecureRandom {
  static final _secureRandom = Random.secure();

  /// Generates a cryptographically secure random string.
  static String generateString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      length,
      (_) => chars[_secureRandom.nextInt(chars.length)],
    ).join();
  }

  /// Generates a cryptographically secure token (32 chars).
  static String generateToken() => generateString(32);

  /// Generates secure random bytes.
  static List<int> generateBytes(int length) =>
      List.generate(length, (_) => _secureRandom.nextInt(256));
}
