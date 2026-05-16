import 'package:flutter/material.dart';
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(title: const Text('Tutoriels'),
          backgroundColor: const Color(0xFF2D1B69)),
      body: const Center(child: Text('Tutoriels — bientôt disponible',
          style: TextStyle(color: Colors.white))),
    );
  }
}