import 'package:equatable/equatable.dart';

/// Pokemon model from PokeAPI
/// https://pokeapi.co/api/v2/pokemon/{id or name}
class Pokemon extends Equatable {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<PokemonType> types;
  final List<PokemonStat> stats;
  final PokemonSprites sprites;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
    required this.sprites,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: (json['types'] as List)
          .map((e) => PokemonType.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: (json['stats'] as List)
          .map((e) => PokemonStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      sprites: PokemonSprites.fromJson(json['sprites'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'weight': weight,
      'types': types.map((e) => e.toJson()).toList(),
      'stats': stats.map((e) => e.toJson()).toList(),
      'sprites': sprites.toJson(),
    };
  }

  String get imageUrl => sprites.frontDefault ?? '';
  String get typesFormatted => types.map((t) => t.type.name).join(', ');
  String get displayName => name[0].toUpperCase() + name.substring(1);

  @override
  List<Object?> get props => [id, name, height, weight, types, stats, sprites];
}

class PokemonType extends Equatable {
  final int slot;
  final TypeInfo type;

  const PokemonType({
    required this.slot,
    required this.type,
  });

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(
      slot: json['slot'] as int,
      type: TypeInfo.fromJson(json['type'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slot': slot,
      'type': type.toJson(),
    };
  }

  @override
  List<Object?> get props => [slot, type];
}

class TypeInfo extends Equatable {
  final String name;
  final String url;

  const TypeInfo({
    required this.name,
    required this.url,
  });

  factory TypeInfo.fromJson(Map<String, dynamic> json) {
    return TypeInfo(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }

  @override
  List<Object?> get props => [name, url];
}

class PokemonStat extends Equatable {
  final int baseStat;
  final int effort;
  final StatInfo stat;

  const PokemonStat({
    required this.baseStat,
    required this.effort,
    required this.stat,
  });

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      baseStat: json['base_stat'] as int,
      effort: json['effort'] as int,
      stat: StatInfo.fromJson(json['stat'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_stat': baseStat,
      'effort': effort,
      'stat': stat.toJson(),
    };
  }

  @override
  List<Object?> get props => [baseStat, effort, stat];
}

class StatInfo extends Equatable {
  final String name;
  final String url;

  const StatInfo({
    required this.name,
    required this.url,
  });

  factory StatInfo.fromJson(Map<String, dynamic> json) {
    return StatInfo(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }

  @override
  List<Object?> get props => [name, url];
}

class PokemonSprites extends Equatable {
  final String? frontDefault;
  final String? frontShiny;
  final String? backDefault;
  final String? backShiny;

  const PokemonSprites({
    this.frontDefault,
    this.frontShiny,
    this.backDefault,
    this.backShiny,
  });

  factory PokemonSprites.fromJson(Map<String, dynamic> json) {
    return PokemonSprites(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
      backDefault: json['back_default'] as String?,
      backShiny: json['back_shiny'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'front_default': frontDefault,
      'front_shiny': frontShiny,
      'back_default': backDefault,
      'back_shiny': backShiny,
    };
  }

  @override
  List<Object?> get props => [frontDefault, frontShiny, backDefault, backShiny];
}
