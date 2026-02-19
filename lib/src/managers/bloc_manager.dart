import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../base/base_state.dart';
import '../utils/logger.dart';
import 'bloc_manager_theme.dart';

/// A declarative widget that wraps a BLoC/Cubit and handles the common
/// cross-cutting concerns automatically:
///
///  * Loading overlay (via [showLoadingIndicator])
///  * Error snackbars (via [showResultErrorNotifications])
///  * Success snackbars (via [showResultSuccessNotifications])
///  * Pull-to-refresh (via [enablePullToRefresh])
///  * Custom listeners and builders
///
/// ## Basic usage
/// ```dart
/// BlocManager<MyCubit, BaseState<MyData>>(
///   bloc: context.read<MyCubit>(),
///   child: MyScreen(),
/// )
/// ```
///
/// ## With custom listener
/// ```dart
/// BlocManager<MyCubit, BaseState<MyData>>(
///   bloc: context.read<MyCubit>(),
///   onSuccess: (context, state) => Navigator.pop(context),
///   onError:   (context, state) => logger.captureError(state.errorMessage),
///   child: MyScreen(),
/// )
/// ```
///
/// ## With builder
/// ```dart
/// BlocManager<MyCubit, BaseState<MyData>>(
///   bloc: context.read<MyCubit>(),
///   builder: (context, state) {
///     if (state is EmptyState) return const EmptyView();
///     if (state is LoadedState<MyData>) return DataView(state.data!);
///     return const SizedBox.shrink();
///   },
///   child: const SizedBox.shrink(), // ignored when builder is provided
/// )
/// ```
class BlocManager<T extends BlocBase<S>, S extends BaseState>
    extends StatelessWidget {
  // ── Required ──────────────────────────────────────────────────────────────

  /// The BLoC/Cubit instance to manage.
  final T bloc;

  /// Fallback child widget (used when [builder] is null).
  final Widget child;

  // ── Optional customisation ────────────────────────────────────────────────

  /// Custom widget builder — receives the current state.
  /// When provided, [child] is ignored.
  final Widget Function(BuildContext context, S state)? builder;

  /// Custom listener callback — fires on every meaningful state change.
  final void Function(BuildContext context, S state)? listener;

  /// Called when the state is an [ErrorState].
  final void Function(BuildContext context, S state)? onError;

  /// Called when the state is a [SuccessState] or [LoadedState].
  final void Function(BuildContext context, S state)? onSuccess;

  // ── Behaviour flags ───────────────────────────────────────────────────────

  /// Show a full-screen loading overlay during [LoadingState]. Default: true.
  final bool showLoadingIndicator;

  /// Automatically show built-in error notifications for [ErrorState].
  /// `null` (default) inherits from [BlocManagerTheme].
  /// Only applies when no [onError] is set on this instance or in the theme.
  final bool? showResultErrorNotifications;

  /// Automatically show built-in success notifications for [SuccessState].
  /// `null` (default) inherits from [BlocManagerTheme].
  /// Only applies when no [onSuccess] is set on this instance or in the theme.
  final bool? showResultSuccessNotifications;

  /// Enable pull-to-refresh. Requires [onRefresh]. Default: false.
  final bool enablePullToRefresh;

  /// Called on pull-to-refresh. Only used when [enablePullToRefresh] is true.
  final Future<void> Function()? onRefresh;

  // ── Visual customisation ──────────────────────────────────────────────────

  /// Replaces the default [SpinKitCircle] while loading.
  /// `null` inherits from [BlocManagerTheme], then falls back to SpinKitCircle.
  final Widget? loadingWidget;

  /// Tint colour for the loading overlay.
  /// `null` inherits from [BlocManagerTheme], then falls back to primary/50%.
  final Color? loadingColor;

  /// Background colour for the built-in error snackbar.
  final Color errorSnackbarColor;

  /// Background colour for the built-in success snackbar.
  final Color successSnackbarColor;

  const BlocManager({
    super.key,
    required this.bloc,
    required this.child,
    this.builder,
    this.listener,
    this.onError,
    this.onSuccess,
    this.showLoadingIndicator = true,
    this.showResultErrorNotifications,   // null = inherit from theme
    this.showResultSuccessNotifications, // null = inherit from theme
    this.enablePullToRefresh = false,
    this.onRefresh,
    this.loadingWidget,   // null = inherit from theme
    this.loadingColor,    // null = inherit from theme
    this.errorSnackbarColor = const Color(0xFFB00020),
    this.successSnackbarColor = const Color(0xFF388E3C),
  });

  @override
  Widget build(BuildContext context) {
    final theme = BlocManagerTheme.of(context);

    // Resolve effective values: instance → theme → built-in default
    final effectiveLoadingWidget = loadingWidget ?? theme.loadingWidget;
    final effectiveLoadingColor = loadingColor ?? theme.loadingColor;
    final effectiveShowErrors =
        showResultErrorNotifications ?? theme.showResultErrorNotifications;
    final effectiveShowSuccess =
        showResultSuccessNotifications ?? theme.showResultSuccessNotifications;

    return BlocProvider<T>.value(
      value: bloc,
      child: BlocConsumer<T, S>(
        listenWhen: (previous, current) {
          if (current.isError && !previous.isError) return true;
          if (current.isSuccess && !previous.isSuccess) return true;
          if (current is LoadedState && previous is! LoadedState) return true;
          if (listener != null && previous != current) return true;
          return false;
        },
        buildWhen: (previous, current) {
          if (previous is InitialState ||
              current is InitialState ||
              current is LoadingState ||
              current is ErrorState ||
              current is EmptyState) {
            return true;
          }
          if (current is LoadedState && previous is LoadedState) {
            if (current.isFromCache == true && previous.data == current.data) {
              return false;
            }
          }
          return true;
        },
        listener: (context, state) {
          // ── Error ────────────────────────────────────────────────────────
          if (state.isError) {
            final msg = state.errorMessage ?? 'An unexpected error occurred.';
            _logErrorDetails(msg);

            if (onError != null) {
              // Instance-level handler takes full priority.
              onError!(context, state);
            } else if (theme.onError != null) {
              // Theme-level handler — fires for all BlocManagers in the tree.
              theme.onError!(context, msg);
            } else if (effectiveShowErrors) {
              // Built-in fallback snackbar.
              _showSnackbar(context, msg, errorSnackbarColor);
            }
          }

          // ── Success ──────────────────────────────────────────────────────
          if (state.isSuccess) {
            final msg = state.successMessage;
            BlocManagerLogger.logSuccess(msg ?? 'Success', tag: 'BlocManager');

            if (onSuccess != null) {
              onSuccess!(context, state);
            } else if (theme.onSuccess != null) {
              theme.onSuccess!(context, msg);
            } else if (effectiveShowSuccess && msg != null) {
              _showSnackbar(context, msg, successSnackbarColor);
            }
          }

          // ── Loaded ───────────────────────────────────────────────────────
          if (state is LoadedState) {
            final msg = state.successMessage;
            BlocManagerLogger.logSuccess(
              '${bloc.runtimeType} data loaded',
              tag: 'BlocManager',
            );

            if (onSuccess != null) {
              onSuccess!(context, state);
            } else if (theme.onSuccess != null) {
              theme.onSuccess!(context, msg);
            } else if (effectiveShowSuccess && msg != null) {
              _showSnackbar(context, msg, successSnackbarColor);
            }
          }

          // ── Custom listener ───────────────────────────────────────────────
          listener?.call(context, state);
        },
        builder: (context, state) {
          final content = builder != null ? builder!(context, state) : child;

          Widget result = content;

          if (enablePullToRefresh && onRefresh != null) {
            result = RefreshIndicator(onRefresh: onRefresh!, child: content);
          }

          if (showLoadingIndicator && state.isLoading) {
            final overlayColor = effectiveLoadingColor ??
                Theme.of(context).primaryColor.withValues(alpha: 0.5);
            return LoadingOverlay(
              isLoading: true,
              color: overlayColor,
              progressIndicator: effectiveLoadingWidget ??
                  const SpinKitCircle(color: Colors.white, size: 50.0),
              child: result,
            );
          }

          return result;
        },
      ),
    );
  }

  static void _showSnackbar(
    BuildContext context,
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  /// Logs errors with extra context for well-known Firebase/Firestore patterns.
  static void _logErrorDetails(String message) {
    BlocManagerLogger.logError(message, tag: 'BlocManager');
    final lower = message.toLowerCase();

    if (lower.contains('index') ||
        lower.contains('composite') ||
        lower.contains('requires an index')) {
      BlocManagerLogger.logError(
        '🔍 Firestore index missing — visit Firebase Console > Firestore > Indexes',
        tag: 'BlocManager',
      );
    } else if (lower.contains('permission') ||
        lower.contains('permission-denied')) {
      BlocManagerLogger.logError(
        '🔒 Firestore permission denied — check your security rules',
        tag: 'BlocManager',
      );
    } else if (lower.contains('not-found') || lower.contains('not found')) {
      BlocManagerLogger.logError(
        '📄 Firestore document not found',
        tag: 'BlocManager',
      );
    }
  }
}
