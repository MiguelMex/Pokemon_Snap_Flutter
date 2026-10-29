import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/painting.dart' show HSVColor, TextStyle;
import 'package:http/http.dart' as http;

import '../config/game_config.dart';
import '../data/snap_pokemon.dart';
import '../scene/spawn_slot.dart';

enum ActorPhase { entering, staying, leaving }

/// Un Pokemon en escena. Ciclo: entra desde su hueco -> se queda un rato
/// (con un movimiento suave) -> se va por donde llego -> se elimina.
class PokemonActor extends PositionComponent with HasGameReference<FlameGame> {
  PokemonActor({
    required this.def,
    required this.slot,
    Random? random,
  })  : _random = random ?? Random(),
        super(anchor: Anchor.center, priority: GameConfig.priorityPokemon);

  final SnapPokemonDef def;
  final SpawnSlot slot;
  final Random _random;

  ActorPhase phase = ActorPhase.entering;
  bool photographed = false;

  Sprite? _sprite;
  double _stayDuration = 5;
  double _phaseTime = 0;
  double _idleTime = 0;
  Vector2 _leaveFrom = Vector2.zero();

  /// Cache compartido por todos los actores (`static` = pertenece a la clase,
  /// no a cada instancia): id del pokemon -> imagen ya descargada.
  static final Map<int, ui.Image> _imageCache = {};

  /// Imagen oficial (fondo transparente) del repo de sprites de PokeAPI.
  String get _imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${def.id}.png';

  late final Paint _placeholderPaint = Paint()
    ..color = HSVColor.fromAHSV(0.9, ((def.id * 47) % 360).toDouble(), 0.55, 0.95).toColor();
  late final TextPaint _label = TextPaint(
    style: const TextStyle(
      color: Color(0xFF000000),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  );

  /// Rectangulo del Pokemon en coordenadas del mundo (anchor = centro).
  Rect get hitRect => Rect.fromCenter(
        center: Offset(position.x, position.y),
        width: size.x,
        height: size.y,
      );

  /// Descarga la imagen desde internet (o la toma del cache si ya se bajo).
  Future<ui.Image> _loadNetworkImage() async {
    final cached = _imageCache[def.id];
    if (cached != null) return cached;

    // GET = pedir el archivo al servidor. `.timeout` lanza un error si
    // tarda mas de 5 s, para que el actor no se quede esperando sin red.
    final response = await http
        .get(Uri.parse(_imageUrl))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode} al bajar ${def.name}');
    }

        // bodyBytes = bytes crudos del PNG (Uint8List = lista de bytes).
    final Uint8List bytes = response.bodyBytes;

    // Un "codec" es el decodificador de un formato de imagen (PNG, JPG...).
    // instantiateImageCodec lee los bytes y prepara el decodificador.
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    // Las imagenes pueden tener varios cuadros (como un GIF animado).
    // getNextFrame() decodifica el primer cuadro; un PNG normal solo tiene uno.
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    _imageCache[def.id] = image;
    return image;
  }

  @override
  Future<void> onLoad() async {
    final height = def.displayHeight;
    var width = height;
    try {
      final image = await _loadNetworkImage();
      _sprite = Sprite(image);
      width = height * image.width / image.height;
    } catch (e) {
      // Sin red o error: se dibuja un circulo con el nombre.
      // (print temporal para ver que falla; quitalo cuando funcione)
      print('No se pudo cargar ${def.name}: $e');
    }
    size = Vector2(width, height);
    position = slot.entry.clone();
    _stayDuration = GameConfig.stayMin +
        _random.nextDouble() * (GameConfig.stayMax - GameConfig.stayMin);
  }

  /// Llamado cuando le toman una foto: se asusta y se va.
  void reactToFlash() {
    photographed = true;
    if (phase != ActorPhase.leaving) _setPhase(ActorPhase.leaving);
  }

  void _setPhase(ActorPhase next) {
    phase = next;
    _phaseTime = 0;
    if (next == ActorPhase.leaving) _leaveFrom = position.clone();
  }

  void _moveBetween(Vector2 a, Vector2 b, double t) {
    position.setValues(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _phaseTime += dt;
    _idleTime += dt;

    switch (phase) {
      case ActorPhase.entering:
        final t = min(1.0, _phaseTime / GameConfig.enterDuration);
        _moveBetween(slot.entry, slot.stop, Curves.easeOutCubic.transform(t));
        if (t >= 1) _setPhase(ActorPhase.staying);
      case ActorPhase.staying:
        final amp = def.isFlying ? 10.0 : 4.0;
        position.setValues(slot.stop.x, slot.stop.y + sin(_idleTime * 3) * amp);
        if (_phaseTime >= _stayDuration) _setPhase(ActorPhase.leaving);
      case ActorPhase.leaving:
        final t = min(1.0, _phaseTime / GameConfig.leaveDuration);
        _moveBetween(_leaveFrom, slot.entry, Curves.easeInCubic.transform(t));
        if (t >= 1) removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final sprite = _sprite;
    if (sprite != null) {
      sprite.render(canvas, size: size);
      return;
    }
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      min(size.x, size.y) / 2,
      _placeholderPaint,
    );
    _label.render(canvas, def.name, Vector2(size.x / 2, size.y / 2), anchor: Anchor.center);
  }

  @override
  void onRemove() {
    slot.occupied = false; // libera el hueco
    super.onRemove();
  }
}