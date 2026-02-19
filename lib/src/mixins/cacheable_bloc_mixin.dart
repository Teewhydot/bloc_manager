import 'package:meta/meta.dart';

import '../base/base_state.dart';
import '../utils/logger.dart';

/// Mixin that provides in-memory caching functionality to BLoCs/Cubits.
///
/// ```dart
/// class MyBloc extends BaseCubit<BaseState<MyData>> with CacheableBlocMixin {
///   @override
///   String get cacheKey => 'my_bloc_data';
///
///   @override
///   Map<String, dynamic>? stateToJson(BaseState<MyData> state) { ... }
///
///   @override
///   BaseState<MyData>? stateFromJson(Map<String, dynamic> json) { ... }
/// }
/// ```
mixin CacheableBlocMixin<State extends BaseState> {
  /// Duration after which cached data is considered stale.
  Duration get cacheTimeout => const Duration(hours: 1);

  /// Unique key for caching this BLoC's state.
  String get cacheKey;

  /// Whether caching is enabled.
  bool get enableCaching => true;

  /// Convert state to JSON for caching.
  Map<String, dynamic>? stateToJson(State state);

  /// Create state from cached JSON.
  State? stateFromJson(Map<String, dynamic> json);

  // Simple in-memory cache.
  static final Map<String, Map<String, dynamic>> _cache = {};

  /// Save current state to cache.
  @protected
  Future<void> saveStateToCache(State state) async {
    if (!enableCaching) return;
    try {
      final jsonData = stateToJson(state);
      if (jsonData != null) {
        _cache[cacheKey] = {
          'state': jsonData,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        BlocManagerLogger.logBasic('State cached for $cacheKey');
      }
    } catch (e) {
      BlocManagerLogger.logError('Failed to cache state for $cacheKey: $e');
    }
  }

  /// Load state from cache.
  @protected
  Future<State?> loadStateFromCache() async {
    if (!enableCaching) return null;
    try {
      final cacheData = _cache[cacheKey];
      if (cacheData == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(
        cacheData['timestamp'] as int,
      );
      if (DateTime.now().difference(cacheTime) > cacheTimeout) {
        BlocManagerLogger.logBasic('Cache expired for $cacheKey');
        await clearCache();
        return null;
      }

      final state = stateFromJson(cacheData['state'] as Map<String, dynamic>);
      if (state != null) {
        BlocManagerLogger.logBasic('State loaded from cache for $cacheKey');
      }
      return state;
    } catch (e) {
      BlocManagerLogger.logError('Failed to load cached state for $cacheKey: $e');
      await clearCache();
      return null;
    }
  }

  /// Clear cached state.
  @protected
  Future<void> clearCache() async {
    try {
      _cache.remove(cacheKey);
      BlocManagerLogger.logBasic('Cache cleared for $cacheKey');
    } catch (e) {
      BlocManagerLogger.logError('Failed to clear cache for $cacheKey: $e');
    }
  }

  /// Whether valid cached data exists.
  @protected
  Future<bool> hasCachedData() async {
    if (!enableCaching) return false;
    try {
      final cacheData = _cache[cacheKey];
      if (cacheData == null) return false;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(
        cacheData['timestamp'] as int,
      );
      return DateTime.now().difference(cacheTime) <= cacheTimeout;
    } catch (_) {
      return false;
    }
  }

  /// Age of the current cache entry, or null if not cached.
  @protected
  Future<Duration?> getCacheAge() async {
    if (!enableCaching) return null;
    try {
      final cacheData = _cache[cacheKey];
      if (cacheData == null) return null;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(
        cacheData['timestamp'] as int,
      );
      return DateTime.now().difference(cacheTime);
    } catch (_) {
      return null;
    }
  }
}
