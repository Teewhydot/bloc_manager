import 'package:meta/meta.dart';

import '../base/base_state.dart';
import '../utils/logger.dart';

/// Pagination metadata returned by [PaginationBlocMixin.onLoadPage].
@immutable
class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int? totalItems;
  final int? totalPages;
  final bool hasNextPage;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    this.totalItems,
    this.totalPages,
    required this.hasNextPage,
  });

  @override
  String toString() =>
      'PaginatedResult(items: ${items.length}, page: $page, hasNext: $hasNextPage)';
}

/// Snapshot of pagination position.
@immutable
class PaginationInfo {
  final int currentPage;
  final int pageSize;
  final int? totalItems;
  final int? totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final bool isLoadingNextPage;

  const PaginationInfo({
    required this.currentPage,
    required this.pageSize,
    this.totalItems,
    this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.isLoadingNextPage = false,
  });

  PaginationInfo copyWith({
    int? currentPage,
    int? pageSize,
    int? totalItems,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    bool? isLoadingNextPage,
  }) =>
      PaginationInfo(
        currentPage: currentPage ?? this.currentPage,
        pageSize: pageSize ?? this.pageSize,
        totalItems: totalItems ?? this.totalItems,
        totalPages: totalPages ?? this.totalPages,
        hasNextPage: hasNextPage ?? this.hasNextPage,
        hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
        isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      );

  @override
  String toString() =>
      'PaginationInfo(page: $currentPage, size: $pageSize, hasNext: $hasNextPage)';
}

/// Mixin that provides pagination functionality to BLoCs/Cubits.
///
/// ```dart
/// class ItemsCubit extends BaseCubit<BaseState<List<Item>>>
///     with PaginationBlocMixin<Item, BaseState<List<Item>>> {
///
///   @override
///   Future<PaginatedResult<Item>> onLoadPage({
///     required int page, required int pageSize,
///   }) async => repo.fetchPage(page: page, pageSize: pageSize);
///
///   @override
///   Future<void> onPageLoaded(PaginatedResult<Item> result, int pageNumber) async {
///     // merge or replace your list state here
///   }
/// }
/// ```
mixin PaginationBlocMixin<T, State extends BaseState> {
  PaginationInfo? _paginationInfo;

  /// Whether pagination is enabled.
  bool get paginationEnabled => true;

  /// Default page size.
  int get defaultPageSize => 20;

  /// Current pagination snapshot.
  PaginationInfo? get paginationInfo => _paginationInfo;

  bool get hasNextPage => _paginationInfo?.hasNextPage ?? false;
  bool get isLoadingNextPage => _paginationInfo?.isLoadingNextPage ?? false;
  int get currentPage => _paginationInfo?.currentPage ?? 1;

  /// Initialise pagination state. Call from your cubit's `load()` before
  /// the first page request.
  @protected
  void initializePagination({int? pageSize}) {
    _paginationInfo = PaginationInfo(
      currentPage: 1,
      pageSize: pageSize ?? defaultPageSize,
      hasNextPage: true,
      hasPreviousPage: false,
    );
    BlocManagerLogger.logBasic(
      'Pagination initialized (pageSize: ${_paginationInfo!.pageSize})',
    );
  }

  /// Request the first page (or reset and reload from scratch).
  @protected
  Future<void> loadFirstPage({int? pageSize}) async {
    if (!paginationEnabled) return;
    _paginationInfo = PaginationInfo(
      currentPage: 1,
      pageSize: pageSize ?? _paginationInfo?.pageSize ?? defaultPageSize,
      hasNextPage: true,
      hasPreviousPage: false,
    );
    try {
      BlocManagerLogger.logBasic('Loading first page');
      final result = await onLoadPage(page: 1, pageSize: _paginationInfo!.pageSize);
      await onPageLoaded(result, 1);
    } catch (e, st) {
      BlocManagerLogger.logError('Failed to load first page: $e');
      await onPageLoadError(e, st, 1);
    }
  }

  /// Append the next page. No-op if already at the last page.
  @protected
  Future<void> loadNextPage() async {
    if (!paginationEnabled || !hasNextPage || isLoadingNextPage) return;
    _paginationInfo = _paginationInfo!.copyWith(isLoadingNextPage: true);
    final nextPage = currentPage + 1;
    try {
      BlocManagerLogger.logBasic('Loading page $nextPage');
      final result = await onLoadPage(
        page: nextPage,
        pageSize: _paginationInfo!.pageSize,
      );
      await onPageLoaded(result, nextPage);
    } catch (e, st) {
      BlocManagerLogger.logError('Failed to load page $nextPage: $e');
      await onPageLoadError(e, st, nextPage);
    } finally {
      _paginationInfo = _paginationInfo!.copyWith(isLoadingNextPage: false);
    }
  }

  /// Call after a successful page load to advance the pagination cursor.
  @protected
  void updatePaginationInfo({
    int? totalItems,
    int? totalPages,
    bool? hasNextPage,
    int? loadedPage,
  }) {
    if (_paginationInfo == null) return;
    final page = loadedPage ?? _paginationInfo!.currentPage;
    final calcTotal = totalPages ??
        (totalItems != null
            ? (totalItems / _paginationInfo!.pageSize).ceil()
            : null);
    final calcHasNext =
        hasNextPage ?? (calcTotal != null ? page < calcTotal : true);

    _paginationInfo = _paginationInfo!.copyWith(
      currentPage: page,
      totalItems: totalItems ?? _paginationInfo!.totalItems,
      totalPages: calcTotal,
      hasNextPage: calcHasNext,
      hasPreviousPage: page > 1,
      isLoadingNextPage: false,
    );
    BlocManagerLogger.logBasic('Pagination updated: $_paginationInfo');
  }

  /// Reset pagination cursor.
  @protected
  void resetPagination() {
    _paginationInfo = null;
    BlocManagerLogger.logBasic('Pagination reset');
  }

  /// Returns true when the scroll position suggests more data should be loaded.
  @protected
  bool shouldLoadMore(double scrollPosition, double maxScrollExtent) {
    if (!hasNextPage || isLoadingNextPage) return false;
    return scrollPosition >= maxScrollExtent * 0.8;
  }

  /// Implement to fetch a single page of data.
  @protected
  Future<PaginatedResult<T>> onLoadPage({
    required int page,
    required int pageSize,
  });

  /// Called with the result of a successful page load.
  @protected
  Future<void> onPageLoaded(PaginatedResult<T> result, int pageNumber);

  /// Called when a page load fails (default: logs the error).
  @protected
  Future<void> onPageLoadError(
    Object error,
    StackTrace stackTrace,
    int pageNumber,
  ) async {
    BlocManagerLogger.logError('Page $pageNumber load failed: $error');
  }
}
