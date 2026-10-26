import 'package:flutter/material.dart';

import 'game_screen.dart';
// Pantalla de Pokedex que ya existia en el proyecto.
// Si la clase se llama distinto, ajustar aqui y en el boton "Pokedex".
import 'generation_list_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6EC6FF), Color(0xFFB9E8A5)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'POKEMON SNAP',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                ),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Jugar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GenerationListScreen()),
                ),
                icon: const Icon(Icons.menu_book),
                label: const Text('Pokedex'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
