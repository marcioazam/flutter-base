import 'package:drift/drift.dart';
import 'package:flutter_base_2025/core/database/drift_repository.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/network/api_client.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// Repository with offline sync support and conflict resolution.
abstract class SyncRepository<T extends DataClass, ID>
    extends BaseDriftRepository<T, ID> {

  SyncRepository({
    required this.apiClient,
    this.conflictResolution = ConflictResolution.serverWins,
  });
  final ApiClient apiClient;
  final ConflictResolution conflictResolution;

  /// Get pending sync items.
  Future<List<T>> getPendingSyncItems();

  /// Mark item as synced.
  Future<void> markAsSynced(ID id);

  /// Mark item as sync failed.
  Future<void> markAsSyncFailed(ID id, String error);

  /// Push local item to server.
  Future<Result<T>> pushToServer(T item);

  /// Pull item from server.
  Future<Result<T>> pullFromServer(ID id);

  /// Sync all pending items.
  Future<Result<SyncResult>> syncAll() async {
    final pending = await getPendingSyncItems();
    var synced = 0;
    var failed = 0;
    final errors = <String>[];

    for (final item in pending) {
      final result = await pushToServer(item);
      result.fold(
        (failure) {
          failed++;
          errors.add(failure.message);
        },
        (_) => synced++,
      );
    }

    return Success(SyncResult(
      totalItems: pending.length,
      syncedItems: synced,
      failedItems: failed,
      errors: errors,
    ));
  }

  /// Resolve conflict between local and remote versions.
  Future<Result<T>> resolveConflict(T local, T remote) async => switch (conflictResolution) {
      ConflictResolution.serverWins => Success(remote),
      ConflictResolution.clientWins => Success(local),
      ConflictResolution.merge => mergeEntities(local, remote),
      ConflictResolution.keepBoth => Success(local),
    };

  /// Merge two entity versions. Override for custom merge logic.
  Future<Result<T>> mergeEntities(T local, T remote) async => Failure(const UnexpectedFailure(
      'Merge not implemented. Override mergeEntities() for custom merge logic.',
    ));
}

/// Result of a sync operation.
class SyncResult {

  const SyncResult({
    required this.totalItems,
    required this.syncedItems,
    required this.failedItems,
    this.errors = const [],
  });
  final int totalItems;
  final int syncedItems;
  final int failedItems;
  final List<String> errors;

  bool get isFullySuccessful => failedItems == 0;
  bool get hasErrors => errors.isNotEmpty;
}
