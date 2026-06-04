import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/player_entity.dart';

// Principe D (Dependency Inversion) — les UseCases dépendent
// de cette INTERFACE abstraite, pas de Firebase directement.
// Principe I (Interface Segregation) — interface séparée par domaine.
// Principe O (Open/Closed) — on peut ajouter une implémentation
// (ex: MockUserRepository pour les tests) sans rien modifier ici.

// Either<Failure, T> = le résultat est soit une erreur soit une valeur
// C'est le pattern "Result" — évite les try/catch dans les UseCases

abstract class IUserRepository {
  // Récupère le profil du joueur depuis Firestore
  Future<Either<Failure, PlayerEntity>> getPlayer(String uid);

  // Crée ou met à jour le profil dans Firestore
  Future<Either<Failure, void>> savePlayer(PlayerEntity player);

  // Met à jour le niveau débloqué
  Future<Either<Failure, void>> updateLevel(String uid, int level);

  // Ajoute un tutoriel complété
  Future<Either<Failure, void>> completeTutorial(String uid, String tutorialId);

  // Incrémente les statistiques après une partie
  Future<Either<Failure, void>> updateStats(
      String uid, {required bool won});
}