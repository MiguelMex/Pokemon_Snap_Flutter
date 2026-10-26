import 'package:flutter/material.dart';

import '../snap_game.dart';

/// Pantalla de fin de sesion: puntaje total y mejor foto de cada Pokemon.
class ResultsOverlay extends StatelessWidget {
  const ResultsOverlay({
    super.key,
    required this.game,
    required this.onRestart,
    required this.onExit,
  });

  final SnapGame game;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    // Mejor puntaje por especie
    final best = <String, int>{};
    for (final photo in game.album) {
      for (final s in photo.subjects) {
        final name = s.actor.def.name;
        if (s.score > (best[name] ?? 0)) best[name] = s.score;
      }
    }
    final entries = best.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      alignment: Alignment.center,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sesion terminada', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Puntaje total: ${game.totalScore.value}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(child: Text('No lograste fotografiar ningun Pokemon'))
                      : ListView(
                          children: [
                            for (final e in entries)
                              ListTile(
                                dense: true,
                                title: Text(e.key),
                                trailing: Text('${e.value} pts'),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(onPressed: onExit, child: const Text('Menu')),
                    FilledButton(onPressed: onRestart, child: const Text('Jugar de nuevo')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
