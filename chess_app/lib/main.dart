import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/game_provider.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'ChessApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D1B69),
            primary: const Color(0xFF2D1B69),
            secondary: const Color(0xFFC9A84C),
          ),
          useMaterial3: true,
          fontFamily: 'Arial',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}