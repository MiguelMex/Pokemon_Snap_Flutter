import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../config/game_config.dart';

/// Visor de la camara. Vive en el viewport (HUD), no en el mundo.
/// El jugador arrastra el dedo en CUALQUIER parte de la pantalla y el visor se
/// mueve de forma relativa (como un trackpad), asi el dedo no tapa el encuadre.
///
/// Como la camara esta fija y anclada arriba-izquierda, las coordenadas del
/// viewport y del mundo coinciden (ambas 1280x720).
class CameraReticle extends PositionComponent with DragCallbacks, HasVisibility {
  CameraReticle()
      : super(position: Vector2.zero(), size: GameConfig.resolution, priority: 10);

  final Vector2 center = GameConfig.resolution / 2;
  final Vector2 frameSize = Vector2(GameConfig.frameWidth, GameConfig.frameHeight);

  final Paint _dim = Paint()..color = const Color(0x66000000);
  final Paint _line = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;
  final Paint _thin = Paint()
    ..color = const Color(0x55FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  Rect get frameRect => Rect.fromCenter(
        center: Offset(center.x, center.y),
        width: frameSize.x,
        height: frameSize.y,
      );

  @override
  void onDragUpdate(DragUpdateEvent event) {
    center.add(event.localDelta * GameConfig.reticleSensitivity);
    center.clamp(frameSize / 2, GameConfig.resolution - frameSize / 2);
  }

  @override
  void render(Canvas canvas) {
    final frame = frameRect;

    // Oscurece todo lo que queda fuera del encuadre
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.x, size.y))
      ..addRect(frame);
    canvas.drawPath(outside, _dim);

    // Regla de tercios
    final w = frame.width / 3;
    final h = frame.height / 3;
    for (var i = 1; i <= 2; i++) {
      canvas.drawLine(Offset(frame.left + w * i, frame.top), Offset(frame.left + w * i, frame.bottom), _thin);
      canvas.drawLine(Offset(frame.left, frame.top + h * i), Offset(frame.right, frame.top + h * i), _thin);
    }

    // Esquinas
    const len = 32.0;
    void corner(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * len, y), _line);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * len), _line);
    }

    corner(frame.left, frame.top, 1, 1);
    corner(frame.right, frame.top, -1, 1);
    corner(frame.left, frame.bottom, 1, -1);
    corner(frame.right, frame.bottom, -1, -1);

    // Cruz central
    final c = frame.center;
    canvas.drawLine(Offset(c.dx - 12, c.dy), Offset(c.dx + 12, c.dy), _line);
    canvas.drawLine(Offset(c.dx, c.dy - 12), Offset(c.dx, c.dy + 12), _line);
  }
}
