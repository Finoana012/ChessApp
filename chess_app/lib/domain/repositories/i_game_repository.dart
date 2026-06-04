import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/game_entity.dart';

abstract class IGameRepository {
  // Crée une nouvelle partie et retourne son entité
  Future<Either<Failure, GameEntity>> createGame(
      GameMode mode, int difficulty);

  // Joue un coup — retourne l'entité mise à jour
  Future<Either<Failure, GameEntity>> makeMove(
      GameEntity game, String from, String to);

  // Sauvegarde l'état de la partie dans Firestore
  Future<Either<Failure, void>> saveGame(
      String uid, GameEntity game);

  // Récupère l'historique des parties d'un joueur
  Future<Either<Failure, List<GameEntity>>> getHistory(String uid);

  // Calcule le meilleur coup de l'IA (Minimax)
  Future<Either<Failure, Map<String, String>>> getBestMove(
      GameEntity game, int depth);
}