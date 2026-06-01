import 'package:flutter/material.dart';

/// Skeleton placeholder for a Pokemon detail card, matching the layout in
/// [PokemonCard] — image area, name/ID, type chips, stats card with progress
/// bars, and height/weight info cards.
class PokemonCardSkeleton extends StatelessWidget {
  const PokemonCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Pokemon image area
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          // Pokemon name
          Container(
            height: 28,
            width: 160,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          // Pokemon ID
          Container(
            height: 20,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Types row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _typeChip(),
              const SizedBox(width: 8),
              _typeChip(),
            ],
          ),
          const SizedBox(height: 24),
          // Stats card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats title
                  Container(
                    height: 20,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stat bars
                  ...List.generate(
                    6,
                    (_) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // Stat label
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 12,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          // Stat value
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 14,
                              width: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          // Stat bar
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Height & Weight info cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoCard(),
              _infoCard(),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _typeChip() {
    return Container(
      height: 32,
      width: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF424242),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }

  static Widget _infoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF424242),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 18,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
