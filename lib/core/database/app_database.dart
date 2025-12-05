import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Base table mixin with common columns for all entities.
mixin BaseTableMixin on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Example cached items table for offline-first pattern.
class CachedItems extends Table with BaseTableMixin {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE(key)'];
}

/// App database with Drift - type-safe SQLite abstraction.
@DriftDatabase(tables: [CachedItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Handle future migrations here
        },
        beforeOpen: (details) async {
          // Enable foreign keys
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Clear all cached items.
  Future<int> clearCache() => delete(cachedItems).go();

  /// Get cached item by key.
  Future<CachedItem?> getCachedItem(String key) =>
      (select(cachedItems)..where((t) => t.key.equals(key))).getSingleOrNull();

  /// Set cached item with optional expiration.
  Future<void> setCachedItem(String key, String value, {DateTime? expiresAt}) =>
      into(cachedItems).insertOnConflictUpdate(
        CachedItemsCompanion.insert(
          id: key,
          key: key,
          value: value,
          expiresAt: Value(expiresAt),
          isSynced: const Value(true),
        ),
      );

  /// Delete expired cache items.
  Future<int> deleteExpiredCache() => (delete(cachedItems)
        ..where((t) => t.expiresAt.isSmallerThanValue(DateTime.now())))
      .go();
}
