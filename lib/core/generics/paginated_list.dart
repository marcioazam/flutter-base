/// Paginated list for domain layer.
class PaginatedList<T> {

  const PaginatedList({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasMore,
  });

  /// Creates empty paginated list.
  factory PaginatedList.empty() => const PaginatedList(
        items: [],
        page: 1,
        pageSize: 20,
        totalItems: 0,
        totalPages: 0,
        hasMore: false,
      );

  /// Creates from items with calculated pagination.
  factory PaginatedList.fromItems(
    List<T> items, {
    required int page,
    required int pageSize,
    required int totalItems,
  }) {
    final totalPages = pageSize > 0 ? (totalItems / pageSize).ceil() : 0;
    return PaginatedList(
      items: items,
      page: page,
      pageSize: pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
      hasMore: page < totalPages,
    );
  }
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasMore;

  /// Returns true if list is empty.
  bool get isEmpty => items.isEmpty;

  /// Returns true if list is not empty.
  bool get isNotEmpty => items.isNotEmpty;

  /// Returns number of items in current page.
  int get length => items.length;

  /// Returns true if this is the first page.
  bool get isFirstPage => page == 1;

  /// Returns true if this is the last page.
  bool get isLastPage => !hasMore;

  /// Maps items to another type.
  PaginatedList<R> map<R>(R Function(T) mapper) => PaginatedList(
        items: items.map(mapper).toList(),
        page: page,
        pageSize: pageSize,
        totalItems: totalItems,
        totalPages: totalPages,
        hasMore: hasMore,
      );

  /// Concatenates with another paginated list (for infinite scroll).
  PaginatedList<T> concat(PaginatedList<T> other) => PaginatedList(
      items: [...items, ...other.items],
      page: other.page,
      pageSize: pageSize,
      totalItems: other.totalItems,
      totalPages: other.totalPages,
      hasMore: other.hasMore,
    );

  /// Filters items while preserving pagination metadata.
  PaginatedList<T> where(bool Function(T) test) => PaginatedList(
        items: items.where(test).toList(),
        page: page,
        pageSize: pageSize,
        totalItems: totalItems,
        totalPages: totalPages,
        hasMore: hasMore,
      );

  /// Returns item at index or null.
  T? itemAt(int index) => index >= 0 && index < items.length ? items[index] : null;

  /// Creates a copy with updated items.
  PaginatedList<T> copyWith({
    List<T>? items,
    int? page,
    int? pageSize,
    int? totalItems,
    int? totalPages,
    bool? hasMore,
  }) => PaginatedList(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );

  @override
  String toString() =>
      'PaginatedList(page: $page/$totalPages, items: ${items.length}, total: $totalItems, hasMore: $hasMore)';
}
