import 'dart:math';

/// Abstract interface for cryptographically secure random generation.
///
/// Provides methods to generate cryptographically secure random values
/// suitable for security-sensitive operations like token generation,
/// session IDs, and nonces.
///
/// **Security Context:**
/// - OWASP A02: Cryptographic Failures Prevention
/// - OWASP A07: Authentication Failures Mitigation
/// - CWE-330: Use of Insufficiently Random Values
///
/// **Important:** Always use cryptographically secure RNG for:
/// - Authentication tokens
/// - Session identifiers
/// - CSRF tokens
/// - Password reset tokens
/// - API keys
/// - Nonces
abstract interface class SecureRandom {
  /// Generates a cryptographically secure random string.
  ///
  /// **Parameters:**
  /// - `length`: Number of characters in the generated string
  ///
  /// **Character Set:**
  /// - Lowercase letters (a-z)
  /// - Uppercase letters (A-Z)
  /// - Digits (0-9)
  ///
  /// **Example:**
  /// ```dart
  /// final random = ref.watch(secureRandomProvider);
  /// final randomString = random.generateString(16);
  /// // Returns: 'aB3xQ9mN2pK8rT4v' (example)
  /// ```
  ///
  /// Returns a random string of specified length.
  String generateString(int length);

  /// Generates a cryptographically secure token (32 characters).
  ///
  /// Convenience method for generating standard-length tokens
  /// suitable for session IDs, CSRF tokens, etc.
  ///
  /// **Example:**
  /// ```dart
  /// final random = ref.watch(secureRandomProvider);
  /// final token = random.generateToken();
  /// // Returns: 32-character random string
  /// ```
  ///
  /// Returns a 32-character random token.
  String generateToken();

  /// Generates secure random bytes.
  ///
  /// **Parameters:**
  /// - `length`: Number of bytes to generate
  ///
  /// **Example:**
  /// ```dart
  /// final random = ref.watch(secureRandomProvider);
  /// final bytes = random.generateBytes(16);
  /// // Returns: List of 16 random bytes [0-255]
  /// ```
  ///
  /// Returns a list of random bytes (0-255).
  List<int> generateBytes(int length);

  /// Generates a random integer in the range [0, max).
  ///
  /// **Parameters:**
  /// - `max`: Upper bound (exclusive)
  ///
  /// **Example:**
  /// ```dart
  /// final random = ref.watch(secureRandomProvider);
  /// final value = random.nextInt(100); // 0-99
  /// ```
  ///
  /// Returns a random integer in range [0, max).
  int nextInt(int max);
}

/// Default implementation of SecureRandom using dart:math Random.secure().
///
/// This implementation uses Dart's cryptographically secure random number
/// generator which provides sufficient entropy for security-sensitive operations.
///
/// **Thread Safety:** This class uses Random.secure() which is thread-safe.
class DefaultSecureRandom implements SecureRandom {
  /// Creates an instance of DefaultSecureRandom.
  ///
  /// Each instance maintains its own Random.secure() instance.
  DefaultSecureRandom() : _secureRandom = Random.secure();

  final Random _secureRandom;

  static const String _chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  @override
  String generateString(int length) => List.generate(
      length,
      (_) => _chars[_secureRandom.nextInt(_chars.length)],
    ).join();

  @override
  String generateToken() => generateString(32);

  @override
  List<int> generateBytes(int length) =>
      List.generate(length, (_) => _secureRandom.nextInt(256));

  @override
  int nextInt(int max) => _secureRandom.nextInt(max);
}
