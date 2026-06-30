import 'package:chess_app/data/datasources/multiplayer_datasource.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/invitation_entity.dart';
import '../../domain/repositories/i_multiplayer_repository.dart';

class MultiplayerRepositoryImpl implements IMultiplayerRepository {
  final MultiplayerDataSource _dataSource;

  const MultiplayerRepositoryImpl({
    required MultiplayerDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Either<Failure, RoomEntity>> createRoom({
    required String hostUid,
    required String hostUsername,
  }) async {
    try {
      final room = await _dataSource.createRoom(
        hostUid: hostUid,
        hostUsername: hostUsername,
      );
      return Right(room);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>?>> searchPlayerByEmail(
      String email) async {
    try {
      final result = await _dataSource.searchPlayerByEmail(email);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvitationEntity>> sendInvitation({
    required String roomCode,
    required String fromUid,
    required String fromUsername,
    required String fromEmail,
    required String toEmail,
  }) async {
    try {
      final invitation = await _dataSource.sendInvitation(
        roomCode: roomCode,
        fromUid: fromUid,
        fromUsername: fromUsername,
        fromEmail: fromEmail,
        toEmail: toEmail,
      );
      return Right(invitation);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<InvitationEntity>> watchInvitations(String userEmail) {
    return _dataSource.watchInvitations(userEmail);
  }

  @override
  Future<Either<Failure, RoomEntity>> acceptInvitation({
    required String invitationId,
    required String roomCode,
    required String guestUid,
    required String guestUsername,
  }) async {
    try {
      final room = await _dataSource.acceptInvitation(
        invitationId: invitationId,
        roomCode: roomCode,
        guestUid: guestUid,
        guestUsername: guestUsername,
      );
      return Right(room);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> declineInvitation(
      String invitationId) async {
    try {
      await _dataSource.declineInvitation(invitationId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<RoomEntity?> watchRoom(String roomCode) {
    return _dataSource.watchRoom(roomCode);
  }

  @override
  Future<Either<Failure, void>> makeMove({
    required String roomCode,
    required String newFen,
    required String nextTurn,
  }) async {
    try {
      await _dataSource.makeMove(
        roomCode: roomCode,
        newFen: newFen,
        nextTurn: nextTurn,
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endGame({
    required String roomCode,
    required String? winnerUid,
  }) async {
    try {
      await _dataSource.endGame(roomCode: roomCode, winnerUid: winnerUid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveRoom(String roomCode) async {
    try {
      await _dataSource.leaveRoom(roomCode);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

    @override
  Stream<String> watchInvitationStatus(String invitationId) {
    return _dataSource.watchInvitationStatus(invitationId);
  }
}