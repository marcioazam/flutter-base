import 'dart:async';

import 'package:flutter/material.dart';

/// Infinite scroll controller state.
enum InfiniteScrollState { idle, loading, error, noMoreData }

/// Infinite scroll controller.
class InfiniteScrollController<T> extends ChangeNotifier {

  InfiniteScrollController({
    required this.fetchPage,
    this.pageSize = 20,
    this.loadThreshold = 0.8,
  });
  final Future<List<T>> Function(int page, int pageSize) fetchPage;
  final int pageSize;
  final double loadThreshold;

  List<T> _items = [];
  int _currentPage = 1;
  InfiniteScrollState _state = InfiniteScrollState.idle;
  String? _errorMessage;
  bool _hasMoreData = true;

  List<T> get items => List.unmodifiable(_items);
  InfiniteScrollState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  bool get isLoading => _state == InfiniteScrollState.loading;
  bool get isEmpty => _items.isEmpty && _state != InfiniteScrollState.loading;

  /// Loads the first page.
  Future<void> loadInitial() async {
    _currentPage = 1;
    _items = [];
    _hasMoreData = true;
    _errorMessage = null;
    await _loadPage();
  }

  /// Loads the next page.
  Future<void> loadMore() async {
    if (_state == InfiniteScrollState.loading || !_hasMoreData) return;
    _currentPage++;
    await _loadPage();
  }

  /// Refreshes the list.
  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> _loadPage() async {
    _state = InfiniteScrollState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final newItems = await fetchPage(_currentPage, pageSize);

      if (newItems.length < pageSize) {
        _hasMoreData = false;
      }

      if (_currentPage == 1) {
        _items = newItems;
      } else {
        _items = [..._items, ...newItems];
      }

      _state = _hasMoreData
          ? InfiniteScrollState.idle
          : InfiniteScrollState.noMoreData;
    } on Exception catch (e) {
      _state = InfiniteScrollState.error;
      _errorMessage = e.toString();
      if (_currentPage > 1) _currentPage--;
    }

    notifyListeners();
  }

  /// Handles scroll notification.
  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      final threshold = metrics.maxScrollExtent * loadThreshold;

      if (metrics.pixels >= threshold && _hasMoreData && !isLoading) {
        loadMore();
      }
    }
    return false;
  }

  /// Removes an item.
  void removeItem(T item) {
    _items.remove(item);
    notifyListeners();
  }

  /// Removes item at index.
  void removeAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Inserts an item at the beginning.
  void insertFirst(T item) {
    _items.insert(0, item);
    notifyListeners();
  }

  /// Updates an item.
  void updateItem(int index, T item) {
    if (index >= 0 && index < _items.length) {
      _items[index] = item;
      notifyListeners();
    }
  }
}

/// Infinite list view widget.
class InfiniteListView<T> extends StatefulWidget {

  const InfiniteListView({
    required this.controller, required this.itemBuilder, super.key,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.endOfListWidget,
    this.separatorWidget,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });
  final InfiniteScrollController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final Widget? endOfListWidget;
  final Widget? separatorWidget;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  State<InfiniteListView<T>> createState() => _InfiniteListViewState<T>();
}

class _InfiniteListViewState<T> extends State<InfiniteListView<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    if (widget.controller.items.isEmpty) {
      widget.controller.loadInitial();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller.isEmpty && controller.state == InfiniteScrollState.loading) {
      return widget.loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (controller.isEmpty && controller.state == InfiniteScrollState.error) {
      return widget.errorWidget ??
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.errorMessage ?? 'Error loading data'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
    }

    if (controller.isEmpty) {
      return widget.emptyWidget ?? const Center(child: Text('No items'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: controller.handleScrollNotification,
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.separated(
          padding: widget.padding,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          itemCount: controller.items.length + 1,
          separatorBuilder: (context, index) =>
              widget.separatorWidget ?? const SizedBox.shrink(),
          itemBuilder: (context, index) {
            if (index == controller.items.length) {
              return _buildFooter(controller);
            }
            return widget.itemBuilder(context, controller.items[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildFooter(InfiniteScrollController<T> controller) {
    switch (controller.state) {
      case InfiniteScrollState.loading:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      case InfiniteScrollState.error:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: TextButton(
              onPressed: controller.loadMore,
              child: const Text('Retry'),
            ),
          ),
        );
      case InfiniteScrollState.noMoreData:
        return widget.endOfListWidget ??
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'End of list',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
      case InfiniteScrollState.idle:
        return const SizedBox(height: 16);
    }
  }
}
