import 'package:flutter/material.dart';

/// Base sealed class for all loading indicator configurations.
///
/// Each subclass carries only the parameters relevant to its style.
/// Pass an instance to [BlocManager.loadingConfig] or
/// [BlocManagerThemeData.loadingConfig].
///
/// ```dart
/// BlocManager(
///   bloc: myCubit,
///   loadingConfig: const FrostedGlassLoadingConfig(sigmaX: 8.0),
///   child: MyScreen(),
/// )
/// ```
sealed class LoadingConfig {
  const LoadingConfig();
}

/// Full-screen loading overlay that obscures the content underneath.
///
/// Uses [LoadingOverlay] under the hood. Shows a centered loading indicator
/// on top of a semi-transparent tint.
class FullScreenLoadingConfig extends LoadingConfig {
  /// Custom loading widget. Defaults to a white [SpinKitCircle] (50px).
  final Widget? loadingWidget;

  /// Tint colour for the overlay. Defaults to the theme primary colour at 50%
  /// opacity. Set to [Colors.transparent] to remove the tint.
  final Color? overlayColor;

  const FullScreenLoadingConfig({
    this.loadingWidget,
    this.overlayColor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FullScreenLoadingConfig &&
          loadingWidget == other.loadingWidget &&
          overlayColor == other.overlayColor;

  @override
  int get hashCode => Object.hash(loadingWidget, overlayColor);
}

/// A slide-up bottom sheet loading indicator anchored to the bottom of the
/// screen. Keeps the existing content visible underneath.
class BottomSheetLoadingConfig extends LoadingConfig {
  /// Custom loading widget shown inside the bottom sheet.
  /// Defaults to [BlocBottomSheetWidget] with optional [trailingWidget].
  final Widget? loadingWidget;

  /// Tint colour for the screen layer behind the bottom sheet.
  /// Defaults to the theme primary colour at 50% opacity.
  /// Set to [Colors.transparent] to remove the tint.
  final Color? overlayColor;

  /// Optional trailing widget displayed on the right side of the default
  /// bottom sheet. Ignored when [loadingWidget] is provided.
  final Widget? trailingWidget;

  const BottomSheetLoadingConfig({
    this.loadingWidget,
    this.overlayColor,
    this.trailingWidget,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BottomSheetLoadingConfig &&
          loadingWidget == other.loadingWidget &&
          overlayColor == other.overlayColor &&
          trailingWidget == other.trailingWidget;

  @override
  int get hashCode => Object.hash(loadingWidget, overlayColor, trailingWidget);
}

/// A thin linear progress bar pinned to the top edge (like YouTube).
/// Non-intrusive — does not obscure the content underneath.
class TopProgressBarLoadingConfig extends LoadingConfig {
  /// Colour of the progress bar. Defaults to the theme's primary colour.
  final Color? progressColor;

  const TopProgressBarLoadingConfig({this.progressColor});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopProgressBarLoadingConfig &&
          progressColor == other.progressColor;

  @override
  int get hashCode => progressColor.hashCode;
}

/// A frosted glass (blurred backdrop) loading overlay.
///
/// Uses [BackdropFilter] with [ImageFilter.blur] to create a glass-like
/// blur effect, combined with a semi-transparent tint and a centered
/// loading indicator.
class FrostedGlassLoadingConfig extends LoadingConfig {
  /// Custom loading widget. Defaults to a white [SpinKitCircle] (50px).
  final Widget? loadingWidget;

  /// Tint colour for the glass overlay.
  /// Defaults to white at ~15% opacity.
  final Color? overlayColor;

  /// Blur sigma on the X axis. Defaults to 12.0.
  final double sigmaX;

  /// Blur sigma on the Y axis. Defaults to 12.0.
  final double sigmaY;

  const FrostedGlassLoadingConfig({
    this.loadingWidget,
    this.overlayColor,
    this.sigmaX = 12.0,
    this.sigmaY = 12.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrostedGlassLoadingConfig &&
          loadingWidget == other.loadingWidget &&
          overlayColor == other.overlayColor &&
          sigmaX == other.sigmaX &&
          sigmaY == other.sigmaY;

  @override
  int get hashCode =>
      Object.hash(loadingWidget, overlayColor, sigmaX, sigmaY);
}
