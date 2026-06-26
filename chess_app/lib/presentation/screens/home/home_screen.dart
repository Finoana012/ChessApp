import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import '../tutorial/tutorial_screen.dart';
import '../level/level_screen.dart';
import '../game/game_mode_screen.dart';
import '../profile/profile_screen.dart';
import '../game/invitations_screen.dart';
import '../../providers/multiplayer_provider.dart';
import '../game/invitations_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _confirmQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Quitter l\'application',
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w700)),
        content: const Text(
            'Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop();
            },
            child: const Text('Quitter',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(userProvider).valueOrNull;
    final authPlayer = ref.watch(currentPlayerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        // PLUS de leading avec le logo
        // Le titre "ChessApp" est maintenant à gauche
        title: const Text(
          'ChessApp',
          style: TextStyle(
            color: AppColors.background,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
        // centerTitle: false — titre à gauche
        centerTitle: false,
        actions: [
          // Badge avec compteur d'invitations en attente
Consumer(
  builder: (context, ref, _) {
    final player = ref.watch(currentPlayerProvider);
    if (player == null) {
      return IconButton(
        icon: const Icon(Icons.mail_outline_rounded,
            color: AppColors.accent),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const InvitationsScreen()),
        ),
      );
    }

    final invitationsAsync =
        ref.watch(invitationsStreamProvider(player.email));
    final count = invitationsAsync.valueOrNull?.length ?? 0;

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.mail_outline_rounded,
              color: AppColors.accent),
          tooltip: 'Invitations',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const InvitationsScreen()),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints:
                  const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  },
),
          IconButton(
            icon: const Icon(Icons.person_rounded,
                color: AppColors.accent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded,
                color: AppColors.accent),
            onPressed: () => _confirmQuit(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: AppColors.accent, height: 3),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de bienvenue avec progression
            _buildWelcomeCard(player ?? authPlayer),

            const SizedBox(height: 28),

            Text(
              'Que voulez-vous faire ?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            // Tutoriels
            _MenuCard(
              icon: Icons.school_rounded,
              label: AppStrings.tutorials,
              subtitle: 'Apprendre les règles des échecs',
              color: AppColors.primary,
              completed: player?.completedTutorials.length ?? 0,
              total: 3,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const TutorialScreen())),
            ),
            const SizedBox(height: 14),

            // // Niveaux
            // _MenuCard(
            //   icon: Icons.emoji_events_rounded,
            //   label: AppStrings.levels,
            //   subtitle: 'Progresser du niveau 1 au niveau 5',
            //   color: AppColors.accent,
            //   completed: (player?.currentLevel ?? 1) - 1,
            //   total: 5,
            //   onTap: () => Navigator.push(context,
            //       MaterialPageRoute(
            //           builder: (_) => const LevelScreen())),
            // ),
            // const SizedBox(height: 14),

            //Jouer
            _MenuCard(
              icon: Icons.sports_esports_rounded,
              label: AppStrings.play,
              subtitle: 'Contre le système ou un ami',
              color: AppColors.success,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const GameModeScreen())),
            ),
            const SizedBox(height: 14),

            // Quitter
            // _MenuCard(
            //   icon: Icons.exit_to_app_rounded,
            //   label: 'Quitter',
            //   subtitle: 'Fermer l\'application',
            //   color: AppColors.error,
            //   onTap: () => _confirmQuit(context),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgressCard(dynamic player) {
  final currentLevel = player?.currentLevel ?? 1;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: AppColors.accent.withOpacity(0.3), width: 1.5),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.emoji_events_rounded,
              color: AppColors.accent, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Niveau $currentLevel / 5 — ${AppStrings.levelNames[currentLevel - 1]}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: currentLevel / 5,
                  backgroundColor: AppColors.accent.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentLevel < 5
                    ? 'Battez le niveau $currentLevel pour débloquer le suivant'
                    : 'Tous les niveaux débloqués !',
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildWelcomeCard(dynamic player) {
    final username = player?.username ?? 'Joueur';
    final level = player?.currentLevel ?? 1;
    final wins = player?.totalWins ?? 0;
    final games = player?.totalGamesPlayed ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('♔',
                style: TextStyle(fontSize: 28, color: AppColors.accent)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $username !',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Niveau $level / 5 · $wins victoires / $games parties',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: level / 5,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accent),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int? completed;
  final int? total;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.completed,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: color,
                      )),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  if (completed != null && total != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: completed! / total!,
                              backgroundColor:
                                  color.withOpacity(0.12),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$completed / $total',
                            style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.4), size: 14),
          ],
        ),
      ),
    );
  }
}