import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../network/api_client.dart';
import '../utils/result.dart';
import 'paginated_list.dart';

/// Generic repository for API consumption.
/// T = Entity type, D = DTO type, ID = Identifier type
abstract class ApiRepository<T, D, ID> {
  final ApiClient _apiClient;
  final String _basePath;

  ApiRepository(this._apiClient, this._basePath);

  /// Converts DTO to Entity.
  T fromDto(D dto);

  /// Converts Entity to DTO for sending to API.
  D toDto(T entity);

  /// Creates DTO from JSON.
  D dtoFromJson(Map<String, dynamic> json);

  /// Gets ID from entity.
  ID getId(T entity);

  /// Fetches entity by ID.
  Future<Result<T>> getById(ID id) async {
    try {
      final dto = await _apiClient.get<D>(
        '$_basePath/$id',
        fromJson: (json) => dtoFromJson(json),
      );
      return Success(fromDto(dto));
    } on AppException catch (e) {
      return Failure(_mapExceptionToFailure(e));
    }
  }

  /// Fetches all entities with pagination.
  Future<Result<PaginatedList<T>>> getAll({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _apiClient.getPaginated<D>(
        _basePath,
        page: page,
        pageSize: pageSize,
        queryParameters: queryParams,
        fromJson: (json) => dtoFromJson(json),
      );

      return Success(
        PaginatedList.fromItems(
          response.items.map(fromDto).toList(),
          page: response.page,
          pageSize: response.pageSize,
          totalItems: response.totalItems,
        ),
      );
    } on AppException catch (e) {
      return Failure(_mapExceptionToFailure(e));
    }
  }

  /// Creates a new entity.
  Future<Result<T>> create(T entity) async {
    try {
      final dto = await _apiClient.post<D>(
        _basePath,
        data: toDto(entity),
        fromJson: (json) => dtoFromJson(json),
      );
      return Success(fromDto(dto));
    } on AppException catch (e) {
      return Failure(_mapExceptionToFailure(e));
    }
  }

  /// Updates an existing entity.
  Future<Result<T>> update(T entity) async {
    try {
      final id = getId(entity);
      final dto = await _apiClient.put<D>(
        '$_basePath/$id',
        data: toDto(entity),
        fromJson: (json) => dtoFromJson(json),
      );
      return Success(fromDto(dto));
    } on AppException catch (e) {
      return Failure(_mapExceptionToFailure(e));
    }
  }

  /// Deletes entity by ID.
  Future<Result<void>> delete(ID id) async {
    try {
      await _apiClient.delete('$_basePath/$id');
      return const Success(null);
    } on AppException catch (e) {
      return Failure(_mapExceptionToFailure(e));
    }
  }

  /// Maps exceptions to failures.
  AppFailure _mapExceptionToFailure(AppException e) {
    return switch (e) {
      NetworkException() => NetworkFailure(e.message),
      ServerException() => ServerFailure(e.message, statusCode: e.statusCode),
      ValidationException(:final fieldErrors) =>
        ValidationFailure(e.message, fieldErrors: fieldErrors ?? {}),
      UnauthorizedException() => AuthFailure(e.message),
      ForbiddenException() => ForbiddenFailure(e.message),
      NotFoundException() => NotFoundFailure(e.message),
      RateLimitException() => RateLimitFailure(e.message),
      CacheException() => CacheFailure(e.message),
    };
  }
}
