import 'package:drift/drift.dart';

import '../errors/failures.dart';
import '../utils/result.dart';

/// Generic repository interface for Drift database operations.
/// T = Entity type (DataClass), ID = Identifier type
abstract class DriftRepository<T extends DataClass, ID> {
  /// Get entity by ID.
  Future<Result<T>> getById(ID id);

  /// Get all entities.
  Future<Result<List<T>>> getAll();

  /// Watch all entities as a stream.
  Stream<List<T>> watchAll();

  /// Insert entity.
  Future<Result<T>> insert(Insertable<T> entity);

  /// Update entity.
  Future<Result<int>> update(Insertable<T> entity);

  /// Delete entity by ID.
  Future<Result<int>> delete(ID id);

  /// Delete all entities.
  Future<Result<int>> deleteAll();
}

/// Base implementation of DriftRepository with common error handling.
abstract class BaseDriftRepository<T extends DataClass, ID>
    implements DriftRepository<T, ID> {
  /// Execute database operation with error handling.
  Future<Result<R>> executeWithErrorHandling<R>(
    Future<R> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Success(result);
    } on Exception catch (e, stack) {
      return Failure(_mapDriftError(e, stack));
    }
  }

  /// Map Drift/SQLite errors to AppFailure.
  AppFailure _mapDriftError(Exception e, StackTrace stack) {
    final message = e.toString();

    if (message.contains('UNIQUE constraint failed')) {
      return ConflictFailure(
        'Entity already exists',
        code: 'UNIQUE_CONSTRAINT',
        stackTrace: stack,
      );
    }

    if (message.contains('FOREIGN KEY constraint failed')) {
      return ValidationFailure(
        'Referenced entity not found',
        code: 'FOREIGN_KEY_CONSTRAINT',
        stackTrace: stack,
      );
    }

    if (message.contains('NOT NULL constraint failed')) {
      return ValidationFailure(
        'Required field is missing',
        code: 'NOT_NULL_CONSTRAINT',
        stackTrace: stack,
      );
    }

    return CacheFailure(
      'Database error: $message',
      stackTrace: stack,
    );
  }
}

/// Conflict resolution strategies for sync operations.
enum ConflictResolution {
  /// Server data wins in case of conflict.
  serverWins,

  /// Client data wins in case of conflict.
  clientWins,

  /// Merge both versions (requires custom implementation).
  merge,

  /// Keep both versions with different IDs.
  keepBoth,
}

/// Sync status for offline-first entities.
enum SyncStatus {
  /// Entity is synced with server.
  synced,

  /// Entity has local changes pending sync.
  pendingSync,

  /// Entity sync failed.
  syncFailed,

  /// Entity is being synced.
  syncing,
}
