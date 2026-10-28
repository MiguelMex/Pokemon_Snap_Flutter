//Recorta una captura de pantalla a la región que corresponde al frame del reticle
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class PhotoCropper {
  static Future<Uint8List?> cropToFrame({
    required Uint8List fullBytes,
    required Rect frameRect,
    required Vector2 gameSize,
    required double pixelRatio,
  }) async {
    //Decodificar la captura completa
    final codec = await ui.instantiateImageCodec(fullBytes);
    final decoded = await codec.getNextFrame();
    final srcImage =  decoded.image;

    //Tamaño logico de la pantalla a partir de la imagen
    final screenW = srcImage.width / pixelRatio;
    final screenH = srcImage.height / pixelRatio;

    //Misma transformación que aplica FixedResolutionViewport de Flame
    final scale = math.min(screenW / gameSize.x, screenH / gameSize.y);
    final offsetX = (screenW - gameSize.x * scale) / 2;
    final offsetY = (screenH - gameSize.y * scale) / 2;

    //FrameRect -> pixeles de imagen
    final cropLeft = (offsetX + frameRect.left * scale) * pixelRatio;
    final cropTop = (offsetY + frameRect.top * scale) * pixelRatio;
    final cropW = frameRect.width * scale * pixelRatio;
    final cropH = frameRect.height * scale * pixelRatio;

    //Dibujar solo la region recortada
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      srcImage, 
      Rect.fromLTWH(cropLeft, cropTop, cropW, cropH),
      Rect.fromLTWH(0, 0, cropW, cropH),
      Paint()
    );

    final picture = recorder.endRecording();
    final cropped = await picture.toImage(cropW.round(), cropH.round());
    final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);

    srcImage.dispose();
    cropped.dispose();

    return byteData?.buffer.asUint8List();
  }
}