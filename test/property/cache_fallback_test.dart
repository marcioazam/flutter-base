import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glados_helpers.dart';

/// Simulates cache fallback behavior for testing.
Future<Result<T>> getWithFallback<T>({
  required Future<Result<T>> Function() fetchFromNetwork,
  required Future<T?> Function() getCached,
}) async {
  final result = await fetchFromNetwork();
  return result.fold(
    (failure) async {
      final cached = await getCached();
      if (cached != null) return Success(cached);
      return Failure(failure);
    },
    Success.new,
  );
}

void main() {
  group('Cache Fallback Property Tests', () {
    /// **Feature: flutter-2025-final-enhancements, Property 8: Cache Fallback on Error**
    /// **Validates: Requirements 8.1, 8.2**
    Glados(any.lowercaseLetters).test(
      'Returns cached data when network fails and cache exists',
      (cachedValue) async {
        final result = await getWithFallback<String>(
          fetchFromNetwork: () async => const Failure(NetworkFailure('Network error')),
          getCached: () async => cachedValue,
        );

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(cachedValue));
      },
    );

    Glados(any.lowercaseLetters).test(
      'Returns network data when network succeeds',
      (networkValue) async {
        final result = await getWithFallback<String>(
          fetchFromNetwork: () async => Success(networkValue),
          getCached: () async => 'cached_value',
        );

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(networkValue));
      },
    );

    test('Returns failure when network fails and no cache exists', () async {
      final result = await getWithFallback<String>(
        fetchFromNetwork: () async => const Failure(NetworkFailure('Network error')),
        getCached: () async => null,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });
}
