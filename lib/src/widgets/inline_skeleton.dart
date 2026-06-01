import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../managers/bloc_manager_theme.dart';

/// Replaces a specific widget with a skeleton placeholder during loading,
/// enabling fine-grained inline skeleton loading instead of replacing the
/// entire screen.
///
/// Use this to selectively show skeleton placeholders for individual
/// components within your UI while keeping the rest of the layout visible
/// and interactive.
///
/// ## Simple usage
/// ```dart
/// InlineSkeleton(
///   isLoading: state.isLoading,
///   skeleton: const SkeletonCard(),
///   child: const RealCard(),
/// )
/// ```
///
/// ## With custom shimmer colours
/// ```dart
/// InlineSkeleton(
///   isLoading: state.isLoading,
///   skeleton: const SkeletonCard(),
///   baseColor: Colors.blue.withOpacity(0.1),
///   highlightColor: Colors.blue.withOpacity(0.3),
///   child: const RealCard(),
/// )
/// ```
///
/// ## Disabling shimmer
/// ```dart
/// InlineSkeleton(
///   isLoading: state.isLoading,
///   skeleton: const SkeletonCard(),
///   enableShimmer: false,
///   child: const RealCard(),
/// )
/// ```
class InlineSkeleton extends StatelessWidget {
  /// Whether the skeleton placeholder should be shown.
  final bool isLoading;

  /// The skeleton placeholder widget shown while [isLoading] is true.
  ///
  /// Should use solid, opaque colours (e.g. white or grey) so the shimmer
  /// effect renders properly over it.
  final Widget skeleton;

  /// The real content widget shown when [isLoading] is false.
  final Widget child;

  /// Base (darker) colour for the shimmer animation.
  ///
  /// `null` inherits from [BlocManagerTheme] or falls back to `Colors.grey[300]`.
  final Color? baseColor;

  /// Highlight (lighter) colour for the shimmer animation.
  ///
  /// `null` inherits from [BlocManagerTheme] or falls back to `Colors.grey[100]`.
  final Color? highlightColor;

  /// Whether to wrap the skeleton with a shimmer animation effect.
  ///
  /// Defaults to `true`. Set to `false` for static placeholders without
  /// animation.
  final bool enableShimmer;

  const InlineSkeleton({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.enableShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    Widget result = skeleton;

    if (enableShimmer) {
      // Resolve colours: instance → BlocManagerTheme → built-in default
      final theme = BlocManagerTheme.of(context);
      final effectiveBaseColor =
          baseColor ?? theme.skeletonBaseColor ?? Colors.grey[300]!;
      final effectiveHighlightColor =
          highlightColor ?? theme.skeletonHighlightColor ?? Colors.grey[100]!;

      result = Shimmer.fromColors(
        baseColor: effectiveBaseColor,
        highlightColor: effectiveHighlightColor,
        child: result,
      );
    }

    return result;
  }
}
