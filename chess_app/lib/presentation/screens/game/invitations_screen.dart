import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/multiplayer_provider.dart';
import 'multiplayer_screen.dart';
import '../../../core/utils/dependency_injection.dart';

class InvitationsScreen extends ConsumerWidget {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(currentPlayerProvider);
    if (player == null) return const SizedBox();

    final invitationsAsync =
        ref.watch(invitationsStreamProvider(player.email));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Invitations reçues',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: invitationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (invitations) {
          if (invitations.isEmpty) {
            return const Center(
              child: Text('Aucune invitation pour le moment',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: invitations.length,
            itemBuilder: (_, i) {
              final inv = invitations[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${inv.fromUsername} vous invite à jouer !',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Code : ${inv.roomCode}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref
                                  .read(multiplayerRepositoryProvider)
                                  .declineInvitation(inv.id);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side:
                                  const BorderSide(color: AppColors.error),
                            ),
                            child: const Text('Refuser'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await ref
                                  .read(multiplayerProvider.notifier)
                                  .acceptInvitation(
                                    invitationId: inv.id,
                                    roomCode: inv.roomCode,
                                    guestUid: player.uid,
                                    guestUsername: player.username,
                                  );
                              if (success && context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OnlineGameScreen(
                                        roomCode: inv.roomCode),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Accepter'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}