import 'package:bloc_manager/bloc_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── InitialState ────────────────────────────────────────────────────────────
  group('InitialState', () {
    const state = InitialState<String>();

    test('isInitial is true', () => expect(state.isInitial, isTrue));
    test('isLoading is false', () => expect(state.isLoading, isFalse));
    test('isError is false', () => expect(state.isError, isFalse));
    test('isSuccess is false', () => expect(state.isSuccess, isFalse));
    test('isLoaded is false', () => expect(state.isLoaded, isFalse));
    test('hasData is false', () => expect(state.hasData, isFalse));
    test('data is null', () => expect(state.data, isNull));
    test('errorMessage is null', () => expect(state.errorMessage, isNull));
    test('successMessage is null', () => expect(state.successMessage, isNull));

    test('equality', () => expect(const InitialState<String>(), equals(state)));
    test('props is empty', () => expect(state.props, isEmpty));
    test('toString', () => expect(state.toString(), 'InitialState<String>'));
  });

  // ── LoadingState ────────────────────────────────────────────────────────────
  group('LoadingState', () {
    const plain = LoadingState<int>();
    const withMessage = LoadingState<int>(message: 'Saving…', progress: 0.5);

    test('isLoading is true', () => expect(plain.isLoading, isTrue));
    test('isInitial is false', () => expect(plain.isInitial, isFalse));
    test('message defaults to null', () => expect(plain.message, isNull));
    test('progress defaults to null', () => expect(plain.progress, isNull));

    test('message is set', () => expect(withMessage.message, 'Saving…'));
    test('progress is set', () => expect(withMessage.progress, 0.5));

    test('equality same args',
        () => expect(const LoadingState<int>(), equals(plain)));
    test('inequality different message',
        () => expect(withMessage, isNot(equals(plain))));

    test('props contains message and progress', () {
      expect(withMessage.props, equals(['Saving…', 0.5]));
    });

    test('toString contains message',
        () => expect(withMessage.toString(), contains('Saving…')));
  });

  // ── SuccessState ────────────────────────────────────────────────────────────
  group('SuccessState', () {
    const state =
        SuccessState<void>(successMessage: 'Profile saved', metadata: {'id': 1});

    test('isSuccess is true', () => expect(state.isSuccess, isTrue));
    test('isError is false', () => expect(state.isError, isFalse));
    test('successMessage is accessible via base getter',
        () => expect(state.successMessage, 'Profile saved'));
    test('metadata is accessible', () => expect(state.metadata, {'id': 1}));

    test('equality preserves successMessage', () {
      expect(
        const SuccessState<void>(successMessage: 'Profile saved', metadata: {'id': 1}),
        equals(state),
      );
    });

    test('toString contains message',
        () => expect(state.toString(), contains('Profile saved')));
  });

  // ── ErrorState ──────────────────────────────────────────────────────────────
  group('ErrorState', () {
    final exc = Exception('boom');
    final state = ErrorState<String>(
      errorMessage: 'Something failed',
      exception: exc,
      errorCode: 'ERR_001',
    );

    test('isError is true', () => expect(state.isError, isTrue));
    test('isSuccess is false', () => expect(state.isSuccess, isFalse));
    test('errorMessage is accessible via base getter',
        () => expect(state.errorMessage, 'Something failed'));
    test('errorCode is set', () => expect(state.errorCode, 'ERR_001'));
    test('exception is set', () => expect(state.exception, exc));

    test('equality by message + code', () {
      expect(
        ErrorState<String>(
            errorMessage: 'Something failed',
            exception: exc,
            errorCode: 'ERR_001'),
        equals(state),
      );
    });

    test('toString contains message and code',
        () => expect(state.toString(), contains('ERR_001')));
  });

  // ── LoadedState ─────────────────────────────────────────────────────────────
  group('LoadedState', () {
    final now = DateTime(2026, 2, 19);
    final state =
        LoadedState<String>(data: 'hello', lastUpdated: now, isFromCache: true);

    test('isLoaded is true', () => expect(state.isLoaded, isTrue));
    test('isSuccess is false', () => expect(state.isSuccess, isFalse));
    test('hasData is true', () => expect(state.hasData, isTrue));
    test('data is accessible', () => expect(state.data, 'hello'));
    test('lastUpdated is set', () => expect(state.lastUpdated, now));
    test('isFromCache is true', () => expect(state.isFromCache, isTrue));
    test('isFromCache defaults to false', () {
      final s = LoadedState<String>(data: 'x');
      expect(s.isFromCache, isFalse);
    });

    test('equality', () {
      expect(
        LoadedState<String>(data: 'hello', lastUpdated: now, isFromCache: true),
        equals(state),
      );
    });

    test('toString', () => expect(state.toString(), contains('fromCache: true')));
  });

  // ── EmptyState ──────────────────────────────────────────────────────────────
  group('EmptyState', () {
    const state = EmptyState<List<int>>(message: 'No results');

    test('hasData is false', () => expect(state.hasData, isFalse));
    test('data is null', () => expect(state.data, isNull));
    test('message is set', () => expect(state.message, 'No results'));
    test('isLoaded is false', () => expect(state.isLoaded, isFalse));

    test('equality', () =>
        expect(const EmptyState<List<int>>(message: 'No results'), equals(state)));
  });

  // ── Async states ────────────────────────────────────────────────────────────
  group('AsyncLoadingState', () {
    const state = AsyncLoadingState<int>(
      data: 42,
      message: 'Refreshing…',
      isRefreshing: true,
    );

    test('holds stale data', () => expect(state.data, 42));
    test('message is set', () => expect(state.message, 'Refreshing…'));
    test('isRefreshing is true', () => expect(state.isRefreshing, isTrue));
    test('toString', () => expect(state.toString(), contains('hasData: true')));
  });

  group('AsyncLoadedState', () {
    final now = DateTime(2026);
    final state = AsyncLoadedState<int>(
      data: 7,
      lastUpdated: now,
      isFromCache: false,
    );

    test('data is set', () => expect(state.data, 7));
    test('lastUpdated is set', () => expect(state.lastUpdated, now));
    test('isFromCache defaults to false', () => expect(state.isFromCache, isFalse));
    test('toString', () => expect(state.toString(), contains('lastUpdated')));
  });

  group('AsyncErrorState', () {
    const state = AsyncErrorState<String>(
      errorMessage: 'Refresh failed',
      errorCode: 'NET_ERR',
      isRetryable: true,
    );

    test('isRetryable is true', () => expect(state.isRetryable, isTrue));
    test('errorMessage via AppErrorState', () => expect(state.errorMessage, 'Refresh failed'));
    test('errorCode is set', () => expect(state.errorCode, 'NET_ERR'));
    test('data defaults to null', () => expect(state.data, isNull));
    test('toString', () => expect(state.toString(), contains('retryable: true')));
  });

  // ── Cross-cutting convenience getters ───────────────────────────────────────
  group('BaseState convenience getters', () {
    test('data returns null from non-data state', () {
      expect(const InitialState<int>().data, isNull);
    });

    test('errorMessage returns null from non-error state', () {
      expect(const InitialState<int>().errorMessage, isNull);
    });

    test('successMessage returns null from non-success state', () {
      expect(const LoadingState<int>().successMessage, isNull);
    });

    test('data from LoadedState is accessible via base class', () {
      final BaseState<String> state = LoadedState<String>(data: 'base');
      expect(state.data, 'base');
    });
  });
}
