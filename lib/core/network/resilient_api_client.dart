import 'package:dio/dio.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/network/circuit_breaker.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// API client with circuit breaker protection per endpoint.
/// 
/// **Feature: flutter-2025-final-enhancements**
/// **Validates: Requirements 5.1, 5.2, 5.3, 8.1, 8.2**
class ResilientApiClient {
  ResilientApiClient(
    this._dio, {
    CircuitBreakerConfig? circuitConfig,
  }) : _circuitConfig = circuitConfig ?? const CircuitBreakerConfig();

  final Dio _dio;
  final CircuitBreakerConfig _circuitConfig;
  final Map<String, CircuitBreaker<Response<dynamic>>> _circuits = {};

  /// Gets or creates circuit breaker for endpoint.
  CircuitBreaker<Response<dynamic>> _getCircuit(String endpoint, Future<Response<dynamic>> Function() request) => _circuits.putIfAbsent(
      endpoint,
      () => CircuitBreaker<Response<dynamic>>(
        config: _circuitConfig,
        execute: request,
      ),
    );

  /// GET with circuit breaker protection.
  Future<Result<T>> get<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    final circuit = _getCircuit(path, () => _dio.get<Map<String, dynamic>>(path, queryParameters: queryParameters));
    final result = await circuit();

    return result.flatMap((response) {
      try {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return Success(fromJson(data));
        }

        if (data is Map) {
          final json = <String, dynamic>{};
          for (final entry in data.entries) {
            final key = entry.key;
            if (key is! String) {
              throw FormatException('Response keys must be strings');
            }
            json[key] = entry.value;
          }
          return Success(fromJson(json));
        }

        throw FormatException('Response body is not a JSON object');
      } on FormatException catch (e, st) {
        return Failure(
          ValidationFailure(
            'Invalid response format: ${e.message}',
            stackTrace: st,
          ),
        );
      } on Exception catch (e, st) {
        return Failure(UnexpectedFailure(e.toString(), stackTrace: st));
      }
    });
  }


  /// GET with circuit breaker and cache fallback.
  /// 
  /// **Feature: flutter-2025-final-enhancements, Property 8: Cache Fallback on Error**
  /// **Validates: Requirements 8.1, 8.2**
  Future<Result<T>> getWithFallback<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    required Future<T?> Function() getCached,
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await get<T>(path, fromJson: fromJson, queryParameters: queryParameters);

    return result.fold(
      (failure) async {
        final cached = await getCached();
        if (cached != null) {
          return Success(cached);
        }
        return Failure(failure);
      },
      Success.new,
    );
  }

  /// POST with circuit breaker protection.
  Future<Result<T>> post<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final circuit = _getCircuit(
      'POST:$path',
      () => _dio.post<Map<String, dynamic>>(path, data: data, queryParameters: queryParameters),
    );
    final result = await circuit();

    return result.flatMap((response) {
      try {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          return Success(fromJson(responseData));
        }

        if (responseData is Map) {
          final json = <String, dynamic>{};
          for (final entry in responseData.entries) {
            final key = entry.key;
            if (key is! String) {
              throw FormatException('Response keys must be strings');
            }
            json[key] = entry.value;
          }
          return Success(fromJson(json));
        }

        throw FormatException('Response body is not a JSON object');
      } on FormatException catch (e, st) {
        return Failure(
          ValidationFailure(
            'Invalid response format: ${e.message}',
            stackTrace: st,
          ),
        );
      } on Exception catch (e, st) {
        return Failure(UnexpectedFailure(e.toString(), stackTrace: st));
      }
    });
  }

  /// Resets circuit breaker for a specific endpoint.
  void resetCircuit(String endpoint) {
    _circuits[endpoint]?.reset();
  }

  /// Resets all circuit breakers.
  void resetAllCircuits() {
    for (final circuit in _circuits.values) {
      circuit.reset();
    }
  }

  /// Gets the state of a circuit breaker for an endpoint.
  CircuitState? getCircuitState(String endpoint) => _circuits[endpoint]?.state;
}
