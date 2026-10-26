/// Definicion de un Pokemon dentro del juego.
/// Para el MVP se declara a mano (6 Pokemon). Mas adelante se puede llenar
/// desde los JSON descargados de PokeAPI.
class SnapPokemonDef {
  const SnapPokemonDef({
    required this.id,
    required this.name,
    required this.displayHeight,
    this.isFlying = false,
    this.spawnWeight = 1.0,
  });

  final int id;
  final String name;

  /// Alto en pantalla (unidades del mundo 1280x720). El ancho se calcula
  /// automaticamente segun la proporcion de la imagen.
  final double displayHeight;

  /// Los voladores pueden salir por arriba; los de tierra no.
  final bool isFlying;

  /// Probabilidad relativa de aparecer (mayor = mas comun).
  final double spawnWeight;

  /// Ruta relativa a assets/images/ -> assets/images/pokemon/025.png
  String get spriteAsset => 'pokemon/${id.toString().padLeft(3, '0')}.png';
}

const List<SnapPokemonDef> kSnapPokemonPool = [
  SnapPokemonDef(id: 1, name: 'Bulbasaur', displayHeight: 190),
  SnapPokemonDef(id: 4, name: 'Charmander', displayHeight: 190),
  SnapPokemonDef(id: 7, name: 'Squirtle', displayHeight: 180),
  SnapPokemonDef(id: 16, name: 'Pidgey', displayHeight: 170, isFlying: true),
  SnapPokemonDef(id: 25, name: 'Pikachu', displayHeight: 170, spawnWeight: 0.6),
  SnapPokemonDef(id: 133, name: 'Eevee', displayHeight: 170, spawnWeight: 0.8),
];
