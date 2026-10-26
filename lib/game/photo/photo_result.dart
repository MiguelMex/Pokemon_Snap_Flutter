import '../components/pokemon_actor.dart';

/// Un Pokemon que salio en una foto, con el detalle de su puntaje.
class PhotoSubject {
  const PhotoSubject({
    required this.actor,
    required this.visibleFraction,
    required this.centering,
    required this.sizeFactor,
    required this.score,
  });

  final PokemonActor actor;

  /// 0..1, que parte del Pokemon quedo dentro del encuadre.
  final double visibleFraction;

  /// 0..1, 1 = justo en el centro del encuadre.
  final double centering;

  /// 0..1, que tan grande se ve respecto al encuadre.
  final double sizeFactor;

  final int score;
}

class PhotoResult {
  const PhotoResult({required this.subjects, required this.bonus});

  final List<PhotoSubject> subjects;

  /// Bonus por varios Pokemon en la misma foto.
  final int bonus;

  bool get isEmpty => subjects.isEmpty;
  int get total => subjects.fold<int>(bonus, (sum, s) => sum + s.score);
}
