import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/i_user_repository.dart';

class CompleteTutorialUseCase {
  final IUserRepository _repository;
  const CompleteTutorialUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String uid,
    required String tutorialId,
  }) async {
    return _repository.completeTutorial(uid, tutorialId);
  }
}