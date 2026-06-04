import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/dependency_injection.dart';
import '../../domain/entities/player_entity.dart';

// Gère le profil et la progression du joueur
class UserNotifier extends AsyncNotifier<PlayerEntity?> {

  @override
  Future<PlayerEntity?> build() async {
    return null; // Initialisé après la connexion
  }

  // Charge le profil depuis Firestore
  Future<void> loadPlayer(String uid) async {
    state = const AsyncLoading();
    final repo = ref.read(userRepositoryProvider);
    final result = await repo.getPlayer(uid);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (player) => AsyncData(player),
    );
  }

  // Marque un tutoriel comme complété
  Future<void> completeTutorial(String tutorialId) async {
    final player = state.valueOrNull;
    if (player == null) return;

    if (player.completedTutorials.contains(tutorialId)) return;

    final useCase = ref.read(completeTutorialUseCaseProvider);
    final result = await useCase(
      uid: player.uid,
      tutorialId: tutorialId,
    );

    result.fold(
      (failure) => null,
      (_) {
        // Mise à jour locale optimiste — sans recharger Firestore
        state = AsyncData(player.copyWith(
          completedTutorials: [...player.completedTutorials, tutorialId],
        ));
      },
    );
  }

  // Débloque le niveau suivant
  Future<void> unlockLevel(int newLevel) async {
    final player = state.valueOrNull;
    if (player == null || newLevel > 5) return;
    if (newLevel <= player.currentLevel) return;

    final useCase = ref.read(unlockLevelUseCaseProvider);
    final result = await useCase(uid: player.uid, newLevel: newLevel);

    result.fold(
      (failure) => null,
      (_) => state = AsyncData(
        player.copyWith(currentLevel: newLevel),
      ),
    );
  }
}

final userProvider =
    AsyncNotifierProvider<UserNotifier, PlayerEntity?>(UserNotifier.new);