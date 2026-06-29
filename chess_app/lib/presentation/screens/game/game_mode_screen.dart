import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/game_entity.dart';
import 'game_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import 'multiplayer_screen.dart';

// Changez StatelessWidget en ConsumerWidget
class GameModeScreen extends ConsumerWidget {
  const GameModeScreen({super.key});

  void _showLevelPicker(BuildContext context, WidgetRef ref) {
    // Récupère le niveau actuel du joueur
    final player = ref.read(userProvider).valueOrNull;
    final currentLevel = player?.currentLevel ?? 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisissez votre niveau',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(5, (i) {
              final level = i + 1;
              // Niveau débloqué si <= niveau actuel du joueur
              final unlocked = level <= currentLevel;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: unlocked
                      ? AppColors.levelColors[i]
                      : Colors.grey.shade300,
                  child: Text(
                    unlocked
                        ? AppStrings.levelEmojis[i]
                        : '🔒',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                title: Text(
                  'Niveau $level — ${AppStrings.levelNames[i]}',
                  style: TextStyle(
                    color: unlocked
                        ? AppColors.primary
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: !unlocked
                    ? Text(
                        'Battez le niveau ${level - 1} pour débloquer',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      )
                    : null,
                trailing: Icon(
                  unlocked
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.lock_rounded,
                  size: 14,
                  color: unlocked
                      ? AppColors.accent
                      : Colors.grey.shade300,
                ),
                // Désactivé si non débloqué
                onTap: unlocked
                    ? () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameScreen(
                              mode: GameMode.vsSystem,
                              difficulty: level,
                            ),
                          ),
                        );
                      }
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showFriendDifficultyPicker(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Difficulté de l\'échiquier',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choisissez la vitesse du chrono (décoratif)',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ...List.generate(3, (i) {
            final labels = ['Débutant', 'Intermédiaire', 'Avancé'];
            final emojis = ['🌱', '🔥', '👑'];
            final colors = [
              AppColors.success,
              AppColors.warning,
              AppColors.error,
            ];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: colors[i].withOpacity(0.15),
                child: Text(emojis[i],
                    style: const TextStyle(fontSize: 16)),
              ),
              title: Text(
                labels[i],
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.accent),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      mode: GameMode.vsFriend,
                      difficulty: i + 1,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choisir le mode',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: AppColors.accent, height: 3),
        ),
      ),
      body: Padding(
        // padding: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Comment voulez-vous jouer ?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 35),
            _ModeCard(
              icon: '🤖',
              title: AppStrings.vsSystem,
              subtitle:
                  'Jouez contre l\'ordinateur\nNiveaux débloqués progressivement',
              onTap: () => _showLevelPicker(context, ref),
            ),
            const SizedBox(height: 20),
            _ModeCard(
            icon: '👥',
            title: AppStrings.vsFriend,
            subtitle: 'Deux joueurs sur le même téléphone\nTour par tour',
            // Appelle le picker de difficulté au lieu de naviguer directement
            onTap: () => _showFriendDifficultyPicker(context, ref),
          ),

          const SizedBox(height: 20),
          _ModeCard(
            icon: '🌐',
            title: 'Jouer en ligne',
            subtitle: 'Invitez un ami par email\nJouez en temps réel',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MultiplayerLobbyScreen(),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.accent, size: 16),
          ],
        ),
      ),
    );
  }
}