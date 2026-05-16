import 'package:flutter/material.dart';
class GameModeScreen extends StatelessWidget {
  const GameModeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(title: const Text('Choisir le mode'),
          backgroundColor: const Color(0xFF2D1B69)),
      body: const Center(child: Text('Mode de jeu — bientôt disponible',
          style: TextStyle(color: Colors.white))),
    );
  }
}