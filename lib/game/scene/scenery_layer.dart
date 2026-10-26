import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../config/game_config.dart';

typedef PlaceholderPainter = void Function(Canvas canvas, Vector2 size);

/// Una capa del escenario del tamano completo de la pantalla.
/// Si existe la imagen en assets/images/[assetPath] la usa; si no, dibuja el
/// [placeholder]. Asi el equipo de arte reemplaza capas sin tocar codigo.
class SceneryLayer extends PositionComponent with HasGameReference<FlameGame> {
  SceneryLayer({
    required this.assetPath,
    required this.placeholder,
    required int priority,
  }) : super(
          position: Vector2.zero(),
          size: GameConfig.resolution,
          priority: priority,
        );

  final String assetPath;
  final PlaceholderPainter placeholder;

  Sprite? _sprite;
  Picture? _placeholderPicture;

  @override
  Future<void> onLoad() async {
    try {
      final image = await game.images.load(assetPath);
      _sprite = Sprite(image);
    } catch (_) {
      // No hay imagen todavia: se graba el placeholder una sola vez.
      final recorder = PictureRecorder();
      placeholder(Canvas(recorder), size);
      _placeholderPicture = recorder.endRecording();
    }
  }

  @override
  void render(Canvas canvas) {
    final sprite = _sprite;
    if (sprite != null) {
      sprite.render(canvas, size: size);
      return;
    }
    final picture = _placeholderPicture;
    if (picture != null) canvas.drawPicture(picture);
  }

  @override
  void onRemove() {
    _placeholderPicture?.dispose();
    super.onRemove();
  }
}
