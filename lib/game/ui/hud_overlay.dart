import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../photo/photo_result.dart';
import '../snap_game.dart';

/// Interfaz encima del juego: puntaje, fotos restantes, boton de disparo.
/// Los espacios vacios dejan pasar los toques al juego (para mover el visor).
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game, required this.onExit});

  final SnapGame game;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton.filledTonal(
                onPressed: onExit,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ValueListenableBuilder<int>(
                valueListenable: game.totalScore,
                builder: (_, score, __) => _Chip('Puntos: $score'),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: ValueListenableBuilder<int>(
                valueListenable: game.photosLeft,
                builder: (_, left, __) => _Chip('Fotos: $left'),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ValueListenableBuilder<PhotoResult?>(
                valueListenable: game.lastPhoto,
                builder: (_, photo, __) => _LastPhotoInfo(photo),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _ShutterButton(onPressed: game.takePhoto),
            ),
            if (kDebugMode)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton.filled(
                  tooltip: 'Debug: spawn',
                  onPressed: game.debugSpawn,
                  icon: const Icon(Icons.bug_report),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _LastPhotoInfo extends StatelessWidget {
  const _LastPhotoInfo(this.photo);
  final PhotoResult? photo;

  @override
  Widget build(BuildContext context) {
    final p = photo;
    final String text;
    if (p == null) {
      text = 'Arrastra para apuntar y toca el boton para tomar la foto';
    } else if (p.isEmpty) {
      text = 'Sin Pokemon en el encuadre (+0)';
    } else {
      final names = p.subjects.map((s) => s.actor.def.name).join(', ');
      text = '$names  +${p.total}';
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: _Chip(text),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.red, width: 8),
        ),
        child: const Icon(Icons.camera_alt, size: 36, color: Colors.black87),
      ),
    );
  }
}
