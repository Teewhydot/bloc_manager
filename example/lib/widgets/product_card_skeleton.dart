import 'package:flutter/material.dart';

/// Skeleton placeholder for a product grid card, matching the layout used in
/// [ProductsScreen] — a [Card] with an image area at the top, followed by
/// title, price, and category text lines.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFF424242)),
            ),
          ),
          // Text area
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title line
                const SizedBox(
                  height: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF424242),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                SizedBox(height: 6),
                // Title line 2
                const SizedBox(
                  height: 12,
                  width: 80,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF424242),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Price line
                const SizedBox(
                  height: 14,
                  width: 60,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF424242),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                // Category line
                const SizedBox(
                  height: 10,
                  width: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF424242),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
