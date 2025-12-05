import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/result.dart';
import 'paginated_list.dart';

/// State for pagination operations.
class PaginationState<T> {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;

  const PaginationState({
    this.items = const [],
    this.currentPage = 0,
    this.pageSize = 20,
    this.totalItems = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? pageSize,
    int? totalItems,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) {
    return PaginationState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isEmpty => items.isEmpty && !isLoading;
  bool get hasError => error != null;
  int get totalPages => pageSize > 0 ? (totalItems / pageSize).ceil() : 0;
}

/// Generic pagination notifier for infinite scroll.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 5.2, 5.4, 5.5**
abstract class PaginationNotifier<T> extends Notifier<PaginationState<T>> {
  @override
  PaginationState<T> build() => const PaginationState();

  /// Fetches a page of data. Override in subclass.
  Future<Result<PaginatedList<T>>> fetchPage(int page, int pageSize);

  /// Loads the first page of data.
  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await fetchPage(1, state.pageSize);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
        );
      },
      (paginatedList) {
        state = state.copyWith(
          items: paginatedList.items,
          currentPage: paginatedList.page,
          totalItems: paginatedList.totalItems,
          hasMore: paginatedList.hasMore,
          isLoading: false,
        );
      },
    );
  }

  /// Loads the next page of data.
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    final nextPage = state.currentPage + 1;
    final result = await fetchPage(nextPage, state.pageSize);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          error: failure,
        );
      },
      (paginatedList) {
        state = state.copyWith(
          items: [...state.items, ...paginatedList.items],
          currentPage: paginatedList.page,
          totalItems: paginatedList.totalItems,
          hasMore: paginatedList.hasMore,
          isLoadingMore: false,
        );
      },
    );
  }

  /// Refreshes the data from the first page.
  Future<void> refresh() async {
    state = state.copyWith(
      items: [],
      currentPage: 0,
      hasMore: true,
      clearError: true,
    );
    await loadInitial();
  }

  /// Resets the pagination state.
  void reset() {
    state = const PaginationState();
  }

  /// Updates page size and reloads.
  Future<void> setPageSize(int pageSize) async {
    if (pageSize == state.pageSize) return;
    state = state.copyWith(pageSize: pageSize);
    await refresh();
  }
}

/// AsyncNotifier variant for pagination.
abstract class AsyncPaginationNotifier<T>
    extends AsyncNotifier<PaginationState<T>> {
  @override
  Future<PaginationState<T>> build() async => const PaginationState();

  /// Fetches a page of data. Override in subclass.
  Future<Result<PaginatedList<T>>> fetchPage(int page, int pageSize);

  /// Loads the first page of data.
  Future<void> loadInitial() async {
    final currentState = state.valueOrNull ?? const PaginationState();
    if (currentState.isLoading) return;

    state = AsyncData(currentState.copyWith(isLoading: true, clearError: true));

    final result = await fetchPage(1, currentState.pageSize);

    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(
          isLoading: false,
          error: failure,
        ));
      },
      (paginatedList) {
        state = AsyncData(currentState.copyWith(
          items: paginatedList.items,
          currentPage: paginatedList.page,
          totalItems: paginatedList.totalItems,
          hasMore: paginatedList.hasMore,
          isLoading: false,
        ));
      },
    );
  }

  /// Loads the next page of data.
  Future<void> loadMore() async {
    final currentState = state.valueOrNull ?? const PaginationState();
    if (currentState.isLoading ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state =
        AsyncData(currentState.copyWith(isLoadingMore: true, clearError: true));

    final nextPage = currentState.currentPage + 1;
    final result = await fetchPage(nextPage, currentState.pageSize);

    result.fold(
      (failure) {
        state = AsyncData(currentState.copyWith(
          isLoadingMore: false,
          error: failure,
        ));
      },
      (paginatedList) {
        state = AsyncData(currentState.copyWith(
          items: [...currentState.items, ...paginatedList.items],
          currentPage: paginatedList.page,
          totalItems: paginatedList.totalItems,
          hasMore: paginatedList.hasMore,
          isLoadingMore: false,
        ));
      },
    );
  }

  /// Refreshes the data from the first page.
  Future<void> refresh() async {
    state = const AsyncData(PaginationState());
    await loadInitial();
  }

  /// Resets the pagination state.
  void reset() {
    state = const AsyncData(PaginationState());
  }
}
