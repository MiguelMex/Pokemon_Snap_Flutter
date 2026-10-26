import 'package:flame/components.dart';

enum EntryEdge { left, right, top, bottom }

/// Un "hueco" del escenario por donde puede salir un Pokemon.
///
/// [entry] es donde empieza (fuera de pantalla o detras de un arbusto) y
/// [stop] donde se queda visible para ser fotografiado. Despues regresa a
/// [entry] y desaparece.
class SpawnSlot {
  SpawnSlot({
    required this.edge,
    required this.entry,
    required this.stop,
    this.airOnly = false,
  });

  final EntryEdge edge;
  final Vector2 entry;
  final Vector2 stop;

  /// Solo para Pokemon voladores.
  final bool airOnly;

  /// Lo maneja el spawner para no encimar dos Pokemon en el mismo hueco.
  bool occupied = false;
}

/// Layout inicial (coordenadas del mundo 1280x720). AJUSTAR cuando exista el
/// arte final del escenario. Activa GameConfig.debugDraw para verlos.
List<SpawnSlot> buildDefaultSlots() => [
      // Salen por la izquierda, detras de los arbustos
      SpawnSlot(edge: EntryEdge.left, entry: Vector2(-220, 520), stop: Vector2(260, 520)),
      SpawnSlot(edge: EntryEdge.left, entry: Vector2(-220, 560), stop: Vector2(480, 560)),
      // Salen por la derecha
      SpawnSlot(edge: EntryEdge.right, entry: Vector2(1500, 520), stop: Vector2(1020, 520)),
      SpawnSlot(edge: EntryEdge.right, entry: Vector2(1500, 560), stop: Vector2(800, 560)),
      // Suben desde abajo, detras de la hierba del frente
      SpawnSlot(edge: EntryEdge.bottom, entry: Vector2(640, 920), stop: Vector2(640, 540)),
      // Bajan desde arriba (voladores)
      SpawnSlot(edge: EntryEdge.top, entry: Vector2(400, -200), stop: Vector2(400, 170), airOnly: true),
      SpawnSlot(edge: EntryEdge.top, entry: Vector2(640, -200), stop: Vector2(640, 140), airOnly: true),
      SpawnSlot(edge: EntryEdge.top, entry: Vector2(880, -200), stop: Vector2(880, 200), airOnly: true),
    ];
