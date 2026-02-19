import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../utils/logger.dart';
import 'base_state.dart';

/// Base BLoC with common error handling and helper emit methods.
///
/// ```dart
/// class MyBloc extends BaseBloc<MyEvent, BaseState<MyData>> {
///   MyBloc() : super(const InitialState()) {
///     on<MyEvent>(_onMyEvent);
///   }
///   Future<void> _onMyEvent(MyEvent event, Emitter emit) async { ... }
/// }
/// ```
abstract class BaseBloc<Event, State extends BaseState>
    extends Bloc<Event, State> {
  BaseBloc(super.initialState) {
    stream.listen((state) {
      if (state.isLoading || state.isInitial) return;
      if (state.isError) {
        BlocManagerLogger.logError(
          '$runtimeType → ${state.errorMessage}',
          tag: 'BLoC',
        );
      } else if (state.isSuccess) {
        BlocManagerLogger.logSuccess(
          '$runtimeType → ${state.successMessage}',
          tag: 'BLoC',
        );
      }
    });
  }

  @protected
  void handleException(Exception exception, [StackTrace? stackTrace]) {
    BlocManagerLogger.logError('$runtimeType Exception: $exception', tag: 'BLoC');
  }

  @override
  void onTransition(Transition<Event, State> transition) {
    super.onTransition(transition);
    if (transition.nextState.isLoading || transition.nextState.isInitial) return;
    BlocManagerLogger.logBasic(
      '$runtimeType: ${transition.currentState.runtimeType} → ${transition.nextState.runtimeType}',
      tag: 'BLoC',
    );
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    BlocManagerLogger.logError('$runtimeType error: $error', tag: 'BLoC');
  }
}

/// Base Cubit with common error handling and helper emit methods.
///
/// ```dart
/// class MyCubit extends BaseCubit<BaseState<MyData>> {
///   MyCubit() : super(const InitialState());
///
///   Future<void> load() async {
///     emitLoading();
///     final result = await repo.fetchData();
///     result.fold(
///       (err)  => emitError(err.message),
///       (data) => emit(LoadedState(data: data, lastUpdated: DateTime.now())),
///     );
///   }
/// }
/// ```
abstract class BaseCubit<State extends BaseState> extends Cubit<State> {
  BaseCubit(super.initialState) {
    stream.listen((state) {
      if (state.isLoading || state.isInitial) return;
      if (state.isError) {
        BlocManagerLogger.logError(
          '$runtimeType → ${state.errorMessage}',
          tag: 'Cubit',
        );
      } else if (state.isSuccess) {
        BlocManagerLogger.logSuccess(
          '$runtimeType → ${state.successMessage}',
          tag: 'Cubit',
        );
      }
    });
  }

  @protected
  void handleException(Exception exception, [StackTrace? stackTrace]) {
    BlocManagerLogger.logError(
      '$runtimeType Exception: $exception',
      tag: 'Cubit',
    );
    emitError(exception.toString(), exception: exception, stackTrace: stackTrace);
  }

  @protected
  void emitLoading([String? message, double? progress]) {
    // ignore: invalid_use_of_visible_for_testing_member
    // LoadingState<Never> is a subtype of BaseState<T> for any T (Never is
    // Dart's bottom type), so the downcast is always safe at runtime.
    emit(LoadingState<Never>(message: message, progress: progress) as State);
  }

  @protected
  void emitSuccess(String message, [Map<String, dynamic>? metadata]) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(SuccessState<Never>(successMessage: message, metadata: metadata) as State);
  }

  @protected
  void emitError(
    String message, {
    Exception? exception,
    StackTrace? stackTrace,
    String? errorCode,
  }) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(ErrorState<Never>(
      errorMessage: message,
      exception: exception,
      stackTrace: stackTrace,
      errorCode: errorCode,
    ) as State);
  }

  /// Wraps an async call in loading → success/error automatically.
  @protected
  Future<void> executeAsync<T>(
    Future<T> Function() operation, {
    void Function(T result)? onSuccess,
    void Function(Exception exception)? onError,
    String? loadingMessage,
    String? successMessage,
  }) async {
    try {
      emitLoading(loadingMessage);
      final result = await operation();
      if (onSuccess != null) {
        onSuccess(result);
      } else if (successMessage != null) {
        emitSuccess(successMessage);
      }
    } on Exception catch (e, stackTrace) {
      if (onError != null) {
        onError(e);
      } else {
        handleException(e, stackTrace);
      }
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    BlocManagerLogger.logError('$runtimeType error: $error', tag: 'Cubit');
  }
}
