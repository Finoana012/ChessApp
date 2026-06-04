import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/game_entity.dart';
import '../repositories/i_game_repository.dart';

// Principe S — ce UseCase fait UNE seule chose : jouer un coup
// Principe D — dépend de l'interface IGameRepository, pas de l'implémentation

class MakeMoveUseCase {
  // Injection de dépendance par constructeur — pattern SOLID
  final IGameRepository _repository;

  const MakeMoveUseCase(this._repository);

  // call() permet d'utiliser l'objet comme une fonction : makeMoveUseCase(...)
  Future<Either<Failure, GameEntity>> call({
    required GameEntity game,
    required String from,
    required String to,
  }) async {
    // Validation basique avant d'appeler le repository
    if (from.isEmpty || to.isEmpty) {
      return const Left(GameFailure('Cases invalides'));
    }
    return _repository.makeMove(game, from, to);
  }
}