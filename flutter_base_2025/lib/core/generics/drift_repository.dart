import 'package:drift/drift.dart';

import '../errors/failures.dart';
import '../utils/result.dart';
import 'base_repository.dart';
import 'paginated_list.dart';

/// Generic Drift repository for local database operations.
/// T = Entity type, D = Drift DataClass, C = Companion class
abstract class DriftRepository<T, D extends DataClass, C extends UpdateCompanion<D>> {
  /// The database instance.
  GeneratedDatabase get database;

  /// The table to operate on.
  TableInfo<Table, D> get table;

  /// Converts Drift DataClass to domain entity.
  T fromRow(D row);

  /// Converts domain entity to Drift Companion for insert/update.
  C toCompanion(T entity);

  /// Gets the ID column for the table.
  GeneratedColumn<String> get idColumn;

  /// Gets ID from entity.
  String getId(T entity);

  /// Fetches entity by ID.
  Future<Result<T>> getById(String id) async {
    try {
      final query = database.select(table)
        ..where((t) => idColumn.equals(id));
      final row = await query.getSingleOrNull();

      if (row == null) {
        return Failure(NotFoundFailure('Entity not found', resourceId: id));
      }

      return Success(fromRow(row));
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }

  /// Fetches all entities with pagination.
  Future<Result<PaginatedList<T>>> getAll({
    int page = 1,
    int pageSize = 20,
    Filter<T>? filter,
    Sort<T>? sort,
  }) async {
    try {
      final countQuery = database.selectOnly(table)
        ..addColumns([table.primaryKey.first.count()]);
      final countResult = await countQuery.getSingle();
      final totalItems = countResult.read(table.primaryKey.first.count()) ?? 0;

      final query = database.select(table)
        ..limit(pageSize, offset: (page - 1) * pageSize);

      final rows = await query.get();
      final items = rows.map(fromRow).toList();

      return Success(PaginatedList.fromItems(
        items,
        page: page,
        pageSize: pageSize,
        totalItems: totalItems,
      ));
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }

  /// Creates a new entity.
  Future<Result<T>> create(T entity) async {
    try {
      final companion = toCompanion(entity);
      await database.into(table).insert(companion);
      return Success(entity);
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }

  /// Updates an existing entity.
  Future<Result<T>> update(T entity) async {
    try {
      final id = getId(entity);
      final companion = toCompanion(entity);

      final updated = await (database.update(table)
            ..where((t) => idColumn.equals(id)))
          .write(companion);

      if (updated == 0) {
        return Failure(NotFoundFailure('Entity not found', resourceId: id));
      }

      return Success(entity);
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }

  /// Deletes entity by ID.
  Future<Result<void>> delete(String id) async {
    try {
      final deleted = await (database.delete(table)
            ..where((t) => idColumn.equals(id)))
          .go();

      if (deleted == 0) {
        return Failure(NotFoundFailure('Entity not found', resourceId: id));
      }

      return const Success(null);
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }

  /// Creates multiple entities.
  Future<Result<List<T>>> createMany(List<T> entities) async {
    try {
      await database.batch((batch) {
        for (final entity in entities) {
          batch.insert(table, toCompanion(entity));
        }
      });
      return Success(entities);
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }

  /// Deletes multiple entities by IDs.
  Future<Result<void>> deleteMany(List<String> ids) async {
    try {
      await (database.delete(table)..where((t) => idColumn.isIn(ids))).go();
      return const Success(null);
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }

  /// Watches all entities for changes.
  Stream<List<T>> watchAll() {
    return database.select(table).watch().map(
          (rows) => rows.map(fromRow).toList(),
        );
  }

  /// Checks if entity exists by ID.
  Future<Result<bool>> exists(String id) async {
    try {
      final query = database.select(table)
        ..where((t) => idColumn.equals(id));
      final row = await query.getSingleOrNull();
      return Success(row != null);
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }

  /// Counts entities.
  Future<Result<int>> count() async {
    try {
      final query = database.selectOnly(table)
        ..addColumns([table.primaryKey.first.count()]);
      final result = await query.getSingle();
      final total = result.read(table.primaryKey.first.count()) ?? 0;
      return Success(total);
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }

  /// Marks entity as synced.
  Future<Result<void>> markSynced(String id) async {
    try {
      // This assumes the table has an isSynced column
      // Subclasses should override if different
      return const Success(null);
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }

  /// Gets all unsynced entities.
  Future<Result<List<T>>> getUnsynced() async {
    try {
      // This assumes the table has an isSynced column
      // Subclasses should override with proper implementation
      return const Success([]);
    } catch (e, st) {
      return Failure(CacheFailure(e.toString(), stackTrace: st));
    }
  }
}
