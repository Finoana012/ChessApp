import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/dependency_injection.dart';
import '../../domain/entities/player_entity.dart';

// AsyncNotifier gère les états : loading, data, error automatiquement
// Principe S — ce notifier gère UNIQUEMENT l'authentification

class AuthNotifier extends AsyncNotifier<PlayerEntity?> {

  @override
  Future<PlayerEntity?> build() async {
    // Au démarrage, vérifie si un utilisateur est déjà connecté
    final useCase = ref.read(authRepositoryProvider);
    final result = await useCase.getCurrentUser();
    return result.fold(
      (failure) => null,  // Erreur → pas connecté
      (player) => player, // Succès → joueur connecté
    );
  }

  // Connexion
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final useCase = ref.read(signInUseCaseProvider);
    final result = await useCase(email: email, password: password);

    return result.fold(
      (failure) {
        // On garde l'état précédent et on retourne le message d'erreur
        state = const AsyncData(null);
        return failure.message;
      },
      (player) {
        state = AsyncData(player);
        return null; // null = pas d'erreur
      },
    );
  }

  // Inscription
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncLoading();
    final useCase = ref.read(signUpUseCaseProvider);
    final result = await useCase(
      email: email,
      password: password,
      username: username,
    );

    return result.fold(
      (failure) {
        state = const AsyncData(null);
        return failure.message;
      },
      (player) {
        state = AsyncData(player);
        return null;
      },
    );
  }

  // Déconnexion
  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncData(null);
  }
}

// Le provider global — accessible depuis n'importe quel écran
final authProvider =
    AsyncNotifierProvider<AuthNotifier, PlayerEntity?>(AuthNotifier.new);

// Provider dérivé — vrai si l'utilisateur est connecté
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull != null;
});

// Provider dérivé — le joueur actuel (peut être null)
final currentPlayerProvider = Provider<PlayerEntity?>((ref) {
  return ref.watch(authProvider).valueOrNull;
});