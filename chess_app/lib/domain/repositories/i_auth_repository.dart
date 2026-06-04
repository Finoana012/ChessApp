import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/player_entity.dart';

abstract class IAuthRepository {
  // Inscription avec email et mot de passe
  Future<Either<Failure, PlayerEntity>> signUp({
    required String email,
    required String password,
    required String username,
  });

  // Connexion
  Future<Either<Failure, PlayerEntity>> signIn({
    required String email,
    required String password,
  });

  // Déconnexion
  Future<Either<Failure, void>> signOut();

  // Vérifie si l'utilisateur est connecté au démarrage
  Future<Either<Failure, PlayerEntity?>> getCurrentUser();
}