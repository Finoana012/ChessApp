import 'package:flutter/material.dart';
class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(title: const Text('Niveaux'),
          backgroundColor: const Color(0xFF2D1B69)),
      body: const Center(child: Text('Niveaux — bientôt disponible',
          style: TextStyle(color: Colors.white))),
    );
  }
}