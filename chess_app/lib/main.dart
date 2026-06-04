import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Obligatoire avant tout appel asynchrone dans main()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase — doit être fait avant runApp()
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  // ProviderScope est le widget racine de Riverpod
  // Il permet à tous les providers d'être accessibles partout
  runApp(const ProviderScope(child: ChessApp()));
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}