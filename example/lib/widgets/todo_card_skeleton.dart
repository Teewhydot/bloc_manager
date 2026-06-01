import 'package:flutter/material.dart';

/// Skeleton placeholder for a todo card, matching the layout used in
/// [TodosScreen] — a [Card] with a [ListTile]-like arrangement:
/// leading [Checkbox] placeholder, title lines, subtitle lines
/// (status + ID), and trailing icon button placeholders.
class TodoCardSkeleton extends StatelessWidget {
  const TodoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox placeholder
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(left: 8, right: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF424242),
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
            ),
            // Title & subtitle lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title line 1
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Title line 2
                  Container(
                    height: 14,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtitle — status line
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle — ID line
                  Container(
                    height: 10,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Trailing icon button placeholders
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF424242),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF424242),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of [TodoCardSkeleton] items used as a loading placeholder,
/// wrapped in a shimmer animation.
class TodoSkeletonList extends StatelessWidget {
  const TodoSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: TodoCardSkeleton(),
        ),
      ),
    );
  }
}
