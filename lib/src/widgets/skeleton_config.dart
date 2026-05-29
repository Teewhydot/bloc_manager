import 'package:flutter/material.dart';

/// Defines the layout orientation for skeleton loading items.
enum SkeletonOrientation {
  /// Vertical scrollable list — renders items in a [ListView.builder].
  list,

  /// Grid layout — renders items in a [GridView.builder] with the specified
  /// [SkeletonConfig.crossAxisCount].
  grid,

  /// Horizontal scrollable row — renders items in a horizontal [ListView].
  row,

  /// Wrap layout — renders items in a [Wrap] widget that flows naturally
  /// to the next line when space runs out.
  wrap,
}

/// Configuration for skeletal loading placeholders shown during [LoadingState]
/// or [InitialState].
///
/// Provide a [builder] that returns a skeleton placeholder widget, a [count]
/// for how many items to show, and an [orientation] for the layout.
///
/// The skeletons are automatically wrapped in a shimmer animation (via the
/// `shimmer` package) when [enableShimmer] is `true`.
///
/// ## Basic usage
/// ```dart
/// BlocManager<MyCubit, BaseState<List<Item>>>(
///   bloc: cubit,
///   skeletonConfig: SkeletonConfig(
///     builder: (context, index) => const SkeletonCard(),
///     count: 6,
///     orientation: SkeletonOrientation.list,
///   ),
///   child: MyScreen(),
/// )
/// ```
///
/// ## Grid layout
/// ```dart
/// SkeletonConfig(
///   builder: (context, index) => const SkeletonProductTile(),
///   count: 8,
///   orientation: SkeletonOrientation.grid,
///   crossAxisCount: 2,
///   spacing: 12.0,
/// )
/// ```
class SkeletonConfig {
  /// Builder that returns a skeleton placeholder widget for the given index.
  ///
  /// The widget should ideally use solid, opaque colours (e.g. white or grey)
  /// so the shimmer effect renders properly over it.
  final Widget Function(BuildContext context, int index) builder;

  /// Number of skeleton items to display.
  final int count;

  /// Layout orientation for the skeleton items.
  ///
  /// Defaults to [SkeletonOrientation.list].
  final SkeletonOrientation orientation;

  /// For [SkeletonOrientation.grid], the number of columns.
  ///
  /// Ignored for other orientations.
  final int? crossAxisCount;

  /// Spacing between skeleton items.
  ///
  /// Used as `mainAxisSpacing` / `crossAxisSpacing` for grids, and
  /// spacing between items for list/row/wrap layouts.
  ///
  /// Defaults to `8.0`.
  final double spacing;

  /// Base (darker) colour for the shimmer animation.
  ///
  /// `null` inherits from [BlocManagerTheme] or falls back to `Colors.grey[300]`.
  final Color? baseColor;

  /// Highlight (lighter) colour for the shimmer animation.
  ///
  /// `null` inherits from [BlocManagerTheme] or falls back to `Colors.grey[100]`.
  final Color? highlightColor;

  /// Whether to wrap the skeletons with a shimmer animation effect.
  ///
  /// Defaults to `true`. Set to `false` if you want static skeleton
  /// placeholders without animation.
  final bool enableShimmer;

  const SkeletonConfig({
    required this.builder,
    required this.count,
    this.orientation = SkeletonOrientation.list,
    this.crossAxisCount,
    this.spacing = 8.0,
    this.baseColor,
    this.highlightColor,
    this.enableShimmer = true,
  });
}
