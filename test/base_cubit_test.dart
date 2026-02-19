import 'package:bloc_manager/bloc_manager.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Test double ──────────────────────────────────────────────────────────────
class CounterCubit extends BaseCubit<BaseState<int>> {
  CounterCubit() : super(const InitialState());

  void start() => emitLoading('working');
  void succeed() => emitSuccess('Done!', {'count': 1});
  void fail() => emitError('Oops', errorCode: 'E01');

  Future<void> loadValue(int value) => executeAsync(
        () async => value,
        onSuccess: (v) =>
            emit(LoadedState(data: v, lastUpdated: DateTime.now())),
        loadingMessage: 'Loading…',
      );

  Future<void> loadWithSuccessMessage(int value) => executeAsync(
        () async => value,
        successMessage: 'Loaded!',
      );

  Future<void> loadFailure() => executeAsync<int>(
        () async => throw Exception('net error'),
      );

  Future<void> loadFailureCustom() => executeAsync<int>(
        () async => throw Exception('custom'),
        onError: (e) => emitError('handled: $e', errorCode: 'CUSTOM'),
      );
}

// ── Tests ─────────────────────────────────────────────────────────────────────
void main() {
  group('emitLoading', () {
    blocTest<CounterCubit, BaseState<int>>(
      'emits LoadingState with message',
      build: CounterCubit.new,
      act: (c) => c.start(),
      expect: () => [
        isA<LoadingState<int>>()
            .having((s) => s.message, 'message', 'working'),
      ],
    );
  });

  group('emitSuccess', () {
    blocTest<CounterCubit, BaseState<int>>(
      'emits SuccessState with message and metadata',
      build: CounterCubit.new,
      act: (c) => c.succeed(),
      expect: () => [
        isA<SuccessState<int>>()
            .having((s) => s.successMessage, 'successMessage', 'Done!')
            .having((s) => s.metadata, 'metadata', {'count': 1}),
      ],
    );
  });

  group('emitError', () {
    blocTest<CounterCubit, BaseState<int>>(
      'emits ErrorState with message and errorCode',
      build: CounterCubit.new,
      act: (c) => c.fail(),
      expect: () => [
        isA<ErrorState<int>>()
            .having((s) => s.errorMessage, 'errorMessage', 'Oops')
            .having((s) => s.errorCode, 'errorCode', 'E01'),
      ],
    );
  });

  group('executeAsync – success path', () {
    blocTest<CounterCubit, BaseState<int>>(
      'emits LoadingState then LoadedState when onSuccess provided',
      build: CounterCubit.new,
      act: (c) => c.loadValue(42),
      expect: () => [
        isA<LoadingState<int>>()
            .having((s) => s.message, 'message', 'Loading…'),
        isA<LoadedState<int>>()
            .having((s) => s.data, 'data', 42),
      ],
    );

    blocTest<CounterCubit, BaseState<int>>(
      'emits SuccessState by message when no onSuccess callback',
      build: CounterCubit.new,
      act: (c) => c.loadWithSuccessMessage(7),
      expect: () => [
        isA<LoadingState<int>>(),
        isA<SuccessState<int>>()
            .having((s) => s.successMessage, 'successMessage', 'Loaded!'),
      ],
    );
  });

  group('executeAsync – error path', () {
    blocTest<CounterCubit, BaseState<int>>(
      'emits LoadingState then ErrorState on unhandled exception',
      build: CounterCubit.new,
      act: (c) => c.loadFailure(),
      expect: () => [
        isA<LoadingState<int>>(),
        isA<ErrorState<int>>()
            .having((s) => s.errorMessage, 'errorMessage', contains('net error')),
      ],
    );

    blocTest<CounterCubit, BaseState<int>>(
      'calls onError callback when provided',
      build: CounterCubit.new,
      act: (c) => c.loadFailureCustom(),
      expect: () => [
        isA<LoadingState<int>>(),
        isA<ErrorState<int>>()
            .having((s) => s.errorMessage, 'message', startsWith('handled:'))
            .having((s) => s.errorCode, 'code', 'CUSTOM'),
      ],
    );
  });

  group('state convenience checks post-emit', () {
    test('isLoading after emitLoading', () {
      final cubit = CounterCubit()..start();
      expect(cubit.state.isLoading, isTrue);
      cubit.close();
    });

    test('isError after emitError', () {
      final cubit = CounterCubit()..fail();
      expect(cubit.state.isError, isTrue);
      expect(cubit.state.errorMessage, 'Oops');
      cubit.close();
    });

    test('isSuccess after emitSuccess', () {
      final cubit = CounterCubit()..succeed();
      expect(cubit.state.isSuccess, isTrue);
      cubit.close();
    });
  });
}
