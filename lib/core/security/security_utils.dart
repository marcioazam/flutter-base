import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Certificate pinning configuration.
class CertificatePinConfig {

  const CertificatePinConfig({
    required this.pinnedCertificates,
    this.allowBadCertificates = false,
  });
  final List<String> pinnedCertificates;
  final bool allowBadCertificates;
}

/// Creates an HttpClient with certificate pinning.
/// Note: For production use, implement proper certificate validation.
HttpClient createPinnedHttpClient(CertificatePinConfig config) {
  final client = HttpClient();

  if (!config.allowBadCertificates && config.pinnedCertificates.isNotEmpty) {
    client.badCertificateCallback = (cert, host, port) {
      // In production, validate against pinned certificates
      // final certPem = cert.pem;
      // return config.pinnedCertificates.contains(certPem);
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

  /// Sanitizes input for SQL (use parameterized queries instead).
  static String sanitizeSql(String input) => input
        .replaceAll("'", "''")
        .replaceAll(r'\', r'\\')
        .replaceAll('\x00', '')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\x1a', r'\Z');

  /// Sanitizes input for JSON.
  static String sanitizeJson(String input) => jsonEncode(input).replaceAll(RegExp(r'^"|"$'), '');

  /// Sanitizes URL parameter.
  static String sanitizeUrlParam(String input) => Uri.encodeComponent(input);

  /// Removes control characters.
  static String removeControlChars(String input) => input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

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
  static String stripHtmlTags(String input) => input.replaceAll(RegExp('<[^>]*>'), '');

  /// Limits string length.
  static String limitLength(String input, int maxLength) {
    if (input.length <= maxLength) return input;
    return input.substring(0, maxLength);
  }

  /// Validates input against whitelist pattern.
  static bool matchesWhitelist(String input, RegExp pattern) => pattern.hasMatch(input);

  /// Alphanumeric only.
  static String alphanumericOnly(String input) => input.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
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
    } catch (e) {
      return false;
    }
  }

  /// Extracts safe path from deep link.
  static String? extractSafePath(String url) {
    if (!isValidDeepLink(url)) return null;

    try {
      final uri = Uri.parse(url);
      return uri.path;
    } catch (e) {
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
    } catch (e) {
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
