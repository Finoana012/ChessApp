import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

// Principe L (Liskov) — implémente IAuthRepository
// Peut remplacer n'importe quelle autre implémentation sans casser le code
// Principe D — dépend de FirebaseAuthDataSource via injection

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuthDataSource _dataSource;

  const AuthRepositoryImpl({required FirebaseAuthDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, PlayerEntity>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final player = await _dataSource.signUp(
        email: email,
        password: password,
        username: username,
      );
      return Right(player);
    } on FirebaseAuthException catch (e) {
      // Conversion des erreurs Firebase en Failures du domaine
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final player = await _dataSource.signIn(
        email: email,
        password: password,
      );
      return Right(player);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity?>> getCurrentUser() async {
    try {
      final player = await _dataSource.getCurrentUser();
      return Right(player);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // Traduit les codes d'erreur Firebase en messages français
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'user-not-found':
        return 'Aucun compte avec cet email';
      case 'weak-password':
        return 'Mot de passe trop faible';
      case 'invalid-email':
        return 'Email invalide';
      case 'network-request-failed':
        return 'Erreur réseau — vérifiez votre connexion';
      default:
        return 'Erreur d\'authentification ($code)';
    }
  }
}