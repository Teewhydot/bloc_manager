import 'dart:async';

import 'package:meta/meta.dart';

import '../base/base_state.dart';
import '../utils/logger.dart';

/// Mixin that provides pull-to-refresh and auto-refresh functionality.
///
/// ```dart
/// class NewsFeedCubit extends BaseCubit<BaseState<List<Article>>>
///     with RefreshableBlocMixin {
///
///   @override
///   Future<void> onRefresh() async {
///     emitLoading();
///     final articles = await repo.fetchLatest();
///     emit(LoadedState(data: articles, lastUpdated: DateTime.now()));
///   }
/// }
/// ```
mixin RefreshableBlocMixin<State extends BaseState> {
  bool _isRefreshing = false;
  DateTime? _lastRefreshTime;
  Timer? _autoRefreshTimer;

  /// Minimum time between refresh calls (prevents spam).
  Duration get refreshCooldown => const Duration(seconds: 2);

  /// Whether pull-to-refresh is supported.
  bool get supportsRefresh => true;

  /// Whether a periodic auto-refresh timer should be started.
  bool get autoRefreshEnabled => false;

  /// Interval for automatic refresh when [autoRefreshEnabled] is true.
  Duration get autoRefreshInterval => const Duration(minutes: 5);

  bool get isRefreshing => _isRefreshing;

  bool get canRefresh {
    if (!supportsRefresh || _isRefreshing) return false;
    if (_lastRefreshTime == null) return true;
    return DateTime.now().difference(_lastRefreshTime!) >= refreshCooldown;
  }

  Duration? get refreshCooldownRemaining {
    if (_lastRefreshTime == null || canRefresh) return null;
    final elapsed = DateTime.now().difference(_lastRefreshTime!);
    return refreshCooldown - elapsed;
  }

  /// Trigger a refresh (respects cooldown).
  @protected
  Future<void> performRefresh() async {
    if (!canRefresh) {
      BlocManagerLogger.logWarning(
        'Refresh blocked – ${_isRefreshing ? 'already refreshing' : 'in cooldown'}',
      );
      return;
    }
    _isRefreshing = true;
    _lastRefreshTime = DateTime.now();
    try {
      BlocManagerLogger.logBasic('Refresh started');
      await onRefresh();
      BlocManagerLogger.logBasic('Refresh completed');
    } catch (e, st) {
      BlocManagerLogger.logError('Refresh failed: $e');
      await onRefreshError(e, st);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Trigger a refresh, bypassing the cooldown check.
  @protected
  Future<void> forceRefresh() async {
    if (!supportsRefresh) return;
    _isRefreshing = true;
    _lastRefreshTime = DateTime.now();
    try {
      BlocManagerLogger.logBasic('Forced refresh started');
      await onRefresh();
      BlocManagerLogger.logBasic('Forced refresh completed');
    } catch (e, st) {
      BlocManagerLogger.logError('Forced refresh failed: $e');
      await onRefreshError(e, st);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Start the periodic auto-refresh timer.
  @protected
  void startAutoRefresh() {
    if (!autoRefreshEnabled || !supportsRefresh) return;
    stopAutoRefresh();
    _autoRefreshTimer = Timer.periodic(autoRefreshInterval, (_) {
      if (canRefresh) performRefresh();
    });
    BlocManagerLogger.logBasic('Auto-refresh started ($autoRefreshInterval)');
  }

  /// Cancel the auto-refresh timer.
  @protected
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Release timer resources. Call from your cubit's `close()`.
  @protected
  void disposeRefreshable() => stopAutoRefresh();

  /// Implement with the actual data-loading logic.
  @protected
  Future<void> onRefresh();

  /// Called when [onRefresh] throws (default: logs the error).
  @protected
  Future<void> onRefreshError(Object error, StackTrace stackTrace) async {
    BlocManagerLogger.logError('Refresh error: $error');
  }
}
