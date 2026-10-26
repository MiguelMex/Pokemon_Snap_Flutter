import 'dart:math';

import 'package:flame/components.dart';

import '../config/game_config.dart';
import '../data/snap_pokemon.dart';
import '../scene/spawn_slot.dart';
import 'pokemon_actor.dart';

/// Decide cuando y por donde aparece cada Pokemon.
class PokemonSpawner extends Component {
  PokemonSpawner({
    required this.world,
    required this.pool,
    required this.slots,
    Random? random,
  }) : _random = random ?? Random();

  final World world;
  final List<SnapPokemonDef> pool;
  final List<SpawnSlot> slots;
  final Random _random;

  bool enabled = true;
  double _countdown = GameConfig.firstSpawnDelay;

  int get activeCount => world.children.whereType<PokemonActor>().length;

  @override
  void update(double dt) {
    super.update(dt);
    if (!enabled) return;

    _countdown -= dt;
    if (_countdown > 0) return;

    _countdown = GameConfig.spawnIntervalMin +
        _random.nextDouble() *
            (GameConfig.spawnIntervalMax - GameConfig.spawnIntervalMin);

    if (activeCount < GameConfig.maxPokemonOnScreen) spawnNow();
  }

  /// Hace aparecer un Pokemon. Sin parametros elige uno al azar (con pesos) y
  /// un hueco libre. Tambien sirve para pruebas/debug: spawnNow(def: ...).
  PokemonActor? spawnNow({SnapPokemonDef? def, SpawnSlot? slot}) {
    final chosen = def ?? _pickDef();

    SpawnSlot? target = slot;
    if (target == null) {
      final free = slots
          .where((s) => !s.occupied && (chosen.isFlying || !s.airOnly))
          .toList();
      if (free.isEmpty) return null;
      target = free[_random.nextInt(free.length)];
    }

    target.occupied = true;
    final actor = PokemonActor(def: chosen, slot: target);
    world.add(actor);
    return actor;
  }

  SnapPokemonDef _pickDef() {
    final total = pool.fold<double>(0, (sum, d) => sum + d.spawnWeight);
    var roll = _random.nextDouble() * total;
    for (final d in pool) {
      roll -= d.spawnWeight;
      if (roll <= 0) return d;
    }
    return pool.last;
  }
}
