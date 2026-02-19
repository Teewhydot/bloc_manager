import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_manager/bloc_manager.dart';

// ── Concrete cubit that exercises the mixin ───────────────────────────────────
class CacheableCubit extends BaseCubit<BaseState<String>>
    with CacheableBlocMixin<BaseState<String>> {
  CacheableCubit() : super(const InitialState());

  @override
  String get cacheKey => 'test_cache';

  @override
  Map<String, dynamic>? stateToJson(BaseState<String> state) {
    if (state is LoadedState<String>) {
      return {'data': state.data, 'ts': state.lastUpdated?.millisecondsSinceEpoch};
    }
    return null;
  }

  @override
  BaseState<String>? stateFromJson(Map<String, dynamic> json) {
    final data = json['data'] as String?;
    if (data == null) return null;
    final ts = json['ts'] as int?;
    return LoadedState<String>(
      data: data,
      lastUpdated:
          ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null,
    );
  }

  // Public wrappers so tests can call the protected methods.
  Future<void> pubSave(BaseState<String> s) => saveStateToCache(s);
  Future<BaseState<String>?> pubLoad() => loadStateFromCache();
  Future<void> pubClear() => clearCache();
  Future<bool> pubHas() => hasCachedData();
  Future<Duration?> pubAge() => getCacheAge();
}

void main() {
  late CacheableCubit cubit;

  setUp(() => cubit = CacheableCubit());
  tearDown(() async {
    await cubit.pubClear();
    await cubit.close();
  });

  group('saveStateToCache / loadStateFromCache', () {
    test('round-trips a LoadedState', () async {
      final state = LoadedState<String>(
        data: 'hello',
        lastUpdated: DateTime(2026, 2, 19),
      );
      await cubit.pubSave(state);
      final restored = await cubit.pubLoad();

      expect(restored, isA<LoadedState<String>>());
      expect((restored as LoadedState<String>).data, 'hello');
    });

    test('returns null when nothing cached', () async {
      final result = await cubit.pubLoad();
      expect(result, isNull);
    });

    test('does not cache non-data states (stateToJson returns null)', () async {
      await cubit.pubSave(const InitialState());
      final result = await cubit.pubLoad();
      expect(result, isNull);
    });
  });

  group('hasCachedData', () {
    test('returns false before any save', () async {
      expect(await cubit.pubHas(), isFalse);
    });

    test('returns true after save', () async {
      await cubit.pubSave(LoadedState<String>(data: 'x'));
      expect(await cubit.pubHas(), isTrue);
    });

    test('returns false after clear', () async {
      await cubit.pubSave(LoadedState<String>(data: 'x'));
      await cubit.pubClear();
      expect(await cubit.pubHas(), isFalse);
    });
  });

  group('getCacheAge', () {
    test('returns null before any save', () async {
      expect(await cubit.pubAge(), isNull);
    });

    test('returns a small duration immediately after save', () async {
      await cubit.pubSave(LoadedState<String>(data: 'x'));
      final age = await cubit.pubAge();
      expect(age, isNotNull);
      expect(age!.inSeconds, lessThan(2));
    });
  });

  group('enableCaching = false', () {
    late CacheableCubit noCache;
    setUp(() => noCache = _NoCacheCubit());
    tearDown(() => noCache.close());

    test('saveStateToCache is skipped', () async {
      await noCache.pubSave(LoadedState<String>(data: 'x'));
      expect(await noCache.pubLoad(), isNull);
    });

    test('hasCachedData always false', () async {
      expect(await noCache.pubHas(), isFalse);
    });
  });

  group('clearCache', () {
    test('load returns null after clear', () async {
      await cubit.pubSave(LoadedState<String>(data: 'boom'));
      await cubit.pubClear();
      expect(await cubit.pubLoad(), isNull);
    });
  });
}

// Subclass with caching disabled to test the guard.
class _NoCacheCubit extends CacheableCubit {
  @override
  bool get enableCaching => false;
}
