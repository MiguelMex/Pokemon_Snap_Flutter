import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_config.dart';
import '../scene/spawn_slot.dart';

/// Dibuja los huecos de aparicion: linea de entrada -> parada. Solo para
/// ajustar posiciones (GameConfig.debugDraw = true).
class DebugSlotsLayer extends PositionComponent {
  DebugSlotsLayer(this.slots) : super(priority: GameConfig.priorityDebug);

  final List<SpawnSlot> slots;

  final Paint _line = Paint()
    ..color = const Color(0xCCFF00FF)
    ..strokeWidth = 2;
  final Paint _dot = Paint()..color = const Color(0xFFFF00FF);

  @override
  void render(Canvas canvas) {
    for (final s in slots) {
      canvas.drawLine(Offset(s.entry.x, s.entry.y), Offset(s.stop.x, s.stop.y), _line);
      canvas.drawCircle(Offset(s.stop.x, s.stop.y), 10, _dot);
    }
  }
}
