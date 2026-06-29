import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/multiplayer_provider.dart';
import '../../widgets/chess_board.dart';
import '../../widgets/floating_notification.dart';

// ─── Écran d'invitation — lobby ───────────────────────────────────────────────

class MultiplayerLobbyScreen extends ConsumerStatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() =>
      _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState
    extends ConsumerState<MultiplayerLobbyScreen> {
  final _emailController = TextEditingController();
  bool _roomCreated = false;
  String? _searchError;
  bool _isSearching = false;
  bool _hasNavigated = false; // évite de naviguer ou notifier 2 fois

  static const _expirationMinutes = 5;

  bool get _isValidEmail {
    final email = _emailController.text.trim();
    return email.isNotEmpty &&
        RegExp(r'^[\w.\-]+@[\w\-]+\.[\w\-.]+$').hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() => _searchError = null);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _createRoomAndInvite() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail) {
      setState(() => _searchError = 'Entrez un email valide');
      return;
    }

    final player = ref.read(currentPlayerProvider);
    if (player == null) return;

    setState(() {
      _searchError = null;
      _isSearching = true;
    });

    final foundPlayer =
        await ref.read(multiplayerProvider.notifier).searchPlayer(email);
    if (!mounted) return;

    if (foundPlayer == null) {
      setState(() {
        _isSearching = false;
        _searchError = 'Aucun joueur trouvé avec cet email';
      });
      return;
    }

    final roomCode = await ref
        .read(multiplayerProvider.notifier)
        .createRoom(player.uid, player.username);

    if (roomCode == null || !mounted) {
      setState(() => _isSearching = false);
      return;
    }

    setState(() {
      _roomCreated = true;
      _isSearching = false;
    });

    final error = await ref.read(multiplayerProvider.notifier).sendInvitation(
          fromUid: player.uid,
          fromUsername: player.username,
          toEmail: email,
        );

    if (error != null && mounted) {
      setState(() => _searchError = error);
      return;
    }

    _startExpirationTimer(roomCode);
  }

  void _startExpirationTimer(String roomCode) {
    Future.delayed(Duration(minutes: _expirationMinutes), () {
      if (!mounted || _hasNavigated) return;
      final state = ref.read(multiplayerProvider);
      if (state.room != null && !state.room!.isFull) {
        _hasNavigated = true;
        ref.read(multiplayerProvider.notifier).clearState();
        Navigator.pop(context);
        showFloatingNotification(
          context,
          message: 'Votre ami n\'a pas répondu à temps. Invitation expirée.',
          icon: Icons.timer_off_rounded,
          color: AppColors.warning,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(multiplayerProvider);

    ref.listen<MultiplayerState>(multiplayerProvider, (previous, next) {
      final wasFull = previous?.room?.isFull ?? false;
      final isFull = next.room?.isFull ?? false;

      // CAS 1 — l'ami a accepté → navigation automatique
      if (!wasFull && isFull && !_hasNavigated) {
        _hasNavigated = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnlineGameScreen(roomCode: next.room!.roomCode),
          ),
        );
        return;
      }

      // CAS 2 — l'ami a refusé
      if (next.errorMessage == 'invitation_declined' && !_hasNavigated) {
        _hasNavigated = true;
        ref.read(multiplayerProvider.notifier).clearState();
        Navigator.pop(context);
        showFloatingNotification(
          context,
          message: 'Votre ami a refusé l\'invitation.',
          icon: Icons.cancel_rounded,
          color: AppColors.error,
        );
        return;
      }

      // CAS 3 — l'adversaire a quitté pendant l'attente
      if (next.errorMessage == 'opponent_left' && !_hasNavigated) {
        _hasNavigated = true;
        ref.read(multiplayerProvider.notifier).clearState();
        showFloatingNotification(
          context,
          message: 'Votre adversaire a quitté la partie.',
          icon: Icons.wifi_off_rounded,
          color: AppColors.error,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            ref.read(multiplayerProvider.notifier).leaveRoom();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Multijoueur en ligne',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
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
            const Text(
              'Inviter un ami à jouer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Entrez l\'email de votre ami pour l\'inviter',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _emailController,
              enabled: !_roomCreated,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email de votre ami',
                prefixIcon: const Icon(Icons.email_outlined,
                    color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: AppColors.primary.withOpacity(0.2)),
                ),
              ),
            ),

            if (_searchError != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_searchError!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13)),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            if (!_roomCreated)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (_isValidEmail && !_isSearching)
                      ? _createRoomAndInvite
                      : null,
                  icon: _isSearching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_isSearching
                      ? 'Recherche du joueur...'
                      : 'Envoyer l\'invitation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

            if (_roomCreated) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Invitation envoyée à ${_emailController.text.trim()}. '
                      'En attente de sa réponse...',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF444444)),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Écran de jeu en ligne ─────────────────────────────────────────────────

class OnlineGameScreen extends ConsumerWidget {
  final String roomCode;
  const OnlineGameScreen({super.key, required this.roomCode});

  void _confirmLeave(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quitter la partie ?',
          style: TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Si vous quittez, la salle sera fermée et votre adversaire '
          'ne pourra plus continuer la partie.',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(multiplayerProvider.notifier).leaveRoom();
              Navigator.pop(context);
              Navigator.pop(context);
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
    final state = ref.watch(multiplayerProvider);
    final myUid = ref.watch(currentPlayerProvider)?.uid ?? '';
    final room = state.room;

    // Détecte que l'adversaire a quitté une partie EN COURS
    ref.listen<MultiplayerState>(multiplayerProvider, (previous, next) {
      if (next.errorMessage == 'opponent_left' &&
          previous?.errorMessage != 'opponent_left') {
        ref.read(multiplayerProvider.notifier).clearState();
        showFloatingNotification(
          context,
          message: 'Votre adversaire a quitté la partie.',
          icon: Icons.wifi_off_rounded,
          color: AppColors.error,
          duration: const Duration(seconds: 4),
        );
        // Retour automatique au menu après un court délai
        Future.delayed(const Duration(milliseconds: 600), () {
          if (context.mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        });
      }
    });

    if (room == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isHost = myUid == room.hostUid;
    final myColor = isHost ? 'white' : 'black';
    final isMyTurn = room.currentTurn == myColor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmLeave(context, ref);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => _confirmLeave(context, ref),
          ),
          title: Text(
            'Vs ${isHost ? room.guestUsername ?? '...' : room.hostUsername}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isHost ? '♔ Blancs' : '♚ Noirs',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Container(color: AppColors.accent, height: 3),
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: isMyTurn
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.primary.withOpacity(0.08),
              child: Center(
                child: Text(
                  isMyTurn
                      ? 'Votre tour !'
                      : 'En attente de l\'adversaire...',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isMyTurn ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ChessBoardWidget(
                chess: state.chess,
                selectedSquare: state.selectedSquare,
                legalMoves: state.legalMoves,
                flipped: !isHost,
                onSquareTap: (sq) => ref
                    .read(multiplayerProvider.notifier)
                    .onSquareTap(sq, myUid),
              ),
            ),
          ],
        ),
      ),
    );
  }
}