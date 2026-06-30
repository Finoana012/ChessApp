import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/room_entity.dart';
import '../entities/invitation_entity.dart';

abstract class IMultiplayerRepository {
  // Crée une nouvelle salle et retourne son code
  Future<Either<Failure, RoomEntity>> createRoom({
    required String hostUid,
    required String hostUsername,
  });

  // Recherche un joueur par email (pour vérifier qu'il existe avant d'inviter)
  Future<Either<Failure, Map<String, String>?>> searchPlayerByEmail(
      String email);

  // Envoie une invitation par email
  Future<Either<Failure, InvitationEntity>> sendInvitation({
    required String roomCode,
    required String fromUid,
    required String fromUsername,
    required String fromEmail,
    required String toEmail,
  });

  // Écoute les invitations reçues en temps réel (Stream Firestore)
  Stream<List<InvitationEntity>> watchInvitations(String userEmail);

  // Accepte une invitation et rejoint la salle
  Future<Either<Failure, RoomEntity>> acceptInvitation({
    required String invitationId,
    required String roomCode,
    required String guestUid,
    required String guestUsername,
  });

  // Refuse une invitation
  Future<Either<Failure, void>> declineInvitation(String invitationId);

  // Écoute les changements de la salle en temps réel
  Stream<RoomEntity?> watchRoom(String roomCode);

  // Joue un coup dans la salle (synchronisé en temps réel)
  Future<Either<Failure, void>> makeMove({
    required String roomCode,
    required String newFen,
    required String nextTurn,
  });

  // Termine la partie et enregistre le résultat
  Future<Either<Failure, void>> endGame({
    required String roomCode,
    required String? winnerUid,
  });

  // Quitte/supprime la salle
  Future<Either<Failure, void>> leaveRoom(String roomCode);

  // Écoute le statut d'une invitation précise (pending/accepted/declined)
Stream<String> watchInvitationStatus(String invitationId);
}