import 'package:bloc_manager/bloc_manager.dart';
import 'package:bloc_manager_example/models/pokemon.dart';
import 'package:bloc_manager_example/repositories/pokemon_repository.dart';

/// PokemonCubit demonstrates the CacheableBlocMixin feature.
/// It caches Pokemon data in memory with a configurable TTL.
class PokemonCubit extends BaseCubit<BaseState<Pokemon>>
    with CacheableBlocMixin<BaseState<Pokemon>> {
  final PokemonRepository _repository;

  PokemonCubit({PokemonRepository? repository})
      : _repository = repository ?? PokemonRepository(),
        super(const InitialState());

  // Cache configuration - 10 minutes TTL
  @override
  Duration get cacheTimeout => const Duration(minutes: 10);

  @override
  String get cacheKey => 'pokemon_data';

  /// Search for a Pokemon by name or ID
  /// Checks cache first before making API call
  Future<void> searchPokemon(String query) async {
    if (query.trim().isEmpty) {
      emit(const EmptyState<Pokemon>(message: 'Enter a Pokemon name or ID'));
      return;
    }

    final normalizedQuery = query.trim().toLowerCase();

    // Check cache first for this Pokemon
    final hasCached = await hasCachedData();
    if (hasCached) {
      final cachedState = await loadStateFromCache();
      if (cachedState is LoadedState<Pokemon> &&
          cachedState.data != null) {
        final cachedPokemon = cachedState.data!;
        // Check if cached Pokemon matches the search query (by name or ID)
        if (cachedPokemon.name == normalizedQuery ||
            cachedPokemon.id.toString() == normalizedQuery) {
          // Cache hit - emit with isFromCache explicitly set to true
          emit(LoadedState<Pokemon>(
            data: cachedPokemon,
            lastUpdated: cachedState.lastUpdated,
            isFromCache: true,
          ));
          return;
        }
      }
    }

    // Cache miss or different Pokemon - fetch from API
    emit(const LoadingState<Pokemon>(message: 'Searching for Pokemon...'));

    try {
      final pokemon = await _repository.fetchPokemon(normalizedQuery);

      // Save to cache (without isFromCache flag since this is fresh data)
      await saveStateToCache(LoadedState<Pokemon>(
        data: pokemon,
        lastUpdated: DateTime.now(),
      ));

      emit(LoadedState<Pokemon>(
        data: pokemon,
        lastUpdated: DateTime.now(),
        isFromCache: false,
      ));
    } catch (e) {
      emitError('Pokemon not found. Try "pikachu" or "25".', exception: e as Exception?);
    }
  }

  /// Load Pokemon from cache if available
  Future<void> loadFromCache() async {
    final cachedState = await loadStateFromCache();
    if (cachedState != null) {
      emit(cachedState);
    } else {
      emit(const EmptyState<Pokemon>(message: 'No cached Pokemon data. Search for one!'));
    }
  }

  /// Clear the cache
  Future<void> clearCacheData() async {
    await clearCache();
    emit(const EmptyState<Pokemon>(message: 'Cache cleared. Search for a Pokemon!'));
  }

  /// Get the age of the current cache entry
  @override
  Future<Duration?> getCacheAge() async {
    return super.getCacheAge();
  }

  // Cache serialization methods
  @override
  Map<String, dynamic>? stateToJson(BaseState<Pokemon> state) {
    if (state is LoadedState<Pokemon> && state.data != null) {
      return {
        'pokemon': state.data!.toJson(),
        'lastUpdated': state.lastUpdated?.toIso8601String(),
      };
    }
    return null;
  }

  @override
  BaseState<Pokemon>? stateFromJson(Map<String, dynamic> json) {
    try {
      final pokemonJson = json['pokemon'] as Map<String, dynamic>;
      final pokemon = Pokemon.fromJson(pokemonJson);

      return LoadedState<Pokemon>(
        data: pokemon,
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
        isFromCache: true,
      );
    } catch (e) {
      return null;
    }
  }
}
