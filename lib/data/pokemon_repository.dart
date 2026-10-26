// data/pokemon_repository.dart
import 'package:http/http.dart' as http;
import 'package:pokeclase20263/models/pokemon_detail_response.dart';

class PokemonRepository {
  final http.Client _client;
  final Map<int, PokemonDetailResponse> _cache = {};

  PokemonRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<PokemonDetailResponse> getPokemon(int id) async {
    if (_cache.containsKey(id)) return _cache[id]!;

    final uri = Uri.https('pokeapi.co', '/api/v2/pokemon/$id');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al cargar el Pokémon $id');
    }

    final pokemon = PokemonDetailResponse.fromRawJson(res.body);
    _cache[id] = pokemon;
    return pokemon;
  }
}