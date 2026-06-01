import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../base/base_state.dart';
import '../utils/logger.dart';
import '../widgets/skeleton_config.dart';
import '../widgets/skeleton_widget.dart';
import 'bloc_manager_theme.dart';
import 'bottom_sheet_loading_wrapper.dart';
import 'frosted_glass_loading_wrapper.dart';
import 'loading_config.dart';
import 'top_progress_bar_loading_wrapper.dart';

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
///
/// ## With loading config
/// ```dart
/// BlocManager<MyCubit, BaseState<MyData>>(
///   bloc: context.read<MyCubit>(),
///   loadingConfig: const BottomSheetLoadingConfig(
///     overlayColor: Colors.transparent,
///     trailingWidget: Icon(Icons.check_circle, color: Colors.green),
///   ),
///   child: MyScreen(),
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

  /// Show a loading indicator during [LoadingState]. Default: true.
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

  /// Configuration for the loading indicator style and appearance.
  ///
  /// Pass a typed config class to choose the style and its parameters:
  ///
  /// ```dart
  /// // Full-screen overlay (default)
  /// loadingConfig: const FullScreenLoadingConfig(),
  ///
  /// // Bottom sheet anchored at the screen bottom
  /// loadingConfig: const BottomSheetLoadingConfig(
  ///   overlayColor: Colors.transparent,
  ///   trailingWidget: Icon(Icons.check_circle),
  /// ),
  ///
  /// // Thin top progress bar (YouTube-style)
  /// loadingConfig: const TopProgressBarLoadingConfig(),
  ///
  /// // Blurred glass overlay
  /// loadingConfig: FrostedGlassLoadingConfig(sigmaX: 8.0),
  /// ```
  ///
  /// `null` (default) inherits from [BlocManagerTheme], then falls back to
  /// [FullScreenLoadingConfig].
  final LoadingConfig? loadingConfig;

  // ── Skeleton loading ──────────────────────────────────────────────────────

  /// Configuration for skeletal loading placeholders shown during
  /// [LoadingState] and [InitialState].
  ///
  /// When set, skeleton widgets replace the content area while the bloc is
  /// loading, giving users a visual preview of the layout. The existing loading
  /// indicator still works alongside if [showLoadingIndicator] is enabled.
  ///
  /// `null` (default) inherits from [BlocManagerTheme].
  final SkeletonConfig? skeletonConfig;

  /// Shimmer base colour for skeleton loading.
  /// `null` inherits from [BlocManagerTheme], then falls back to `Colors.grey[300]`.
  final Color? skeletonBaseColor;

  /// Shimmer highlight colour for skeleton loading.
  /// `null` inherits from [BlocManagerTheme], then falls back to `Colors.grey[100]`.
  final Color? skeletonHighlightColor;

  // ── Snackbar colours ───────────────────────────────────────────────────────

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
    this.showResultErrorNotifications, // null = inherit from theme
    this.showResultSuccessNotifications, // null = inherit from theme
    this.enablePullToRefresh = false,
    this.onRefresh,
    this.loadingConfig, // null = inherit from theme
    this.skeletonConfig, // null = inherit from theme
    this.skeletonBaseColor, // null = inherit from theme
    this.skeletonHighlightColor, // null = inherit from theme
    this.errorSnackbarColor = const Color(0xFFB00020),
    this.successSnackbarColor = const Color(0xFF388E3C),
  });

  @override
  Widget build(BuildContext context) {
    final theme = BlocManagerTheme.of(context);

    // Resolve effective values: instance → theme → built-in default
    final effectiveLoadingConfig =
        loadingConfig ?? theme.loadingConfig ?? const FullScreenLoadingConfig();
    final effectiveShowErrors =
        showResultErrorNotifications ?? theme.showResultErrorNotifications;
    final effectiveShowSuccess =
        showResultSuccessNotifications ?? theme.showResultSuccessNotifications;
    final effectiveSkeletonConfig =
        skeletonConfig ?? theme.skeletonConfig;
    final effectiveSkeletonBaseColor =
        skeletonBaseColor ?? theme.skeletonBaseColor;
    final effectiveSkeletonHighlightColor =
        skeletonHighlightColor ?? theme.skeletonHighlightColor;

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
          // ── Show skeleton placeholders during loading states ───────────
          final showSkeletons = effectiveSkeletonConfig != null &&
              (state.isLoading || state.isInitial);

          Widget content;
          if (showSkeletons) {
            content = SkeletonListWidget(
              config: effectiveSkeletonConfig,
              resolvedBaseColor: effectiveSkeletonBaseColor,
              resolvedHighlightColor: effectiveSkeletonHighlightColor,
            );
          } else {
            content = builder != null ? builder!(context, state) : child;
          }

          Widget result = content;

          if (enablePullToRefresh && onRefresh != null) {
            result = RefreshIndicator(onRefresh: onRefresh!, child: content);
          }

          if (!showLoadingIndicator) {
            return result;
          }

          // Resolve loading style from the config
          return _buildLoadingWrapper(context, effectiveLoadingConfig, state, result);
        },
      ),
    );
  }

  /// Builds the appropriate loading wrapper based on the [LoadingConfig] type.
  Widget _buildLoadingWrapper(
    BuildContext context,
    LoadingConfig config,
    S state,
    Widget child,
  ) {
    return switch (config) {
      BottomSheetLoadingConfig _ => _buildBottomSheet(context, config, state, child),
      TopProgressBarLoadingConfig _ => _buildTopProgressBar(context, config, state, child),
      FrostedGlassLoadingConfig _ => _buildFrostedGlass(context, config, state, child),
      FullScreenLoadingConfig _ => _buildFullScreen(context, config, state, child),
    };
  }

  Widget _buildFullScreen(
    BuildContext context,
    FullScreenLoadingConfig config,
    S state,
    Widget child,
  ) {
    final overlayColor = config.overlayColor ??
        Theme.of(context).primaryColor.withValues(alpha: 0.5);
    final loadingWidget = config.loadingWidget ??
        const SpinKitCircle(color: Colors.white, size: 50.0);

    return LoadingOverlay(
      isLoading: state.isLoading,
      color: overlayColor,
      progressIndicator: loadingWidget,
      child: child,
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    BottomSheetLoadingConfig config,
    S state,
    Widget child,
  ) {
    final overlayColor = config.overlayColor ??
        Theme.of(context).primaryColor.withValues(alpha: 0.5);
    final loadingWidget = config.loadingWidget ??
        BlocBottomSheetWidget(trailingWidget: config.trailingWidget);

    return BottomSheetLoadingWrapper(
      isLoading: state.isLoading,
      overlayColor: overlayColor,
      loadingWidget: loadingWidget,
      child: child,
    );
  }

  Widget _buildTopProgressBar(
    BuildContext context,
    TopProgressBarLoadingConfig config,
    S state,
    Widget child,
  ) {
    final progressColor =
        config.progressColor ?? Theme.of(context).colorScheme.primary;

    return TopProgressBarLoadingWrapper(
      isLoading: state.isLoading,
      progressColor: progressColor,
      child: child,
    );
  }

  Widget _buildFrostedGlass(
    BuildContext context,
    FrostedGlassLoadingConfig config,
    S state,
    Widget child,
  ) {
    final overlayColor =
        config.overlayColor ?? const Color(0x26FFFFFF); // white at ~15%
    final loadingWidget = config.loadingWidget ??
        const SpinKitCircle(color: Colors.white, size: 50.0);

    return FrostedGlassLoadingWrapper(
      isLoading: state.isLoading,
      overlayColor: overlayColor,
      loadingWidget: loadingWidget,
      sigmaX: config.sigmaX,
      sigmaY: config.sigmaY,
      child: child,
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

class BlocBottomSheetWidget extends StatelessWidget {
  final Widget? trailingWidget;
  const BlocBottomSheetWidget({super.key, this.trailingWidget});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator.adaptive(strokeWidth: 3),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailingWidget != null) trailingWidget!,
          ],
        ),
      ),
    );
  }
}
