import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/game_entity.dart';
import '../../providers/user_provider.dart';
import '../game/game_screen.dart';

class LevelScreen extends ConsumerWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(userProvider);

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
          AppStrings.levels,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: AppColors.accent, height: 3),
        ),
      ),
      body: playerAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Erreur : $e')),
        data: (player) {
          final currentLevel = player?.currentLevel ?? 1;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Carte de progression
                _buildProgressCard(currentLevel),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choisissez un niveau',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Liste des 5 niveaux
                ...List.generate(5, (i) {
                  final level = i + 1;
                  final unlocked = level <= currentLevel;
                  return _LevelCard(
                    level: level,
                    unlocked: unlocked,
                    onTap: unlocked
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(
                                  mode: GameMode.vsSystem,
                                  difficulty: level,
                                ),
                              ),
                            )
                        : null,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(int currentLevel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre progression',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Niveau $currentLevel / 5 débloqué',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: currentLevel / 5,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accent),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final bool unlocked;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.unlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.levelColors[level - 1];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: unlocked ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unlocked
                ? color.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: unlocked
                    ? color.withOpacity(0.12)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  unlocked
                      ? AppStrings.levelEmojis[level - 1]
                      : '🔒',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Niveau $level — ${AppStrings.levelNames[level - 1]}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: unlocked
                          ? color
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    unlocked
                        ? 'Appuyez pour jouer'
                        : 'Battez le niveau précédent pour débloquer',
                    style: TextStyle(
                      fontSize: 12,
                      color: unlocked
                          ? Colors.grey
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              unlocked
                  ? Icons.play_circle_filled_rounded
                  : Icons.lock_rounded,
              color: unlocked ? color : Colors.grey.shade300,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}