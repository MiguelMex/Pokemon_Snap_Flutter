import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_config.dart';

/// Destello blanco al tomar una foto. Se elimina solo.
class PhotoFlash extends PositionComponent {
  PhotoFlash() : super(size: GameConfig.resolution, priority: 100);

  static const double _duration = 0.35;
  double _t = 0;
  final Paint _paint = Paint();

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_t >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1 - _t / _duration).clamp(0.0, 1.0).toDouble();
    _paint.color = Color.fromRGBO(255, 255, 255, alpha);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }
}
