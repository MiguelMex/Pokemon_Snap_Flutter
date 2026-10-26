import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'components/camera_reticle.dart';
import 'components/photo_flash.dart';
import 'components/pokemon_actor.dart';
import 'components/pokemon_spawner.dart';
import 'config/game_config.dart';
import 'data/snap_pokemon.dart';
import 'debug/debug_slots_layer.dart';
import 'photo/photo_evaluator.dart';
import 'photo/photo_result.dart';
import 'scene/placeholder_scenery.dart';
import 'scene/scenery_layer.dart';
import 'scene/spawn_slot.dart';

/// Juego principal. Escena ESTATICA: la camara no se mueve y los Pokemon
/// salen desde los bordes/arbustos del escenario.
///
/// Mundo (world):    capas del escenario + Pokemon
/// Viewport (HUD):   visor de la camara + destello
/// Overlays Flutter: botones, puntaje, resultados (ver game/ui/)
class SnapGame extends FlameGame {
  SnapGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: GameConfig.width,
            height: GameConfig.height,
          ),
        );

  static const String hudOverlay = 'hud';
  static const String resultsOverlay = 'results';

  // Estado que escucha la UI de Flutter
  final ValueNotifier<int> photosLeft = ValueNotifier(GameConfig.photosPerSession);
  final ValueNotifier<int> totalScore = ValueNotifier(0);
  final ValueNotifier<PhotoResult?> lastPhoto = ValueNotifier(null);

  /// Todas las fotos de la sesion (base del album).
  final List<PhotoResult> album = [];

  final List<SpawnSlot> slots = buildDefaultSlots();

  CameraReticle? _reticle;
  PokemonSpawner? _spawner;

  @override
  Future<void> onLoad() async {
    // Con anchor arriba-izquierda, mundo (0,0) = esquina superior izquierda.
    camera.viewfinder.anchor = Anchor.topLeft;

    world.addAll([
      SceneryLayer(
        assetPath: 'scenery/background.png',
        placeholder: paintPlaceholderBackground,
        priority: GameConfig.priorityBackground,
      ),
      SceneryLayer(
        assetPath: 'scenery/midground.png',
        placeholder: paintPlaceholderMidground,
        priority: GameConfig.priorityMidground,
      ),
      SceneryLayer(
        assetPath: 'scenery/foreground.png',
        placeholder: paintPlaceholderForeground,
        priority: GameConfig.priorityForeground,
      ),
    ]);

    if (GameConfig.debugDraw) world.add(DebugSlotsLayer(slots));

    final spawner = PokemonSpawner(world: world, pool: kSnapPokemonPool, slots: slots);
    _spawner = spawner;
    add(spawner);

    final reticle = CameraReticle();
    _reticle = reticle;
    camera.viewport.add(reticle);
  }

  /// Toma una foto con el encuadre actual. Devuelve null si no se pudo.
  PhotoResult? takePhoto() {
    final reticle = _reticle;
    if (reticle == null || photosLeft.value <= 0 || paused) return null;

    photosLeft.value -= 1;

    final result = PhotoEvaluator.evaluate(
      frame: reticle.frameRect,
      actors: world.children.whereType<PokemonActor>(),
    );

    camera.viewport.add(PhotoFlash());
    for (final subject in result.subjects) {
      subject.actor.reactToFlash();
    }

    album.add(result);
    totalScore.value += result.total;
    lastPhoto.value = result;

    if (photosLeft.value == 0) finishSession();
    return result;
  }

  void finishSession() {
    overlays.add(resultsOverlay);
    pauseEngine();
  }

  /// Solo para pruebas: hace aparecer un Pokemon ya.
  void debugSpawn() => _spawner?.spawnNow();
}
