import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../models/player_model.dart';

class UserRepositoryImpl implements IUserRepository {
  final FirestoreDataSource _dataSource;

  const UserRepositoryImpl({required FirestoreDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, PlayerEntity>> getPlayer(String uid) async {
    try {
      final player = await _dataSource.getPlayer(uid);
      return Right(player);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePlayer(PlayerEntity player) async {
    try {
      final model = PlayerModel.fromEntity(player);
      await _dataSource.savePlayer(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLevel(
      String uid, int level) async {
    try {
      await _dataSource.updateField(uid, 'currentLevel', level);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeTutorial(
      String uid, String tutorialId) async {
    try {
      await _dataSource.addCompletedTutorial(uid, tutorialId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStats(
      String uid, {required bool won}) async {
    try {
      await _dataSource.incrementStats(uid, won: won);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}