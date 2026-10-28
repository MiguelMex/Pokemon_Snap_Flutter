import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/snap_game.dart';
import '../game/ui/hud_overlay.dart';
import '../game/ui/results_overlay.dart';

import 'package:screenshot/screenshot.dart';

/// Pantalla que aloja el juego. Fuerza horizontal y pantalla completa
/// mientras esta abierta, y restaura todo al salir (el Pokedex sigue vertical).
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SnapGame _game;

  @override
  void initState() {
    super.initState();
    _game = SnapGame();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _exit() => Navigator.of(context).pop();

  void _restart() => setState(() => _game = SnapGame());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Screenshot(
        controller: _game.screenshotController,
        child: GameWidget<SnapGame>(
          key: ObjectKey(_game),
          game: _game,
          initialActiveOverlays: const [SnapGame.hudOverlay],
          overlayBuilderMap: {
            SnapGame.hudOverlay: (context, game) => HudOverlay(game: game, onExit: _exit),
            SnapGame.resultsOverlay: (context, game) => ResultsOverlay(
                  game: game,
                  onRestart: _restart,
                  onExit: _exit,
                ),
          },
        ),
      ),
    );
  }
}
