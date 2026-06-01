import 'package:flutter/material.dart';

import '../widgets/skeleton_config.dart';
import 'loading_config.dart';

/// Global defaults for every [BlocManager] in the widget tree.
///
/// Place this once at the root of your app to enforce consistent branding
/// across all loading overlays, error messages, and success messages:
///
/// ```dart
/// BlocManagerTheme(
///   data: BlocManagerThemeData(
///     loadingConfig: const BottomSheetLoadingConfig(
///       overlayColor: Colors.black54,
///     ),
///     onError: (context, message) => MyToast.error(context, message),
///     onSuccess: (context, message) => MyToast.success(context, message),
///   ),
///   child: MaterialApp(...),
/// )
/// ```
///
/// Any parameter explicitly passed to a [BlocManager] instance overrides the
/// theme value for that instance only.
class BlocManagerTheme extends InheritedWidget {
  const BlocManagerTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final BlocManagerThemeData data;

  /// Returns the nearest [BlocManagerThemeData] in the tree, or
  /// [BlocManagerThemeData.defaults] if no theme is present.
  static BlocManagerThemeData of(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<BlocManagerTheme>();
    return theme?.data ?? const BlocManagerThemeData();
  }

  @override
  bool updateShouldNotify(BlocManagerTheme oldWidget) => data != oldWidget.data;
}

/// Configuration data carried by [BlocManagerTheme].
///
/// All fields are optional — unset fields fall back to the [BlocManager]
/// built-in defaults.
class BlocManagerThemeData {
  /// Default loading indicator configuration applied to all [BlocManager]
  /// instances that do not provide their own [BlocManager.loadingConfig].
  ///
  /// When null, individual [BlocManager] instances default to
  /// [FullScreenLoadingConfig].
  final LoadingConfig? loadingConfig;

  // ── Skeleton loading ──────────────────────────────────────────────────────

  /// Default [SkeletonConfig] applied to all [BlocManager] instances in the
  /// tree that do not provide their own.
  final SkeletonConfig? skeletonConfig;

  /// Default shimmer base colour for skeleton loading.
  /// Falls back to `Colors.grey[300]` when null.
  final Color? skeletonBaseColor;

  /// Default shimmer highlight colour for skeleton loading.
  /// Falls back to `Colors.grey[100]` when null.
  final Color? skeletonHighlightColor;

  /// Called when any [ErrorState] is received.
  /// Receives the [BuildContext] and the error message string.
  /// When set, replaces the default red snackbar globally.
  /// Set [showResultErrorNotifications] to `false` on individual
  /// [BlocManager] instances if you want to suppress it per-screen.
  final void Function(BuildContext context, String message)? onError;

  /// Called when any [SuccessState] or [LoadedState] is received.
  /// Receives the [BuildContext] and the success message string (may be null).
  final void Function(BuildContext context, String? message)? onSuccess;

  /// Whether to show error notifications globally. Default: `true`.
  final bool showResultErrorNotifications;

  /// Whether to show success notifications globally. Default: `false`.
  final bool showResultSuccessNotifications;

  const BlocManagerThemeData({
    this.loadingConfig,
    this.skeletonConfig,
    this.skeletonBaseColor,
    this.skeletonHighlightColor,
    this.onError,
    this.onSuccess,
    this.showResultErrorNotifications = true,
    this.showResultSuccessNotifications = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlocManagerThemeData &&
          runtimeType == other.runtimeType &&
          loadingConfig == other.loadingConfig &&
          skeletonConfig == other.skeletonConfig &&
          skeletonBaseColor == other.skeletonBaseColor &&
          skeletonHighlightColor == other.skeletonHighlightColor &&
          onError == other.onError &&
          onSuccess == other.onSuccess &&
          showResultErrorNotifications == other.showResultErrorNotifications &&
          showResultSuccessNotifications == other.showResultSuccessNotifications;

  @override
  int get hashCode => Object.hash(
        loadingConfig,
        skeletonConfig,
        skeletonBaseColor,
        skeletonHighlightColor,
        onError,
        onSuccess,
        showResultErrorNotifications,
        showResultSuccessNotifications,
      );
}
