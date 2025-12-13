import 'package:flutter_base_2025/core/base/paginated_response.dart';

/// Generic interface for remote data sources.
/// Frontend only - all data persistence is handled by Python API.
abstract interface class BaseRemoteDataSource<T, ID> {
  /// Fetches entity by ID from remote.
  Future<T> get(ID id);

  /// Fetches all entities with pagination from remote.
  Future<PaginatedResponse<T>> getAll({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? queryParams,
  });

  /// Creates entity on remote.
  Future<T> create(T data);

  /// Updates entity on remote.
  Future<T> update(ID id, T data);

  /// Deletes entity on remote.
  Future<void> delete(ID id);
}
