

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pokeclase20263/game/gallery_repository.dart';
import 'package:pokeclase20263/game/photo/photo_cropper.dart';

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

//Para la captura de pantalla
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

  //Visibilidad de la UI, la screenshot solo captura el canvas del juego
  //Estos widgets no aparecen en la foto
  final ValueNotifier<bool> hudVisible = ValueNotifier(true);
  final ValueNotifier<bool> resultsVisible = ValueNotifier(false);

  // static const String hudOverlay = 'hud';
  // static const String resultsOverlay = 'results';

  // Estado que escucha la UI de Flutter
  final ValueNotifier<int> photosLeft = ValueNotifier(GameConfig.photosPerSession);
  final ValueNotifier<int> totalScore = ValueNotifier(0);
  final ValueNotifier<PhotoResult?> lastPhoto = ValueNotifier(null);

  /// Todas las fotos de la sesion (base del album).
  final List<PhotoResult> album = [];

  final List<SpawnSlot> slots = buildDefaultSlots();

  CameraReticle? _reticle;
  PokemonSpawner? _spawner;

  //Para la screenshot
  final ScreenshotController screenshotController = ScreenshotController();
  //Key pública para la screenshot
  final GlobalKey screenshotKey = GlobalKey();
  //Última captura en base 64
  final ValueNotifier<Uint8List?> lastScreenshot = ValueNotifier(null);
  //La galeria de imagenes
  final ValueNotifier<List<Uint8List>> galleryImages = ValueNotifier([]);

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

    //Congelar camara
    final frameAtShot = reticle.frameRect;

    final result = PhotoEvaluator.evaluate(
      frame: frameAtShot,
      actors: world.children.whereType<PokemonActor>(),
    );

    album.add(result);
    totalScore.value += result.total;
    lastPhoto.value = result;

    //Ocultar visor para que el proximo frame se pinte sin el
    reticle.isVisible = false;

    //Capturamos el siguiente frame (el que sigue al flash)
    //Si era la última foto, mostramos el overlay después de capturar
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try{
        await captureImage(frameAtShot);
      } finally {
        reticle.isVisible = true;
      }

      camera.viewport.add(PhotoFlash());
    for (final subject in result.subjects) {
      subject.actor.reactToFlash();
    }

      if (photosLeft.value == 0) finishSession();
    });

    return result;
  }

  Future<void> captureImage(Rect frameRect) async {
    const pixelRatio = 2.0;
    try{
      final bytes = await screenshotController.capture(
        pixelRatio: pixelRatio,
      );

      if (bytes == null || bytes.isEmpty){
        debugPrint('captureImage: bytes vacios');
        return;
      }

      final cropped = await PhotoCropper.cropToFrame(
        fullBytes: bytes, 
        frameRect: frameRect, 
        gameSize: GameConfig.resolution, 
        pixelRatio: pixelRatio
      );
      if (cropped == null || cropped.isEmpty){
        debugPrint('captureImage: recorte vacio');
        return;
      }

      await GalleryRepository.instance.add(cropped);
      lastScreenshot.value = cropped;

      debugPrint('Screenshot OK (${cropped.length} bytes)');
    } catch (e){
      debugPrint('Error inesperado capturando screenshot: $e');
    }
  }

  void finishSession() {
    //overlays.add(resultsOverlay);
    resultsVisible.value = true;
    pauseEngine();
  }

  /// Solo para pruebas: hace aparecer un Pokemon ya.
  void debugSpawn() => _spawner?.spawnNow();
}
