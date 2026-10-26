import 'package:flame/components.dart';

/// Todos los valores ajustables del juego viven aqui.
/// Si algo "se siente mal" (muy rapido, muy lento, muy dificil), se cambia aqui.
class GameConfig {
  GameConfig._();

  // --- Resolucion logica -----------------------------------------------------
  // El juego es horizontal 16:9. Mundo y HUD usan ESTAS coordenadas
  // (0,0 = esquina superior izquierda). Flame escala a la pantalla real y
  // deja barras negras si la proporcion es distinta.
  static const double width = 1280;
  static const double height = 720;
  static Vector2 get resolution => Vector2(width, height);

  // --- Orden de dibujo (mayor = mas al frente) -------------------------------
  static const int priorityBackground = 0;
  static const int priorityMidground = 5;
  static const int priorityPokemon = 10;
  static const int priorityForeground = 20; // arbustos que tapan la entrada
  static const int priorityDebug = 90;

  // --- Sesion ----------------------------------------------------------------
  static const int photosPerSession = 12;

  // --- Spawner ---------------------------------------------------------------
  static const int maxPokemonOnScreen = 3;
  static const double firstSpawnDelay = 1.0;
  static const double spawnIntervalMin = 2.0;
  static const double spawnIntervalMax = 5.0;

  // --- Pokemon (tiempos en segundos) -----------------------------------------
  static const double enterDuration = 1.6;
  static const double leaveDuration = 1.2;
  static const double stayMin = 4.0;
  static const double stayMax = 8.0;

  // --- Visor -----------------------------------------------------------------
  static const double frameWidth = 420;
  static const double frameHeight = 280;
  static const double reticleSensitivity = 1.4;

  // --- Foto ------------------------------------------------------------------
  /// Fraccion minima del Pokemon que debe estar dentro del encuadre para contar.
  static const double minVisibleFraction = 0.6;

  /// Dibuja los puntos de aparicion en pantalla (para ajustar posiciones).
  static const bool debugDraw = false;
}
