/// Abstract interface for deep link validation services.
/// Provides security validation for deep links to prevent:
/// - Open redirect vulnerabilities
/// - Path traversal attacks
/// - Malicious scheme injection
///
/// **Security Context:**
/// - OWASP A01: Broken Access Control
/// - OWASP A05: Injection Prevention
/// - CWE-601: URL Redirection to Untrusted Site
abstract interface class DeepLinkValidator {
  /// List of allowed URL schemes (e.g., 'https', 'myapp').
  List<String> get allowedSchemes;

  /// List of allowed hosts for http/https schemes.
  List<String> get allowedHosts;

  /// Validates a deep link URL against security policies.
  ///
  /// **Validation Rules:**
  /// - Scheme must be in allowedSchemes
  /// - For http/https, host must be in allowedHosts
  /// - Path must not contain traversal patterns (../ or //)
  /// - URL must be parseable
  ///
  /// **Example:**
  /// ```dart
  /// final isValid = validator.isValidDeepLink('https://example.com/page');
  /// if (isValid) {
  ///   // Safe to process deep link
  /// }
  /// ```
  ///
  /// Returns true if URL passes all security checks.
  bool isValidDeepLink(String url);

  /// Extracts safe path from validated deep link.
  ///
  /// Returns null if URL fails validation.
  /// Otherwise returns the sanitized path component.
  ///
  /// **Example:**
  /// ```dart
  /// final path = validator.extractSafePath('https://example.com/products/123');
  /// // Returns: '/products/123'
  /// ```
  String? extractSafePath(String url);

  /// Extracts safe query parameters from validated deep link.
  ///
  /// Returns null if URL fails validation.
  /// Otherwise returns sanitized query parameters as a map.
  ///
  /// **Security:**
  /// - Keys are sanitized to alphanumeric only
  /// - Values are HTML-sanitized to prevent XSS
  ///
  /// **Example:**
  /// ```dart
  /// final params = validator.extractSafeParams('https://example.com/page?id=123&name=test');
  /// // Returns: {'id': '123', 'name': 'test'}
  /// ```
  Map<String, String>? extractSafeParams(String url);
}

/// Configuration for deep link validation.
///
/// Defines security policies for acceptable deep links.
class DeepLinkValidatorConfig {
  const DeepLinkValidatorConfig({
    this.allowedSchemes = const ['https', 'http', 'myapp'],
    this.allowedHosts = const ['example.com', 'api.example.com'],
  });

  /// Allowed URL schemes.
  /// Default: ['https', 'http', 'myapp']
  final List<String> allowedSchemes;

  /// Allowed hosts for http/https schemes.
  /// Default: ['example.com', 'api.example.com']
  final List<String> allowedHosts;
}

/// Default implementation of DeepLinkValidator.
///
/// This implementation provides secure deep link validation following
/// OWASP security guidelines to prevent open redirect and injection attacks.
///
/// **Thread Safety:** This class is immutable and thread-safe.
class DefaultDeepLinkValidator implements DeepLinkValidator {
  /// Creates a const instance of DefaultDeepLinkValidator with configuration.
  const DefaultDeepLinkValidator({
    required this.config,
    required this.inputSanitizer,
  });

  /// Validation configuration.
  final DeepLinkValidatorConfig config;

  /// Input sanitizer for query parameter sanitization.
  final dynamic inputSanitizer;

  @override
  List<String> get allowedSchemes => config.allowedSchemes;

  @override
  List<String> get allowedHosts => config.allowedHosts;

  @override
  bool isValidDeepLink(String url) {
    try {
      final uri = Uri.parse(url);

      // Validate scheme
      if (!allowedSchemes.contains(uri.scheme.toLowerCase())) {
        return false;
      }

      // Validate host for http/https
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        if (!allowedHosts.contains(uri.host.toLowerCase())) {
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

  @override
  String? extractSafePath(String url) {
    if (!isValidDeepLink(url)) return null;

    try {
      final uri = Uri.parse(url);
      return uri.path;
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, String>? extractSafeParams(String url) {
    if (!isValidDeepLink(url)) return null;

    try {
      final uri = Uri.parse(url);
      return uri.queryParameters.map(
        (key, value) => MapEntry(
          inputSanitizer.alphanumericOnly(key),
          inputSanitizer.sanitizeHtml(value),
        ),
      );
    } catch (e) {
      return null;
    }
  }
}
