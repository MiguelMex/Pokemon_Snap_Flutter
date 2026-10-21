import 'dart:convert';

class PokemonDetailResponse {
  final int id;
  final String name;
  final int height; // en decímetros (así lo da la API)
  final int weight; // en hectogramos (así lo da la API)
  final String imageUrl;
  final List<PokemonTypeSlot> types;
  final List<PokemonStat> stats;
  final List<PokemonAbility> abilities;
  final String? cryUrl;

  PokemonDetailResponse({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.imageUrl,
    required this.types,
    required this.stats,
    required this.abilities,
    this.cryUrl,
  });

  factory PokemonDetailResponse.fromRawJson(String str) =>
      PokemonDetailResponse.fromJson(json.decode(str));

  factory PokemonDetailResponse.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] ?? {};
    final officialArtwork = sprites['other']?['official-artwork']?['front_default'];

    return PokemonDetailResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      imageUrl: officialArtwork ?? sprites['front_default'] ?? '',
      types: (json['types'] as List? ?? [])
          .map((t) => PokemonTypeSlot.fromJson(t))
          .toList(),
      stats: (json['stats'] as List? ?? [])
          .map((s) => PokemonStat.fromJson(s))
          .toList(),
      abilities: (json['abilities'] as List? ?? [])
          .map((a) => PokemonAbility.fromJson(a))
          .toList(),
      cryUrl: json['cries']?['latest'] as String?,
    );
  }
}

class PokemonTypeSlot {
  final int slot;
  final String name;

  PokemonTypeSlot({required this.slot, required this.name});

  factory PokemonTypeSlot.fromJson(Map<String, dynamic> json) {
    return PokemonTypeSlot(
      slot: json['slot'] ?? 0,
      name: json['type']?['name'] ?? '',
    );
  }
}

class PokemonStat {
  final String name;
  final int baseStat;

  PokemonStat({required this.name, required this.baseStat});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']?['name'] ?? '',
      baseStat: json['base_stat'] ?? 0,
    );
  }
}

class PokemonAbility {
  final String name;
  final bool isHidden;

  PokemonAbility({required this.name, required this.isHidden});

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(
      name: json['ability']?['name'] ?? '',
      isHidden: json['is_hidden'] ?? false,
    );
  }
}