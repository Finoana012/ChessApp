import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/player_entity.dart';
import '../repositories/i_auth_repository.dart';

class SignUpUseCase {
  final IAuthRepository _repository;
  const SignUpUseCase(this._repository);

  Future<Either<Failure, PlayerEntity>> call({
    required String email,
    required String password,
    required String username,
  }) async {
    if (!email.contains('@')) {
      return const Left(AuthFailure('Email invalide'));
    }
    if (password.length < 6) {
      return const Left(AuthFailure('Mot de passe trop court'));
    }
    if (username.trim().isEmpty) {
      return const Left(AuthFailure('Nom d\'utilisateur requis'));
    }
    return _repository.signUp(
      email: email,
      password: password,
      username: username,
    );
  }
}