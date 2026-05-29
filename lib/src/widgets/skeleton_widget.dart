import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'skeleton_config.dart';

/// Renders a set of skeleton placeholder widgets arranged according to the
/// provided [SkeletonConfig], optionally wrapped in a shimmer animation.
///
/// This widget is used internally by [BlocManager] when [skeletonConfig] is
/// provided and the state is [LoadingState] or [InitialState].
class SkeletonListWidget extends StatelessWidget {
  final SkeletonConfig config;
  final Color? resolvedBaseColor;
  final Color? resolvedHighlightColor;

  const SkeletonListWidget({
    super.key,
    required this.config,
    this.resolvedBaseColor,
    this.resolvedHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      config.count,
      (index) => config.builder(context, index),
    );

    Widget layout = _buildLayout(context, items);

    // Optionally wrap in shimmer
    if (config.enableShimmer) {
      final baseColor = resolvedBaseColor ?? Colors.grey[300]!;
      final highlightColor = resolvedHighlightColor ?? Colors.grey[100]!;
      layout = Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: layout,
      );
    }

    return layout;
  }

  /// Builds the skeleton layout using non-scrollable widgets so skeletons
  /// can be safely nested inside any parent layout (e.g. inside a
  /// [SingleChildScrollView] or [CustomScrollView]).
  Widget _buildLayout(BuildContext context, List<Widget> items) {
    switch (config.orientation) {
      case SkeletonOrientation.list:
        return Padding(
          padding: EdgeInsets.all(config.spacing),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  SizedBox(height: config.spacing),
              ],
            ],
          ),
        );

      case SkeletonOrientation.grid:
        final crossAxisCount = config.crossAxisCount ?? 2;
        // Use LayoutBuilder to calculate a fixed width per item so that
        // skeleton widgets with internal Expanded children receive proper
        // bounded constraints (unlike Row+Expanded which passes unbounded
        // height up the layout chain).
        return LayoutBuilder(
          builder: (context, constraints) {
            final availWidth = constraints.maxWidth - config.spacing * 2;
            final totalGaps = config.spacing * (crossAxisCount - 1);
            final itemWidth =
                ((availWidth - totalGaps) / crossAxisCount).clamp(1.0, double.infinity);

            final rows = <Widget>[];
            for (int i = 0; i < items.length; i += crossAxisCount) {
              final end = (i + crossAxisCount).clamp(0, items.length);
              final rowItems = items.sublist(i, end);
              rows.add(
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i + crossAxisCount < items.length
                        ? config.spacing
                        : 0,
                  ),
                  child: Row(
                    children: rowItems.map((item) {
                      final idx = rowItems.indexOf(item);
                      return Padding(
                        padding: EdgeInsets.only(
                          left: idx == 0 ? 0 : config.spacing / 2,
                          right: idx == rowItems.length - 1
                              ? 0
                              : config.spacing / 2,
                        ),
                        child: SizedBox(
                          width: itemWidth,
                          child: AspectRatio(
                            // Provide bounded height so skeleton widgets
                            // with internal Expanded children work.
                            aspectRatio: 1.0,
                            child: item,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.all(config.spacing),
              child: Column(children: rows),
            );
          },
        );

      case SkeletonOrientation.row:
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(config.spacing),
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  SizedBox(width: config.spacing),
              ],
            ],
          ),
        );

      case SkeletonOrientation.wrap:
        return Padding(
          padding: EdgeInsets.all(config.spacing),
          child: Wrap(
            spacing: config.spacing,
            runSpacing: config.spacing,
            children: items,
          ),
        );
    }
  }
}
