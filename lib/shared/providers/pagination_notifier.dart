import 'package:flutter_base_2025/core/base/paginated_list.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sentinel value for copyWith to distinguish between null and not provided.
const _sentinel = Object();

/// State for paginated data.
class PaginationState<T> {
  const PaginationState({
    required this.data,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.error,
  });

  factory PaginationState.initial() =>
      PaginationState(data: PaginatedList.empty());
  final PaginatedList<T> data;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? error;

  PaginationState<T> copyWith({
    PaginatedList<T>? data,
    bool? isLoadingMore,
    bool? isRefreshing,
    Object? error = _sentinel,
  }) => PaginationState(
    data: data ?? this.data,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    error: error == _sentinel ? this.error : error as String?,
  );

  /// Returns true if initial load is in progress.
  bool get isInitialLoading => data.isEmpty && !isLoadingMore && error == null;

  /// Returns true if any loading is in progress.
  bool get isLoading => isLoadingMore || isRefreshing;

  /// Returns true if there are items.
  bool get hasData => data.isNotEmpty;

  /// Returns true if there was an error.
  bool get hasError => error != null;

  /// Returns true if more items can be loaded.
  bool get canLoadMore => data.hasMore && !isLoadingMore;
}

/// Generic pagination notifier for infinite scroll.
/// T = Item type
abstract class PaginationNotifier<T> extends AsyncNotifier<PaginationState<T>> {
  PaginationNotifier({int pageSize = 20}) : _pageSize = pageSize;
  int _currentPage = 1;
  final int _pageSize;

  /// Fetches a page of data. Override in subclass.
  Future<Result<PaginatedList<T>>> fetchPage(int page, int pageSize);

  @override
  Future<PaginationState<T>> build() async {
    _currentPage = 1;
    final result = await fetchPage(_currentPage, _pageSize);

    return result.fold(
      (failure) =>
          PaginationState<T>.initial().copyWith(error: failure.userMessage),
      (data) => PaginationState(data: data),
    );
  }

  /// Loads the next page of data.
  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    if (!currentState.canLoadMore) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    final nextPage = _currentPage + 1;
    final result = await fetchPage(nextPage, _pageSize);

    result.fold(
      (failure) {
        // Preserve existing items on failure
        state = AsyncData(
          currentState.copyWith(
            isLoadingMore: false,
            error: failure.userMessage,
          ),
        );
      },
      (newData) {
        _currentPage = nextPage;
        final combinedData = currentState.data.concat(newData);
        state = AsyncData(PaginationState(data: combinedData));
      },
    );
  }

  /// Refreshes the data from the first page.
  Future<void> refresh() async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      ref.invalidateSelf();
      return;
    }

    state = AsyncData(currentState.copyWith(isRefreshing: true));

    _currentPage = 1;
    final result = await fetchPage(_currentPage, _pageSize);

    result.fold(
      (failure) {
        // Preserve existing items on failure
        state = AsyncData(
          currentState.copyWith(
            isRefreshing: false,
            error: failure.userMessage,
          ),
        );
      },
      (data) {
        state = AsyncData(PaginationState(data: data));
      },
    );
  }

  /// Resets to initial state.
  void reset() {
    _currentPage = 1;
    ref.invalidateSelf();
  }

  /// Clears any error state.
  void clearError() {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(error: null));
    }
  }
}

/// Extension to add valueOrNull to AsyncValue for Riverpod 3.0 compatibility.
extension AsyncValueNullable<T> on AsyncValue<T> {
  /// Returns the value if available, null otherwise.
  T? get valueOrNull => whenOrNull(data: (v) => v);
}

/// Extension for easy pagination state handling in widgets.
extension PaginationStateExtension<T> on AsyncValue<PaginationState<T>> {
  /// Returns items or empty list.
  List<T> get items => whenOrNull(data: (s) => s.data.items) ?? [];

  /// Returns true if loading more.
  bool get isLoadingMore => whenOrNull(data: (s) => s.isLoadingMore) ?? false;

  /// Returns true if refreshing.
  bool get isRefreshing => whenOrNull(data: (s) => s.isRefreshing) ?? false;

  /// Returns true if can load more.
  bool get canLoadMore => whenOrNull(data: (s) => s.canLoadMore) ?? false;

  /// Returns error message or null.
  String? get errorMessage => whenOrNull(data: (s) => s.error);
}
