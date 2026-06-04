import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/player_entity.dart';
import '../repositories/i_auth_repository.dart';

class SignInUseCase {
  final IAuthRepository _repository;
  const SignInUseCase(this._repository);

  Future<Either<Failure, PlayerEntity>> call({
    required String email,
    required String password,
  }) async {
    // Validation email basique
    if (!email.contains('@')) {
      return const Left(AuthFailure('Email invalide'));
    }
    if (password.length < 6) {
      return const Left(AuthFailure('Mot de passe trop court (6 caractères minimum)'));
    }
    return _repository.signIn(email: email, password: password);
  }
}