/// Cache entry with value and metadata.
/// Consolidated version used by all cache implementations.
///
/// **Feature: flutter-state-of-art-code-review-2025**
/// **Validates: Requirements TD-02 (Cache consolidation)**
class CacheEntry<T> {
  CacheEntry({
    required this.value,
    DateTime? cachedAt,
    this.expiresAt,
  }) : cachedAt = cachedAt ?? DateTime.now();

  /// Factory for quick creation with TTL.
  factory CacheEntry.withTtl(T value, {Duration? ttl}) {
    final now = DateTime.now();
    return CacheEntry(
      value: value,
      cachedAt: now,
      expiresAt: ttl != null ? now.add(ttl) : null,
    );
  }

  final T value;
  final DateTime cachedAt;
  final DateTime? expiresAt;

  /// Returns true if entry has expired.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Returns remaining TTL in milliseconds, or null if no expiration.
  int? get remainingTtlMs {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now()).inMilliseconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Returns age of cached entry in milliseconds.
  int get ageMs => DateTime.now().difference(cachedAt).inMilliseconds;

  @override
  String toString() => 'CacheEntry(value: $value, '
      'cached: $cachedAt, '
      'expires: ${expiresAt ?? 'never'}, '
      'expired: $isExpired)';
}
