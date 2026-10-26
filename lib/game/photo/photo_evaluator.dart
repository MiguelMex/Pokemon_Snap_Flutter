import 'dart:math';
import 'dart:ui';

import '../components/pokemon_actor.dart';
import '../config/game_config.dart';
import 'photo_result.dart';

/// Calcula el puntaje de una foto. Pura matematica de rectangulos:
/// no depende de Flame, asi que es facil de probar con tests.
///
/// Es una primera version. Pendiente para el rol de "mecanica de foto":
/// bonus por pose/accion, por rareza (PokeAPI capture_rate), por no repetir...
class PhotoEvaluator {
  PhotoEvaluator._();

  static PhotoResult evaluate({
    required Rect frame,
    required Iterable<PokemonActor> actors,
  }) {
    final subjects = <PhotoSubject>[];

    for (final actor in actors) {
      final rect = actor.hitRect;
      if (!frame.overlaps(rect)) continue;

      final inter = frame.intersect(rect);
      final area = rect.width * rect.height;
      if (area <= 0) continue;

      final visible = (inter.width * inter.height) / area;
      if (visible < GameConfig.minVisibleFraction) continue;

      final halfDiag = frame.size.longestSide / 2;
      final dist = (rect.center - frame.center).distance;
      final centering = (1 - dist / halfDiag).clamp(0.0, 1.0).toDouble();

      final ratio = rect.height / frame.height;
      final sizeFactor = min(1.0, ratio / 0.7);

      final score = (100 * (0.45 * centering + 0.35 * sizeFactor + 0.20 * visible)).round();

      subjects.add(PhotoSubject(
        actor: actor,
        visibleFraction: visible,
        centering: centering,
        sizeFactor: sizeFactor,
        score: score,
      ));
    }

    final bonus = subjects.length >= 2 ? 25 * (subjects.length - 1) : 0;
    return PhotoResult(subjects: subjects, bonus: bonus);
  }
}
