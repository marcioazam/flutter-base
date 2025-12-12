/// Configuration for Hive cache.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 2.6**
class HiveCacheConfig {
  const HiveCacheConfig({
    this.defaultTtl = const Duration(hours: 1),
    this.maxEntries = 1000,
    this.encryptSensitiveBoxes = true,
    this.subDirectory = 'hive_cache',
  });

  /// Default time-to-live for cache entries
  final Duration defaultTtl;

  /// Maximum number of entries per box
  final int maxEntries;

  /// Whether to encrypt boxes containing sensitive data
  final bool encryptSensitiveBoxes;

  /// Subdirectory for Hive storage
  final String subDirectory;

  /// Create config for development (shorter TTL, no encryption)
  factory HiveCacheConfig.development() => const HiveCacheConfig(
        defaultTtl: Duration(minutes: 5),
        encryptSensitiveBoxes: false,
      );

  /// Create config for production (longer TTL, encryption enabled)
  factory HiveCacheConfig.production() => const HiveCacheConfig(
        defaultTtl: Duration(hours: 24),
        encryptSensitiveBoxes: true,
      );

  @override
  String toString() =>
      'HiveCacheConfig(defaultTtl: $defaultTtl, maxEntries: $maxEntries, '
      'encryptSensitiveBoxes: $encryptSensitiveBoxes)';
}
