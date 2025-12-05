import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/exceptions.dart';
import '../generics/paginated_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Provider for Dio instance configured for Python API.
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(ref),
    RetryInterceptor(dio: dio),
    if (config.enableLogging) LoggingInterceptor(),
  ]);

  return dio;
});

/// Provider for generic API client.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

/// Generic API client for consuming Python backend.
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// GET request returning single item.
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET request returning list of items.
  Future<List<T>> getList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data!
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET request returning paginated response.
  Future<PaginatedResponse<T>> getPaginated<T>(
    String path, {
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final params = {
        'page': page,
        'page_size': pageSize,
        ...?queryParameters,
      };
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: params,
      );
      return PaginatedResponse.fromJson(
        response.data!,
        (json) => fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request.
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request.
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH request.
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request.
  Future<void> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _dio.delete<void>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handles Dio errors and converts to app exceptions.
  AppException _handleDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        NetworkException('Connection timeout', statusCode: 408),
      DioExceptionType.connectionError =>
        NetworkException('No internet connection'),
      DioExceptionType.badResponse => _handleBadResponse(e.response),
      DioExceptionType.cancel => NetworkException('Request cancelled'),
      _ => NetworkException(e.message ?? 'Unknown network error'),
    };
  }

  AppException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 500;
    final data = response?.data;
    
    String message = 'Server error';
    Map<String, List<String>>? fieldErrors;
    
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? 
                data['detail'] as String? ?? 
                'Server error';
      
      if (data['errors'] is Map) {
        fieldErrors = (data['errors'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            (value as List).map((e) => e.toString()).toList(),
          ),
        );
      }
    }

    return switch (statusCode) {
      400 => ValidationException(message, fieldErrors: fieldErrors),
      401 => UnauthorizedException(message),
      403 => ForbiddenException(message),
      404 => NotFoundException(message),
      422 => ValidationException(message, fieldErrors: fieldErrors),
      429 => RateLimitException(message),
      >= 500 => ServerException(message, statusCode: statusCode),
      _ => NetworkException(message, statusCode: statusCode),
    };
  }
}
