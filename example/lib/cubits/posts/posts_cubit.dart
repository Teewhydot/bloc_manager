import 'package:bloc_manager/bloc_manager.dart';
import 'package:bloc_manager_example/models/post.dart';
import 'package:bloc_manager_example/repositories/posts_repository.dart';

/// PostsCubit demonstrates the PaginationBlocMixin feature.
/// It loads posts in pages and allows infinite scroll pagination.
class PostsCubit extends BaseCubit<BaseState<List<Post>>>
    with PaginationBlocMixin<Post, BaseState<List<Post>>> {
  final PostsRepository _repository;
  final List<Post> _accumulatedPosts = [];

  PostsCubit({PostsRepository? repository})
      : _repository = repository ?? PostsRepository(),
        super(const InitialState()) {
    // Initialize pagination and load first page
    initializePagination(pageSize: 10);
    loadFirstPage();
  }

  // Current data accessor
  List<Post> get posts => state.data ?? [];

  @override
  Future<PaginatedResult<Post>> onLoadPage({
    required int page,
    required int pageSize,
  }) async {
    final posts = await _repository.fetchPosts(
      page: page,
      pageSize: pageSize,
    );

    // Get total count for pagination info (JSONPlaceholder has 100 posts)
    final totalCount = 100;

    return PaginatedResult(
      items: posts,
      page: page,
      pageSize: pageSize,
      totalItems: totalCount,
      totalPages: (totalCount / pageSize).ceil(),
      hasNextPage: page * pageSize < totalCount,
    );
  }

  @override
  Future<void> onPageLoaded(PaginatedResult<Post> result, int pageNumber) async {
    if (pageNumber == 1) {
      _accumulatedPosts.clear();
      _accumulatedPosts.addAll(result.items);
    } else {
      _accumulatedPosts.addAll(result.items);
    }

    emit(LoadedState<List<Post>>(
      data: List.from(_accumulatedPosts),
      lastUpdated: DateTime.now(),
    ));

    updatePaginationInfo(
      totalItems: result.totalItems,
      totalPages: result.totalPages,
      hasNextPage: result.hasNextPage,
      loadedPage: pageNumber,
    );
  }

  @override
  Future<void> onPageLoadError(
    Object error,
    StackTrace stackTrace,
    int pageNumber,
  ) async {
    // Show specific message based on page number
    final errorMessage = pageNumber == 1
        ? 'Failed to load posts. Please try again.'
        : 'Failed to load more posts. Pull to refresh.';

    emitError(errorMessage, exception: error as Exception?, stackTrace: stackTrace);
  }

  /// Reset pagination and reload from first page
  void refresh() {
    _accumulatedPosts.clear();
    resetPagination();
    loadFirstPage();
  }

  /// Public method to load next page (wraps protected mixin method)
  void loadMore() => loadNextPage();

  @override
  Future<void> close() {
    _accumulatedPosts.clear();
    return super.close();
  }
}
