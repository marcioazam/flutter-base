import 'package:flutter_base_2025/core/cache/cache_datasource.dart';
import 'package:flutter_base_2025/core/base/base_repository.dart';
import 'package:flutter_base_2025/core/base/paginated_list.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// Composite repository that orchestrates cache, local, and remote sources.
/// Strategy: Cache -> Local -> Remote with automatic cache population.
///
/// **Feature: flutter-2025-state-of-art-review**
/// **Validates: Requirements 1.5**
class CompositeRepository<T, ID> implements BaseRepository<T, ID> {
  CompositeRepository({
    required this.remote,
    this.local,
    this.cache,
    this.cacheTtl = const Duration(minutes: 5),
    String Function(ID)? cacheKeyBuilder,
  }) : cacheKeyBuilder = cacheKeyBuilder ?? ((id) => id.toString());
  final BaseRepository<T, ID> remote;
  final BaseRepository<T, ID>? local;
  final CacheDataSource<T>? cache;
  final Duration cacheTtl;
  final String Function(ID) cacheKeyBuilder;

  @override
  Future<Result<T>> getById(ID id) async {
    final cacheKey = cacheKeyBuilder(id);

    // 1. Try cache first
    if (cache != null) {
      final cached = await cache!.get(cacheKey);
      if (cached != null) {
        return Success(cached);
      }
    }

    // 2. Try local storage
    if (local != null) {
      final localResult = await local!.getById(id);
      if (localResult.isSuccess) {
        // Populate cache
        if (cache != null && localResult.valueOrNull != null) {
          await cache!.set(
            cacheKey,
            localResult.valueOrNull as T,
            ttl: cacheTtl,
          );
        }
        return localResult;
      }
    }

    // 3. Fetch from remote
    final remoteResult = await remote.getById(id);

    if (remoteResult.isSuccess && remoteResult.valueOrNull != null) {
      final value = remoteResult.valueOrNull as T;

      // Populate cache
      if (cache != null) {
        await cache!.set(cacheKey, value, ttl: cacheTtl);
      }

      // Persist to local
      if (local != null) {
        await local!.create(value);
      }
    }

    return remoteResult;
  }

  @override
  Future<Result<PaginatedList<T>>> getAll({
    int page = 1,
    int pageSize = 20,
    Filter<T>? filter,
    Sort<T>? sort,
  }) async {
    // For paginated data, prefer remote for freshness
    final remoteResult = await remote.getAll(
      page: page,
      pageSize: pageSize,
      filter: filter,
      sort: sort,
    );

    if (remoteResult.isSuccess) {
      // Optionally sync to local
      if (local != null && remoteResult.valueOrNull != null) {
        for (final item in remoteResult.valueOrNull!.items) {
          await local!.create(item);
        }
      }
      return remoteResult;
    }

    // Fallback to local if remote fails
    if (local != null) {
      return local!.getAll(
        page: page,
        pageSize: pageSize,
        filter: filter,
        sort: sort,
      );
    }

    return remoteResult;
  }

  @override
  Future<Result<T>> create(T entity) async {
    // Create on remote first
    final remoteResult = await remote.create(entity);

    if (remoteResult.isSuccess && remoteResult.valueOrNull != null) {
      final created = remoteResult.valueOrNull as T;

      // Sync to local
      if (local != null) {
        await local!.create(created);
      }
    }

    return remoteResult;
  }

  @override
  Future<Result<T>> update(T entity) async {
    // Update on remote first
    final remoteResult = await remote.update(entity);

    if (remoteResult.isSuccess && remoteResult.valueOrNull != null) {
      final updated = remoteResult.valueOrNull as T;

      // Sync to local
      if (local != null) {
        await local!.update(updated);
      }

      // Invalidate cache (will be repopulated on next read)
      // Note: We'd need ID extraction here for proper cache invalidation
    }

    return remoteResult;
  }

  @override
  Future<Result<void>> delete(ID id) async {
    final cacheKey = cacheKeyBuilder(id);

    // Delete from remote first
    final remoteResult = await remote.delete(id);

    if (remoteResult.isSuccess) {
      // Delete from local
      if (local != null) {
        await local!.delete(id);
      }

      // Invalidate cache
      if (cache != null) {
        await cache!.invalidate(cacheKey);
      }
    }

    return remoteResult;
  }

  @override
  Future<Result<List<T>>> createMany(List<T> entities) async {
    final remoteResult = await remote.createMany(entities);

    if (remoteResult.isSuccess && local != null) {
      await local!.createMany(entities);
    }

    return remoteResult;
  }

  @override
  Future<Result<void>> deleteMany(List<ID> ids) async {
    final remoteResult = await remote.deleteMany(ids);

    if (remoteResult.isSuccess) {
      if (local != null) {
        await local!.deleteMany(ids);
      }

      if (cache != null) {
        for (final id in ids) {
          await cache!.invalidate(cacheKeyBuilder(id));
        }
      }
    }

    return remoteResult;
  }

  @override
  Stream<List<T>> watchAll() {
    // Prefer local for reactive updates
    if (local != null) {
      return local!.watchAll();
    }
    return remote.watchAll();
  }

  @override
  Future<Result<bool>> exists(ID id) async {
    final cacheKey = cacheKeyBuilder(id);

    // Check cache first
    if (cache != null && await cache!.has(cacheKey)) {
      return const Success(true);
    }

    // Check local
    if (local != null) {
      final localResult = await local!.exists(id);
      if (localResult.isSuccess && (localResult.valueOrNull ?? false)) {
        return localResult;
      }
    }

    // Check remote
    return remote.exists(id);
  }

  @override
  Future<Result<int>> count({Filter<T>? filter}) async {
    // Prefer remote for accurate count
    final remoteResult = await remote.count(filter: filter);

    if (remoteResult.isFailure && local != null) {
      return local!.count(filter: filter);
    }

    return remoteResult;
  }

  @override
  Future<Result<T?>> findFirst(Filter<T> filter) async {
    // Try local first for speed
    if (local != null) {
      final localResult = await local!.findFirst(filter);
      if (localResult.isSuccess && localResult.valueOrNull != null) {
        return localResult;
      }
    }

    // Fallback to remote
    return remote.findFirst(filter);
  }

  /// Invalidates all caches.
  Future<void> invalidateAllCaches() async {
    if (cache != null) {
      await cache!.invalidateAll();
    }
  }

  /// Forces a refresh from remote, updating local and cache.
  Future<Result<T>> forceRefresh(ID id) async {
    final cacheKey = cacheKeyBuilder(id);

    // Invalidate cache
    if (cache != null) {
      await cache!.invalidate(cacheKey);
    }

    // Fetch fresh from remote
    final remoteResult = await remote.getById(id);

    if (remoteResult.isSuccess && remoteResult.valueOrNull != null) {
      final value = remoteResult.valueOrNull as T;

      // Update cache
      if (cache != null) {
        await cache!.set(cacheKey, value, ttl: cacheTtl);
      }

      // Update local
      if (local != null) {
        await local!.update(value);
      }
    }

    return remoteResult;
  }
}
