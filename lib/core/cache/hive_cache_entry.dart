/// Cache entry with TTL metadata stored in Hive.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 2.6**
///
/// Note: Using JSON serialization instead of HiveType adapters
/// due to hive_generator version conflict with drift_dev.
class HiveCacheEntry<T> {
  HiveCacheEntry({
    required this.data,
    required this.cachedAt,
    required this.expiresAt,
    this.key,
  });

  /// Create entry with TTL duration
  factory HiveCacheEntry.withTtl({
    required T data,
    required Duration ttl,
    String? key,
  }) {
    final now = DateTime.now();
    return HiveCacheEntry(
      data: data,
      cachedAt: now,
      expiresAt: now.add(ttl),
      key: key,
    );
  }

  /// Create from JSON map
  factory HiveCacheEntry.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) dataFromJson,
  ) => HiveCacheEntry(
    data: dataFromJson(json['data'] as Map<String, dynamic>),
    cachedAt: DateTime.parse(json['cachedAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    key: json['key'] as String?,
  );

  /// The cached data
  final T data;

  /// When the entry was cached
  final DateTime cachedAt;

  /// When the entry expires
  final DateTime expiresAt;

  /// Optional key for identification
  final String? key;

  /// Check if the entry has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Time remaining until expiration
  Duration get timeToLive {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Convert to JSON map for storage
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) dataToJson) => {
    'data': dataToJson(data),
    'cachedAt': cachedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'key': key,
  };

  @override
  String toString() =>
      'HiveCacheEntry(key: $key, cachedAt: $cachedAt, expiresAt: $expiresAt, '
      'isExpired: $isExpired)';
}
