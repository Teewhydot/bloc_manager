import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'app_state.dart';

/// Base sealed class for all BLoC/Cubit states.
///
/// Subclass your data type:
/// ```dart
/// // Nothing else needed — just use the pre-built states:
/// emit(const LoadingState<UserData>());
/// emit(LoadedState<UserData>(data: user, lastUpdated: DateTime.now()));
/// emit(ErrorState<UserData>(errorMessage: 'Login failed'));
/// ```
@immutable
sealed class BaseState<T> extends Equatable {
  const BaseState();

  bool get isLoading  => this is LoadingState;
  bool get isInitial  => this is InitialState;
  bool get isLoaded   => this is LoadedState;
  bool get isError    => this is ErrorState;
  bool get isSuccess  => this is SuccessState;
  bool get hasData    => this is DataState && (this as DataState).data != null;

  String? get errorMessage   => isError   ? (this as ErrorState).errorMessage   : null;
  String? get successMessage => isSuccess ? (this as SuccessState).successMessage : null;
  T? get data => hasData ? (this as DataState<T>).data : null;

  @override
  List<Object?> get props => [];
}

// ─── Concrete states ──────────────────────────────────────────────────────────

/// Starting state — emitted before any operation begins.
@immutable
final class InitialState<T> extends BaseState<T> {
  const InitialState();
  @override
  String toString() => 'InitialState<$T>';
}

/// Operation in progress.
@immutable
final class LoadingState<T> extends BaseState<T> {
  final String? message;
  final double? progress;

  const LoadingState({this.message, this.progress});

  @override
  List<Object?> get props => [message, progress];

  @override
  String toString() => 'LoadingState<$T>(message: $message)';
}

/// Operation completed successfully (no persistent data needed).
@immutable
final class SuccessState<T> extends BaseState<T> implements AppSuccessState {
  @override
  final String successMessage;
  final Map<String, dynamic>? metadata;

  const SuccessState({required this.successMessage, this.metadata});

  @override
  List<Object?> get props => [successMessage, metadata];

  @override
  String toString() => 'SuccessState<$T>(message: $successMessage)';
}

/// Operation failed.
@immutable
final class ErrorState<T> extends BaseState<T> implements AppErrorState {
  @override
  final String errorMessage;
  final Exception? exception;
  final StackTrace? stackTrace;
  final String? errorCode;

  const ErrorState({
    required this.errorMessage,
    this.exception,
    this.stackTrace,
    this.errorCode,
  });

  @override
  List<Object?> get props => [errorMessage, exception, errorCode];

  @override
  String toString() => 'ErrorState<$T>(message: $errorMessage, code: $errorCode)';
}

// ─── Data-bearing states ──────────────────────────────────────────────────────

/// Base for states that carry a data payload.
@immutable
sealed class DataState<T> extends BaseState<T> {
  @override
  final T? data;

  const DataState({this.data});

  @override
  List<Object?> get props => [data];
}

/// Data loaded successfully. Use [isFromCache] to inform the UI.
@immutable
final class LoadedState<T> extends DataState<T> {
  final DateTime? lastUpdated;
  final bool isFromCache;

  const LoadedState({
    required T data,
    this.lastUpdated,
    this.isFromCache = false,
  }) : super(data: data);

  @override
  List<Object?> get props => [data, lastUpdated, isFromCache];

  @override
  String toString() => 'LoadedState<$T>(fromCache: $isFromCache)';
}

/// Operation succeeded but returned no data.
@immutable
final class EmptyState<T> extends DataState<T> {
  final String? message;

  const EmptyState({this.message}) : super(data: null);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'EmptyState<$T>(message: $message)';
}

// ─── Async variants (for streams / real-time data) ───────────────────────────

/// Base for async states that can carry existing data during refreshes.
@immutable
sealed class AsyncState<T> extends DataState<T> {
  final bool isRefreshing;
  final String? operationId;

  const AsyncState({super.data, this.isRefreshing = false, this.operationId});

  @override
  List<Object?> get props => [data, isRefreshing, operationId];
}

/// Async load in progress — optionally holds stale data for optimistic UI.
@immutable
final class AsyncLoadingState<T> extends AsyncState<T> {
  final String? message;
  final double? progress;

  const AsyncLoadingState({
    super.data,
    this.message,
    this.progress,
    super.isRefreshing = false,
    super.operationId,
  });

  @override
  List<Object?> get props => [data, message, progress, isRefreshing, operationId];

  @override
  String toString() => 'AsyncLoadingState<$T>(hasData: ${data != null})';
}

/// Async data loaded successfully.
@immutable
final class AsyncLoadedState<T> extends AsyncState<T> {
  final DateTime lastUpdated;
  final bool isFromCache;

  const AsyncLoadedState({
    required super.data,
    required this.lastUpdated,
    this.isFromCache = false,
    super.isRefreshing = false,
    super.operationId,
  });

  @override
  List<Object?> get props =>
      [data, lastUpdated, isFromCache, isRefreshing, operationId];

  @override
  String toString() => 'AsyncLoadedState<$T>(lastUpdated: $lastUpdated)';
}

/// Async operation failed — optionally retains last-good data.
@immutable
final class AsyncErrorState<T> extends AsyncState<T> implements AppErrorState {
  @override
  final String errorMessage;
  final Exception? exception;
  final String? errorCode;
  final bool isRetryable;

  const AsyncErrorState({
    required this.errorMessage,
    super.data,
    this.exception,
    this.errorCode,
    this.isRetryable = false,
    super.isRefreshing = false,
    super.operationId,
  });

  @override
  List<Object?> get props => [
        data, errorMessage, exception, errorCode, isRetryable,
        isRefreshing, operationId,
      ];

  @override
  String toString() =>
      'AsyncErrorState<$T>(error: $errorMessage, retryable: $isRetryable)';
}
