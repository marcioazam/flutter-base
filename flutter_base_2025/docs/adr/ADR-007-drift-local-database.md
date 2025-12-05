# ADR-007: Drift for Local Database

## Status

Accepted

## Date

2025-12-04

## Context

The Flutter Base 2025 project needed a local database solution for:
- Offline-first data caching
- Type-safe database operations
- Reactive data streams
- Migration support
- Cross-platform compatibility (iOS, Android, Web, Desktop)

### Options Considered

1. **Raw SQLite (sqflite)**
   - Pros: Direct control, lightweight
   - Cons: No type safety, manual SQL, no reactive streams

2. **Drift (formerly Moor)**
   - Pros: Type-safe, reactive streams, code generation, migrations
   - Cons: Learning curve, generated code size

3. **Isar**
   - Pros: Fast, NoSQL, easy to use
   - Cons: Less mature, limited query capabilities

4. **Hive**
   - Pros: Fast, simple key-value
   - Cons: Not relational, limited queries

5. **ObjectBox**
   - Pros: Fast, object-oriented
   - Cons: Commercial license for some features

## Decision

We chose **Drift** for the following reasons:

1. **Type Safety**: Compile-time verification of queries prevents runtime errors
2. **Reactive Streams**: Built-in `watch()` methods integrate perfectly with Riverpod
3. **Code Generation**: Reduces boilerplate while maintaining type safety
4. **Migration System**: Structured approach to schema changes
5. **SQL Power**: Full SQL capabilities when needed
6. **Active Maintenance**: Well-maintained with regular updates
7. **Flutter Integration**: First-class Flutter support

## Implementation

### Database Structure

```dart
@DriftDatabase(tables: [CachedItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);
  
  @override
  int get schemaVersion => 1;
}
```

### Generic Repository Pattern

```dart
abstract class DriftRepository<T extends DataClass, ID> {
  Future<Result<T>> getById(ID id);
  Stream<List<T>> watchAll();
  Future<Result<T>> insert(Insertable<T> entity);
  Future<Result<int>> update(Insertable<T> entity);
  Future<Result<int>> delete(ID id);
}
```

### Sync Repository for Offline-First

```dart
abstract class SyncRepository<T extends DataClass, ID> 
    extends BaseDriftRepository<T, ID> {
  Future<Result<SyncResult>> syncAll();
  Future<Result<T>> resolveConflict(T local, T remote);
}
```

## Consequences

### Positive

- Type-safe database operations catch errors at compile time
- Reactive streams enable automatic UI updates
- Generic repository pattern reduces boilerplate
- Conflict resolution strategies support offline-first
- Migrations ensure smooth schema updates

### Negative

- Generated code increases build time
- Learning curve for team members unfamiliar with Drift
- Additional dependency to maintain

### Neutral

- Requires build_runner for code generation
- SQL knowledge still beneficial for complex queries

## References

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Drift GitHub](https://github.com/simolus3/drift)
- [Flutter SQLite Options Comparison](https://flutter.dev/docs/cookbook/persistence/sqlite)
