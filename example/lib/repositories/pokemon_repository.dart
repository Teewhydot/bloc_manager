import 'package:bloc_manager_example/models/pokemon.dart';
import 'api_client.dart';

/// Repository for fetching Pokemon from PokeAPI
class PokemonRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  PokemonRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch a Pokemon by name or ID
  Future<Pokemon> fetchPokemon(String query) async {
    final response = await _apiClient.get(
      '$_baseUrl/pokemon/$query',
    );

    return Pokemon.fromJson(response.data as Map<String, dynamic>);
  }
}
