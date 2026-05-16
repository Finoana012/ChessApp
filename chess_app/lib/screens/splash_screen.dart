import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _barProgress;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // L'image apparaît progressivement dès le début
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // La barre progresse de 0% à 100% sur toute la durée
    _barProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await context.read<GameProvider>().loadProgress();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EDD6),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // L'IMAGE couvre tout le scaffold du haut jusqu'en bas
              FadeTransition(
                opacity: _fadeIn,
                child: SizedBox(
                  width: screenWidth,
                  height: screenHeight,
                  child: Image.asset(
                    'assets/images/chessclub.png',
                    // cover = l'image remplit tout l'espace sans déformation
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // BARRE DE PROGRESSION en bas, juste au-dessus du bas de l'écran
              Positioned(
                left: 0,
                right: 0,
                // on place la barre à 60px du bas pour lui donner de l'espace
                bottom: 120,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pourcentage affiché au-dessus de la barre
                      Text(
                        '${(_barProgress.value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2A6E),
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Conteneur de la barre — hauteur augmentée à 12px
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2A6E).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _barProgress.value,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2D2A6E),
                                      Color(0xFFC9A84C),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Texte "Chargement..."
                      const Text(
                        'Chargement...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2D2A6E),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
