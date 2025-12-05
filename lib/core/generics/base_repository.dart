import '../errors/failures.dart';
import '../utils/result.dart';
import 'paginated_list.dart';

/// Filter specification for repository queries.
class Filter<T> {
  final Map<String, dynamic> conditions;
  const Filter(this.conditions);
}

/// Sort specification for repository queries.
class Sort<T> {
  final String field;
  final bool ascending;
  const Sort(this.field, {this.ascending = true});
}

/// Generic repository interface with CRUD operations.
/// T = Entity type, ID = Identifier type (String, int, etc.)
abstract interface class BaseRepository<T, ID> {
  /// Fetches entity by ID.
  Future<Result<T>> getById(ID id);

  /// Fetches all entities with pagination.
  Future<Result<PaginatedList<T>>> getAll({
    int page = 1,
    int pageSize = 20,
    Filter<T>? filter,
    Sort<T>? sort,
  });

  /// Creates a new entity.
  Future<Result<T>> create(T entity);

  /// Updates an existing entity.
  Future<Result<T>> update(T entity);

  /// Deletes entity by ID.
  Future<Result<void>> delete(ID id);

  /// Creates multiple entities.
  Future<Result<List<T>>> createMany(List<T> entities);

  /// Deletes multiple entities by IDs.
  Future<Result<void>> deleteMany(List<ID> ids);

  /// Watches all entities for changes.
  Stream<List<T>> watchAll();

  /// Checks if entity exists by ID.
  Future<Result<bool>> exists(ID id);

  /// Counts entities matching filter.
  Future<Result<int>> count({Filter<T>? filter});

  /// Finds first entity matching filter.
  Future<Result<T?>> findFirst(Filter<T> filter);
}
