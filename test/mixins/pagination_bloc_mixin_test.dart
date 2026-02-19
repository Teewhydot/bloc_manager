import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_manager/bloc_manager.dart';

// ── Concrete cubit ────────────────────────────────────────────────────────────
class ItemsCubit extends BaseCubit<BaseState<List<String>>>
    with PaginationBlocMixin<String, BaseState<List<String>>> {
  ItemsCubit() : super(const InitialState());

  List<String> _items = [];
  int loadPageCallCount = 0;
  bool throwOnLoad = false;

  @override
  Future<PaginatedResult<String>> onLoadPage({
    required int page,
    required int pageSize,
  }) async {
    loadPageCallCount++;
    if (throwOnLoad) throw Exception('load failed');
    final items = List.generate(pageSize, (i) => 'item_p${page}_$i');
    final hasNext = page < 3; // 3 total pages in test
    return PaginatedResult<String>(
      items: items,
      page: page,
      pageSize: pageSize,
      totalItems: pageSize * 3,
      hasNextPage: hasNext,
    );
  }

  @override
  Future<void> onPageLoaded(PaginatedResult<String> result, int pageNumber) async {
    _items = pageNumber == 1 ? result.items : [..._items, ...result.items];
    emit(LoadedState(data: List.unmodifiable(_items), lastUpdated: DateTime.now()));
    updatePaginationInfo(
      totalItems: result.totalItems,
      hasNextPage: result.hasNextPage,
      loadedPage: pageNumber,
    );
  }

  // Public wrappers for protected methods.
  Future<void> pubLoadFirst({int? pageSize}) => loadFirstPage(pageSize: pageSize);
  Future<void> pubLoadNext() => loadNextPage();
  void pubInit({int? pageSize}) => initializePagination(pageSize: pageSize);
  void pubUpdate({int? totalItems, bool? hasNextPage, int? loadedPage}) =>
      updatePaginationInfo(
          totalItems: totalItems, hasNextPage: hasNextPage, loadedPage: loadedPage);
  void pubReset() => resetPagination();
  bool pubShouldLoad(double pos, double max) => shouldLoadMore(pos, max);
}

// ── Tests ─────────────────────────────────────────────────────────────────────
void main() {
  late ItemsCubit cubit;

  setUp(() => cubit = ItemsCubit());
  tearDown(() => cubit.close());

  group('initializePagination', () {
    test('sets page 1 with default size', () {
      cubit.pubInit();
      expect(cubit.currentPage, 1);
      expect(cubit.paginationInfo?.pageSize, 20); // defaultPageSize
    });

    test('accepts custom page size', () {
      cubit.pubInit(pageSize: 5);
      expect(cubit.paginationInfo?.pageSize, 5);
    });

    test('hasNextPage is true after init', () {
      cubit.pubInit();
      expect(cubit.hasNextPage, isTrue);
    });
  });

  group('loadFirstPage', () {
    test('calls onLoadPage with page=1', () async {
      await cubit.pubLoadFirst(pageSize: 5);
      expect(cubit.loadPageCallCount, 1);
    });

    test('emits LoadedState with items', () async {
      await cubit.pubLoadFirst(pageSize: 3);
      expect(cubit.state, isA<LoadedState<List<String>>>());
      expect((cubit.state.data as List<String>).length, 3);
    });

    test('sets currentPage to 1', () async {
      await cubit.pubLoadFirst(pageSize: 2);
      expect(cubit.currentPage, 1);
    });

    test('handles onLoadPage throwing without propagating', () async {
      cubit.throwOnLoad = true;
      await expectLater(cubit.pubLoadFirst(), completes);
    });
  });

  group('loadNextPage', () {
    test('advances page cursor', () async {
      await cubit.pubLoadFirst(pageSize: 2);
      await cubit.pubLoadNext();
      expect(cubit.currentPage, 2);
    });

    test('appends items to list', () async {
      await cubit.pubLoadFirst(pageSize: 2);
      await cubit.pubLoadNext();
      expect((cubit.state.data as List<String>).length, 4);
    });

    test('is no-op when hasNextPage is false', () async {
      // Load all 3 pages.
      await cubit.pubLoadFirst(pageSize: 2);
      await cubit.pubLoadNext(); // page 2
      await cubit.pubLoadNext(); // page 3 — hasNextPage becomes false
      final countBefore = cubit.loadPageCallCount;
      await cubit.pubLoadNext(); // should not call
      expect(cubit.loadPageCallCount, countBefore);
    });

    test('is no-op when not yet initialized', () async {
      await expectLater(cubit.pubLoadNext(), completes);
      expect(cubit.loadPageCallCount, 0);
    });
  });

  group('updatePaginationInfo', () {
    setUp(() => cubit.pubInit(pageSize: 5));

    test('updates currentPage', () {
      cubit.pubUpdate(loadedPage: 2, hasNextPage: true);
      expect(cubit.currentPage, 2);
    });

    test('sets hasPreviousPage when page > 1', () {
      cubit.pubUpdate(loadedPage: 2, hasNextPage: true);
      expect(cubit.paginationInfo?.hasPreviousPage, isTrue);
    });

    test('infers hasNextPage from totalItems / pageSize', () {
      cubit.pubUpdate(totalItems: 10, loadedPage: 1);
      // 10 items, pageSize=5 → 2 pages → page 1 has next
      expect(cubit.hasNextPage, isTrue);
    });
  });

  group('resetPagination', () {
    test('clears paginationInfo', () {
      cubit.pubInit();
      cubit.pubReset();
      expect(cubit.paginationInfo, isNull);
    });

    test('hasNextPage is false after reset', () {
      cubit.pubInit();
      cubit.pubReset();
      expect(cubit.hasNextPage, isFalse);
    });
  });

  group('shouldLoadMore', () {
    setUp(() async => cubit.pubLoadFirst(pageSize: 2));

    test('returns true at 80% scroll threshold', () {
      expect(cubit.pubShouldLoad(800, 1000), isTrue);
    });

    test('returns false below threshold', () {
      expect(cubit.pubShouldLoad(500, 1000), isFalse);
    });

    test('returns false when no next page', () async {
      // Exhaust all 3 pages.
      await cubit.pubLoadNext();
      await cubit.pubLoadNext();
      expect(cubit.pubShouldLoad(900, 1000), isFalse);
    });
  });

  group('PaginatedResult', () {
    test('toString contains meaningful info', () {
      const r = PaginatedResult<int>(
        items: [1, 2],
        page: 1,
        pageSize: 10,
        hasNextPage: true,
      );
      expect(r.toString(), contains('items: 2'));
      expect(r.toString(), contains('page: 1'));
    });
  });

  group('PaginationInfo.copyWith', () {
    test('creates new instance with updated field', () {
      const info = PaginationInfo(
        currentPage: 1,
        pageSize: 10,
        hasNextPage: true,
        hasPreviousPage: false,
      );
      final updated = info.copyWith(currentPage: 2, hasPreviousPage: true);
      expect(updated.currentPage, 2);
      expect(updated.hasPreviousPage, isTrue);
      // Unchanged field preserved.
      expect(updated.pageSize, 10);
    });
  });
}
