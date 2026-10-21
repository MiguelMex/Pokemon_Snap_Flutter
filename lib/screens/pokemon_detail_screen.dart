import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pokeclase20263/models/pokemon_detail_response.dart';
import 'package:pokeclase20263/providers/poke_api_provider.dart';
import 'package:provider/provider.dart';

class PokemonDetailScreen extends StatefulWidget {
  final int pokemonId;
  final String pokemonName;

  const PokemonDetailScreen({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playCry(String? cryUrl) async {
    if (cryUrl == null) return;
    try {
      await _audioPlayer.play(UrlSource(cryUrl));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo reproducir el grito: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.pokemonName[0].toUpperCase() + widget.pokemonName.substring(1),
        ),
      ),
      body: FutureBuilder(
        future: Provider.of<PokeApiProvider>(context, listen: false)
            .getPokemonDetail(widget.pokemonId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final pokemon = PokemonDetailResponse.fromRawJson(snapshot.data!.body);
            return _PokemonDetailBody(
              pokemon: pokemon,
              colorScheme: colorScheme,
              onPlayCry: () => _playCry(pokemon.cryUrl),
            );
          }
        },
      ),
    );
  }
}

class _PokemonDetailBody extends StatelessWidget {
  final PokemonDetailResponse pokemon;
  final ColorScheme colorScheme;
  final VoidCallback onPlayCry;

  const _PokemonDetailBody({
    required this.pokemon,
    required this.colorScheme,
    required this.onPlayCry,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '#${pokemon.id.toString().padLeft(3, '0')}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: pokemon.imageUrl.isEmpty
                ? Icon(Icons.catching_pokemon, size: 100, color: colorScheme.secondary)
                : Image.network(
                    pokemon.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.catching_pokemon,
                      size: 100,
                      color: colorScheme.secondary,
                    ),
                  ),
          ),
          const SizedBox(height: 8),

          // Botón para el grito (audio)
          if (pokemon.cryUrl != null)
            ElevatedButton.icon(
              onPressed: onPlayCry,
              icon: const Icon(Icons.volume_up),
              label: const Text('Escuchar grito'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
            ),
          const SizedBox(height: 16),

          // Tipos
          Wrap(
            spacing: 8,
            children: pokemon.types.map((t) {
              return Chip(
                label: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                backgroundColor: colorScheme.primary,
                labelStyle: TextStyle(color: colorScheme.onPrimary),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Altura y peso (la API los da en decímetros / hectogramos)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoColumn(label: 'Altura', value: '${pokemon.height / 10} m'),
              _InfoColumn(label: 'Peso', value: '${pokemon.weight / 10} kg'),
            ],
          ),
          const SizedBox(height: 20),

          // Stats
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Estadísticas base',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...pokemon.stats.map((s) => _StatBar(
                name: s.name,
                value: s.baseStat,
                colorScheme: colorScheme,
              )),
          const SizedBox(height: 20),

          // Habilidades
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Habilidades',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: pokemon.abilities.map((a) {
              return Chip(
                label: Text(
                  a.name + (a.isHidden ? ' (oculta)' : ''),
                ),
                backgroundColor: colorScheme.onPrimary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatBar extends StatelessWidget {
  final String name;
  final int value;
  final ColorScheme colorScheme;

  const _StatBar({
    required this.name,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(name, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (value / 150).clamp(0, 1).toDouble(),
                minHeight: 8,
                backgroundColor: colorScheme.onPrimary,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text('$value', style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}