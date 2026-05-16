import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import 'tutorial_screen.dart';
import 'level_screen.dart';
import 'game_mode_screen.dart';

const kIndigo = Color(0xFF2D2A6E);
const kIndigoSoft = Color(0xFF3D3A8E);
const kGold = Color(0xFFC9A84C);
const kCream = Color(0xFFF5EDD6);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Boîte de dialogue de confirmation pour quitter l'application
  void _confirmQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quitter ChessApp ?',
          style: TextStyle(
            color: kIndigo,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Voulez-vous vraiment quitter l\'application ?',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        actions: [
          // Bouton Annuler
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          // Bouton Quitter — ferme vraiment l'application
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kIndigo,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // SystemNavigator.pop() ferme l'application proprement
              SystemNavigator.pop();
            },
            child: const Text(
              'Quitter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: kCream,

      // AppBar avec logo en CircleAvatar et nom de l'application
      appBar: AppBar(
        backgroundColor: kIndigo,
        elevation: 0,
        // CircleAvatar avec le logo à gauche
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: kCream,
            backgroundImage: AssetImage('assets/images/kin.png'),
          ),
        ),
        // Nom de l'application au centre
        title: const Text(
          'ChessApp',
          style: TextStyle(
            color: kCream,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: 1,
          ),
        ),
        centerTitle: false,
        // Bouton quitter à droite
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded, color: kGold),
            tooltip: 'Quitter',
            onPressed: () => _confirmQuit(context),
          ),
        ],
        // Ligne dorée en bas de l'AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: kGold, height: 3),
        ),
      ),

      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de bienvenue
                const Text(
                  'Profitez vous d\'une belle aventure !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kIndigo,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Choisissez un mode pour commencer',
                  style: TextStyle(
                    fontSize: 13,
                    color: kIndigo.withOpacity(0.5),
                  ),
                ),

                const SizedBox(height: 28),

                // Bouton Tutoriels
                _buildMenuCard(
                  context,
                  icon: Icons.school_rounded,
                  label: 'Tutoriels',
                  subtitle: 'Apprendre les règles des échecs',
                  accentColor: kIndigo,
                  completed: provider.completedTutorials.length,
                  total: 3,
                  onTap: () =>
                      Navigator.push(context, _route(const TutorialScreen())),
                ),

                const SizedBox(height: 16),

                // Bouton Niveaux
                _buildMenuCard(
                  context,
                  icon: Icons.emoji_events_rounded,
                  label: 'Niveaux',
                  subtitle: 'Progresser du niveau 1 au niveau 5',
                  accentColor: kGold,
                  completed: provider.unlockedLevel - 1,
                  total: 5,
                  onTap: () =>
                      Navigator.push(context, _route(const LevelScreen())),
                ),

                const SizedBox(height: 16),

                // Bouton Jouer
                _buildMenuCard(
                  context,
                  icon: Icons.sports_esports_rounded,
                  label: 'Jouer',
                  subtitle: 'Contre le système ou un ami',
                  accentColor: const Color(0xFF1D9E75),
                  onTap: () =>
                      Navigator.push(context, _route(const GameModeScreen())),
                ),                

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
    int? completed,
    int? total,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône dans cercle coloré
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                  // Barre de progression si applicable
                  if (completed != null && total != null) ...[
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: completed / total,
                              backgroundColor: accentColor.withOpacity(0.12),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(accentColor),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$completed / $total',
                          style: TextStyle(
                            fontSize: 11,
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(Icons.arrow_forward_ios_rounded,
                color: accentColor.withOpacity(0.4), size: 14),
          ],
        ),
      ),
    );
  }

  PageRouteBuilder _route(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
