import 'package:flutter/material.dart';
import 'package:bloc_manager_example/models/pokemon.dart';

/// Widget to display Pokemon data with cache indicator
class PokemonCard extends StatelessWidget {
  final Pokemon? pokemon;
  final bool isFromCache;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.isFromCache,
  });

  @override
  Widget build(BuildContext context) {
    if (pokemon == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cache indicator
          if (isFromCache)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cached, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'From Cache',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Pokemon image
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.network(
              pokemon!.imageUrl,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                alignment: Alignment.center,
                child: const Icon(Icons.error, size: 64, color: Colors.grey),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Pokemon name
          Text(
            pokemon!.displayName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          // Pokemon ID
          Text(
            '#${pokemon!.id.toString().padLeft(3, '0')}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 16),
          // Types
          Wrap(
            spacing: 8,
            children: pokemon!.types
                .map((type) => Chip(
                      label: Text(type.type.name.toUpperCase()),
                      backgroundColor: _getTypeColor(type.type.name),
                      labelStyle: const TextStyle(color: Colors.white),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          // Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stats',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...pokemon!.stats.map((stat) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatStatName(stat.stat.name),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                stat.baseStat.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: LinearProgressIndicator(
                                value: stat.baseStat / 255,
                                backgroundColor: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Physical info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoCard(
                label: 'Height',
                value: '${pokemon!.height / 10} m',
                icon: Icons.height,
              ),
              _InfoCard(
                label: 'Weight',
                value: '${pokemon!.weight / 10} kg',
                icon: Icons.monitor_weight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    final typeColors = {
      'normal': const Color(0xFFA8A878),
      'fire': const Color(0xFFF08030),
      'water': const Color(0xFF6890F0),
      'electric': const Color(0xFFF8D030),
      'grass': const Color(0xFF78C850),
      'ice': const Color(0xFF98D8D8),
      'fighting': const Color(0xFFC03028),
      'poison': const Color(0xFFA040A0),
      'ground': const Color(0xFFE0C068),
      'flying': const Color(0xFFA890F0),
      'psychic': const Color(0xFFF85888),
      'bug': const Color(0xFFA8B820),
      'rock': const Color(0xFFB8A038),
      'ghost': const Color(0xFF705898),
      'dragon': const Color(0xFF7038F8),
      'dark': const Color(0xFF705848),
      'steel': const Color(0xFFB8B8D0),
      'fairy': const Color(0xFFEE99AC),
    };
    return typeColors[type.toLowerCase()] ?? const Color(0xFF68A090);
  }

  String _formatStatName(String name) {
    const replacements = {
      'hp': 'HP',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'SP. ATK',
      'special-defense': 'SP. DEF',
      'speed': 'SPD',
    };
    return replacements[name] ?? name.toUpperCase();
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
