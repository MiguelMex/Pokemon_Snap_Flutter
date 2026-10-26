import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Alignment, LinearGradient;

// Escenario PROVISIONAL dibujado con formas, para poder probar el juego
// antes de tener arte. Cuando existan las imagenes, basta con poner:
//   assets/images/scenery/background.png
//   assets/images/scenery/midground.png   (PNG con transparencia)
//   assets/images/scenery/foreground.png  (PNG con transparencia)
// y SceneryLayer las usa automaticamente en lugar de esto.

const double _horizon = 430;

void paintPlaceholderBackground(Canvas canvas, Vector2 size) {
  final sky = Rect.fromLTWH(0, 0, size.x, _horizon);
  canvas.drawRect(
    sky,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF6EC6FF), Color(0xFFE3F6FF)],
      ).createShader(sky),
  );

  canvas.drawOval(
    Rect.fromCenter(center: Offset(300, _horizon), width: 900, height: 220),
    Paint()..color = const Color(0xFF8BC98A),
  );
  canvas.drawOval(
    Rect.fromCenter(center: Offset(1000, _horizon), width: 1000, height: 260),
    Paint()..color = const Color(0xFF79BC7B),
  );

  final ground = Rect.fromLTWH(0, _horizon, size.x, size.y - _horizon);
  canvas.drawRect(
    ground,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF6DBE5B), Color(0xFF3F8F3A)],
      ).createShader(ground),
  );

  canvas.drawOval(
    Rect.fromCenter(center: Offset(size.x / 2, 570), width: 1100, height: 160),
    Paint()..color = const Color(0x33A67C52),
  );
}

void paintPlaceholderMidground(Canvas canvas, Vector2 size) {
  void tree(double x, double base, double s) {
    canvas.drawRect(
      Rect.fromLTWH(x - 14 * s, base - 120 * s, 28 * s, 120 * s),
      Paint()..color = const Color(0xFF6D4C41),
    );
    canvas.drawCircle(Offset(x, base - 150 * s), 85 * s, Paint()..color = const Color(0xFF2E7D32));
    canvas.drawCircle(Offset(x - 50 * s, base - 110 * s), 60 * s, Paint()..color = const Color(0xFF388E3C));
    canvas.drawCircle(Offset(x + 50 * s, base - 110 * s), 60 * s, Paint()..color = const Color(0xFF388E3C));
  }

  tree(170, 470, 1.0);
  tree(1110, 460, 1.1);
  tree(560, 440, 0.7);
  tree(760, 440, 0.65);
}

void paintPlaceholderForeground(Canvas canvas, Vector2 size) {
  final dark = Paint()..color = const Color(0xFF1B5E20);
  final light = Paint()..color = const Color(0xFF2E7D32);

  void blob(double cx, double cy, double rx, double ry, Paint p) {
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), p);
  }

  // Bordes izquierdo y derecho: aqui "se esconden" los Pokemon al entrar
  blob(40, 560, 150, 130, dark);
  blob(120, 650, 190, 110, light);
  blob(1240, 560, 150, 130, dark);
  blob(1160, 650, 190, 110, light);
  // Franja de hierba al frente
  blob(640, 770, 700, 100, dark);
  blob(330, 745, 220, 70, light);
  blob(950, 745, 220, 70, light);
}
