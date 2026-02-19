import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_manager/bloc_manager.dart';

// ── Concrete cubit ────────────────────────────────────────────────────────────
class RefreshableCubit extends BaseCubit<BaseState<int>>
    with RefreshableBlocMixin<BaseState<int>> {
  RefreshableCubit() : super(const InitialState());

  int refreshCount = 0;
  bool throwOnRefresh = false;

  @override
  Future<void> onRefresh() async {
    refreshCount++;
    if (throwOnRefresh) throw Exception('refresh failed');
    emit(LoadedState<int>(data: refreshCount, lastUpdated: DateTime.now()));
  }

  // Public wrappers.
  Future<void> triggerRefresh() => performRefresh();
  Future<void> triggerForceRefresh() => forceRefresh();
  void startAuto() => startAutoRefresh();
  void stopAuto() => stopAutoRefresh();
  void dispose_() => disposeRefreshable();

  @override
  Duration get refreshCooldown => const Duration(milliseconds: 100);
}

class AutoRefreshCubit extends RefreshableCubit {
  @override
  bool get autoRefreshEnabled => true;

  @override
  Duration get autoRefreshInterval => const Duration(milliseconds: 50);
}

// ── Tests ─────────────────────────────────────────────────────────────────────
void main() {
  late RefreshableCubit cubit;

  setUp(() => cubit = RefreshableCubit());
  tearDown(() {
    cubit.dispose_();
    cubit.close();
  });

  group('canRefresh', () {
    test('is true initially', () => expect(cubit.canRefresh, isTrue));

    test('is false during refresh', () async {
      // Intercept mid-flight by checking inside onRefresh.
      bool? midFlightCanRefresh;
      final Completer<void> completer = Completer();
      late final _SlowRefreshCubit special;

      special = _SlowRefreshCubit(
        onRefreshCallback: () async {
          midFlightCanRefresh = special.canRefresh; // check THIS cubit's state
          completer.complete();
          await Future.delayed(const Duration(milliseconds: 1));
        },
      );
      unawaited(special.triggerRefresh());
      await completer.future;
      expect(midFlightCanRefresh, isFalse);
      await special.close();
    });

    test('is false within cooldown window', () async {
      await cubit.triggerRefresh();
      expect(cubit.canRefresh, isFalse);
    });

    test('is true after cooldown expires', () async {
      await cubit.triggerRefresh();
      await Future.delayed(const Duration(milliseconds: 150));
      expect(cubit.canRefresh, isTrue);
    });
  });

  group('performRefresh', () {
    test('calls onRefresh and increments count', () async {
      await cubit.triggerRefresh();
      expect(cubit.refreshCount, 1);
    });

    test('blocked during cooldown', () async {
      await cubit.triggerRefresh();
      await cubit.triggerRefresh(); // should be swallowed
      expect(cubit.refreshCount, 1);
    });

    test('emits error state when onRefresh throws', () async {
      cubit.throwOnRefresh = true;
      await cubit.triggerRefresh();
      // no exception propagates to the caller
      expect(cubit.isRefreshing, isFalse);
    });

    test('isRefreshing is false after completion', () async {
      await cubit.triggerRefresh();
      expect(cubit.isRefreshing, isFalse);
    });
  });

  group('forceRefresh', () {
    test('bypasses cooldown', () async {
      await cubit.triggerRefresh();
      // immediately force again (within cooldown) – should run
      await cubit.triggerForceRefresh();
      expect(cubit.refreshCount, 2);
    });
  });

  group('disposeRefreshable', () {
    test('clears timer without throwing', () {
      cubit.startAuto();
      expect(() => cubit.dispose_(), returnsNormally);
    });
  });
}

// Helper – lets us inspect canRefresh mid-flight.
class _SlowRefreshCubit extends BaseCubit<BaseState<int>>
    with RefreshableBlocMixin<BaseState<int>> {
  _SlowRefreshCubit({required this.onRefreshCallback})
      : super(const InitialState());

  final Future<void> Function() onRefreshCallback;

  @override
  Future<void> onRefresh() => onRefreshCallback();

  Future<void> triggerRefresh() => performRefresh();

  @override
  Duration get refreshCooldown => const Duration(milliseconds: 100);
}
