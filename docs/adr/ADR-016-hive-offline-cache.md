# ADR-016: Hive Offline Cache Layer

## Status
Accepted

## Context
The project required offline caching capabilities as documented, but no implementation existed. We needed to add a cache layer that:
- Persists data locally for offline access
- Supports TTL-based expiration
- Integrates with existing CompositeRepository pattern
- Provides encryption for sensitive data

## Decision
We will implement offline caching using Hive with the following components:

1. **HiveInitializer**: Centralized initialization
   - Flutter-specific initialization via `hive_flutter`
   - Encryption key management via `flutter_secure_storage`
   - Support for both encrypted and unencrypted boxes

2. **HiveCacheDataSource<T>**: Generic cache data source
   - JSON-based serialization (due to hive_generator version conflict)
   - TTL support with automatic expiration
   - Stale data retrieval for offline fallback
   - Reactive updates via Hive watch streams

3. **HiveCacheEntry<T>**: Cache entry wrapper
   - Stores data with metadata (cachedAt, expiresAt)
   - Provides expiration checking
   - JSON serialization for storage

4. **HiveCacheConfig**: Configuration
   - Environment-based TTL defaults
   - Encryption toggle for sensitive boxes
   - Max entries limit

## Consequences

### Positive
- Fast key-value storage with minimal overhead
- Encryption support for sensitive data
- TTL-based automatic expiration
- Reactive updates via streams
- Works offline without network

### Negative
- No hive_generator due to version conflict with drift_dev
- Manual JSON serialization required
- Box management complexity

### Neutral
- JSON serialization aligns with existing DTO patterns
- Cache boxes are separate from Drift database

## Technical Notes

### Version Conflict
`hive_generator` requires `source_gen ^1.0.0` while `drift_dev` requires `source_gen >=3.0.0`. We chose to use JSON serialization instead of TypeAdapters to avoid this conflict.

### Integration with CompositeRepository
The cache layer integrates with CompositeRepository:
1. Check Hive cache first
2. If miss/expired, fetch from remote
3. Populate cache on successful remote fetch
4. On network failure, serve stale cache data

## Alternatives Considered

1. **SharedPreferences**: Rejected due to lack of encryption and complex data support
2. **SQLite/Drift only**: Rejected as Drift is for structured data, not caching
3. **Custom file-based cache**: Rejected due to maintenance burden
4. **ObjectBox**: Rejected due to additional native dependencies

## References
- Hive: https://pub.dev/packages/hive
- hive_flutter: https://pub.dev/packages/hive_flutter
