import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/i_user_repository.dart';

class UnlockLevelUseCase {
  final IUserRepository _repository;
  const UnlockLevelUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String uid,
    required int newLevel,
  }) async {
    // On ne peut pas dépasser le niveau 5
    if (newLevel > 5) return const Right(null);
    return _repository.updateLevel(uid, newLevel);
  }
}