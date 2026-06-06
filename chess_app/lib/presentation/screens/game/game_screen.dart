import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/game_entity.dart';
import '../../providers/game_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/chess_board.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameMode mode;
  final int difficulty;

  const GameScreen({
    super.key,
    required this.mode,
    this.difficulty = 1,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Démarre la partie au chargement de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startGame(
        mode: widget.mode,
        difficulty: widget.difficulty,
      );
    });
  }

  // Affiche la boîte de dialogue de fin de partie
  void _showGameOverDialog(GameState state) {
    final player = ref.read(currentPlayerProvider);
    final whitesWin = state.isCheckMate &&
        state.chess.turn.name == 'black';
    final message = state.isCheckMate
        ? (whitesWin ? '🏆 Blancs gagnent !' : '🏆 Noirs gagnent !')
        : '🤝 Match nul — Pat';

    // Sauvegarde dans Firebase si connecté
    if (player != null) {
      final won = widget.mode == GameMode.vsSystem && whitesWin;
      ref.read(gameProvider.notifier).saveGame(player.uid, won: won);
      if (won) {
        ref.read(userProvider.notifier)
            .unlockLevel(widget.difficulty + 1);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        content: const Text(
          'Voulez-vous rejouer ?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Menu',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameProvider.notifier).resetGame();
            },
            child: const Text('Rejouer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Réinitialiser la partie ?',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'La partie en cours sera perdue.\nVoulez-vous vraiment recommencer ?',
        style: TextStyle(color: Colors.grey, fontSize: 14),
        textAlign: TextAlign.center,
      ),
      actions: [
        // Bouton Non
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Non',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Bouton Oui
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.pop(context);
            ref.read(gameProvider.notifier).resetGame();
            setState(() {});
          },
          child: const Text(
            'Oui, recommencer',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);

    // Détecte la fin de partie et affiche le dialog
    ref.listen<GameState>(gameProvider, (previous, next) {
      if (next.gameOver && !(previous?.gameOver ?? false)) {
        Future.microtask(() => _showGameOverDialog(next));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.mode == GameMode.vsSystem
              ? '${AppStrings.levelNames[widget.difficulty - 1]}'
              : AppStrings.vsFriend,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          if (widget.mode == GameMode.vsFriend)
            IconButton(
              icon: const Icon(Icons.swap_vert_rounded,
                  color: Colors.white),
              onPressed: () =>
                  ref.read(gameProvider.notifier).flipBoard(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.accent),
            tooltip: 'Nouvelle partie',
            onPressed: () => _confirmReset(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: AppColors.accent, height: 3),
        ),
      ),
      body: Column(
        children: [
          // Bandeau indicateur de tour
          _buildTurnIndicator(state),

          // Message d'état (échec, mat...)
          if (state.isCheck && !state.gameOver)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 16),
              color: AppColors.error.withOpacity(0.15),
              child: Text(
                state.statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),

          // Échiquier
          Padding(
            padding: const EdgeInsets.all(10),
            child: ChessBoardWidget(
              chess: state.chess,
              selectedSquare: state.selectedSquare,
              legalMoves: state.legalMoves,
              flipped: state.flipped,
              onSquareTap: (sq) =>
                  ref.read(gameProvider.notifier).onSquareTap(sq),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(GameState state) {
    final isWhite = state.chess.turn.name == 'white';
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 16),
      color: AppColors.primary.withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isWhite ? '♔' : '♚',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            state.statusMessage,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          // Spinner pendant que l'IA réfléchit
          if (state.isLoading) ...[
            const SizedBox(width: 10),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}