import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_manager/bloc_manager.dart';
import 'package:bloc_manager_example/cubits/pokemon/pokemon_cubit.dart';
import 'package:bloc_manager_example/widgets/pokemon_card.dart';

/// Pokemon Screen demonstrates CacheableBlocMixin.
/// Shows Pokemon data with in-memory caching and TTL.
class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PokemonCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon (Caching)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Load from cache',
            onPressed: () => cubit.loadFromCache(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear cache',
            onPressed: () => cubit.clearCacheData(),
          ),
        ],
      ),
      body: BlocManager<PokemonCubit, BaseState<dynamic>>(
        bloc: cubit,
        showLoadingIndicator: false,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Enter Pokemon name or ID (e.g., pikachu, 25)',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () =>
                              cubit.searchPokemon(_searchController.text),
                        ),
                      ),
                      onSubmitted: (value) => cubit.searchPokemon(value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () =>
                        cubit.searchPokemon(_searchController.text),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: BlocBuilder<PokemonCubit, BaseState<dynamic>>(
                builder: (context, state) {
                  if (state is InitialState) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cached, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Search for a Pokemon to get started!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is LoadingState) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Searching...'),
                        ],
                      ),
                    );
                  }

                  if (state is EmptyState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline,
                              size: 64, color: Colors.blue),
                          const SizedBox(height: 16),
                          Text(
                            state.message ?? 'No data',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              state.errorMessage ?? 'An error occurred',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is LoadedState) {
                    final pokemon = state.data;
                    return PokemonCard(
                      pokemon: pokemon,
                      isFromCache: state.isFromCache,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
