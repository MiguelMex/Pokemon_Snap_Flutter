# Pokemon Snap (escena estatica) - Guia del equipo

## Como correrlo
1. Copiar el contenido de este paquete sobre la raiz del repo (reemplaza `pubspec.yaml` y `lib/main.dart`; respalda tu `main.dart` antes).
2. `flutter pub get`
3. `flutter run` (Android, dispositivo real recomendado)

> `lib/screens/menu_screen.dart` asume que la pantalla del Pokedex se llama `GenerationListScreen` y tiene constructor sin parametros. Si no, ajustar esa linea.

## Como funciona
- **Escena estatica**: la camara no se mueve. Resolucion logica fija 1280x720 (horizontal). Mundo y HUD usan las mismas coordenadas, (0,0) = arriba-izquierda.
- **Apuntar**: el jugador arrastra el dedo en cualquier parte y el visor se mueve (relativo). El boton rojo toma la foto.
- **Pokemon**: salen por "huecos" (`SpawnSlot`) en los bordes: izquierda, derecha, abajo (hierba) y arriba (solo voladores). Entran, se quedan 4-8 s y se van. Si les toman foto, se asustan y se van.
- **Arbustos del frente** (`foreground`) se dibujan encima de los Pokemon, asi parece que salen de detras.

## Estructura
```
lib/game/
  config/game_config.dart      numeros ajustables (tiempos, tamanos, capas)
  data/snap_pokemon.dart       lista de Pokemon del juego (id, nombre, alto, volador, peso)
  scene/spawn_slot.dart        huecos de aparicion  <- ajustar al arte final
  scene/scenery_layer.dart     capa de escenario (usa imagen si existe, si no placeholder)
  scene/placeholder_scenery.dart  escenario provisional dibujado con formas
  components/pokemon_actor.dart   un Pokemon (entra / se queda / sale)
  components/pokemon_spawner.dart cuando y por donde aparecen
  components/camera_reticle.dart  visor + arrastre
  components/photo_flash.dart     destello
  photo/photo_evaluator.dart   puntaje (matematica de rectangulos)
  photo/photo_result.dart      resultado de una foto
  ui/hud_overlay.dart          botones, puntaje, fotos restantes
  ui/results_overlay.dart      fin de sesion
  snap_game.dart               el juego (une todo)
lib/screens/  menu_screen.dart, game_screen.dart (+ las del Pokedex existentes)
```

## Quien toca que
| Rol | Archivos principales |
|---|---|
| A - Gameplay | `pokemon_actor.dart`, `pokemon_spawner.dart`, `spawn_slot.dart`, `game_config.dart` |
| B - Foto | `photo_evaluator.dart`, `photo_result.dart`, `camera_reticle.dart` |
| C - Datos/UI | `snap_pokemon.dart`, `hud_overlay.dart`, `results_overlay.dart`, `menu_screen.dart`, Pokedex |
| D - Arte/audio/QA | `assets/`, `placeholder_scenery.dart` (hasta que haya arte) |

## Reemplazar placeholders por arte
Poner PNG de 1280x720 (los dos ultimos con transparencia):
```
assets/images/scenery/background.png
assets/images/scenery/midground.png
assets/images/scenery/foreground.png
assets/images/pokemon/025.png      (id con 3 digitos, ej. 001, 025, 133)
```
No hay que tocar codigo: si el archivo existe se usa, si no se ve el placeholder.
Despues activar `GameConfig.debugDraw = true` para ver los huecos y moverlos en `buildDefaultSlots()`.

## Agregar un Pokemon
1. PNG en `assets/images/pokemon/`.
2. Una linea en `kSnapPokemonPool` (`snap_pokemon.dart`).

## Pendiente (ideas para las semanas siguientes)
- Guardar la imagen real de la foto (captura de pantalla) y el album persistente.
- Poses/animaciones (dormir, comer, saltar) y bonus por pose.
- Bonus por rareza usando `capture_rate` / `is_legendary` de `/pokemon-species`.
- Sonidos: obturador, gritos (`cryUrl` del modelo existente), musica.
- Cargar la lista de Pokemon desde JSON local de PokeAPI en vez de a mano.
- Tests del `PhotoEvaluator`.
