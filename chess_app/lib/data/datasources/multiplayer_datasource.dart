import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';
import '../models/invitation_model.dart';

class MultiplayerDataSource {
  final FirebaseFirestore _db;

  const MultiplayerDataSource({required FirebaseFirestore db}) : _db = db;

  // Génère un code de salle aléatoire à 5 caractères (ex: "XK7F2")
  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(5, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Crée une nouvelle salle dans Firestore
  Future<RoomModel> createRoom({
    required String hostUid,
    required String hostUsername,
  }) async {
    final roomCode = _generateRoomCode();
    final room = RoomModel(
      roomCode: roomCode,
      hostUid: hostUid,
      hostUsername: hostUsername,
      createdAt: DateTime.now(),
    );

    await _db.collection('rooms').doc(roomCode).set(room.toFirestore());
    return room;
  }

  // Cherche un joueur par email dans la collection players
  Future<Map<String, String>?> searchPlayerByEmail(String email) async {
    final query = await _db
        .collection('players')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    return {
      'uid': doc.id,
      'username': doc.data()['username'] ?? '',
      'email': doc.data()['email'] ?? '',
    };
  }

  // Envoie une invitation — créée dans la collection invitations
  Future<InvitationModel> sendInvitation({
    required String roomCode,
    required String fromUid,
    required String fromUsername,
    required String toEmail,
  }) async {
    final docRef = _db.collection('invitations').doc();
    final invitation = InvitationModel(
      id: docRef.id,
      roomCode: roomCode,
      fromUid: fromUid,
      fromUsername: fromUsername,
      toEmail: toEmail,
      createdAt: DateTime.now(),
    );

    await docRef.set(invitation.toFirestore());
    return invitation;
  }

  // Stream temps réel des invitations reçues par un email
  Stream<List<InvitationModel>> watchInvitations(String userEmail) {
    return _db
        .collection('invitations')
        .where('toEmail', isEqualTo: userEmail)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvitationModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Accepte l'invitation — met à jour la salle avec le guest
  Future<RoomModel> acceptInvitation({
    required String invitationId,
    required String roomCode,
    required String guestUid,
    required String guestUsername,
  }) async {
    // Met à jour le statut de l'invitation
    await _db.collection('invitations').doc(invitationId).update({
      'status': 'accepted',
    });

    // Met à jour la salle avec les infos du joueur invité
    await _db.collection('rooms').doc(roomCode).update({
      'guestUid': guestUid,
      'guestUsername': guestUsername,
      'status': 'playing',
    });

    final doc = await _db.collection('rooms').doc(roomCode).get();
    return RoomModel.fromFirestore(doc.data()!, roomCode);
  }

  Future<void> declineInvitation(String invitationId) async {
    await _db.collection('invitations').doc(invitationId).update({
      'status': 'declined',
    });
  }

  // Stream temps réel d'une salle — écoute chaque coup joué
  Stream<RoomModel?> watchRoom(String roomCode) {
    return _db.collection('rooms').doc(roomCode).snapshots().map((doc) {
      if (!doc.exists) return null;
      return RoomModel.fromFirestore(doc.data()!, roomCode);
    });
  }

  // Joue un coup — met à jour le FEN et le tour
  Future<void> makeMove({
    required String roomCode,
    required String newFen,
    required String nextTurn,
  }) async {
    await _db.collection('rooms').doc(roomCode).update({
      'fen': newFen,
      'currentTurn': nextTurn,
    });
  }

  // Termine la partie
  Future<void> endGame({
    required String roomCode,
    required String? winnerUid,
  }) async {
    await _db.collection('rooms').doc(roomCode).update({
      'status': 'finished',
      'winnerUid': winnerUid,
    });
  }

  // Supprime la salle
  Future<void> leaveRoom(String roomCode) async {
    await _db.collection('rooms').doc(roomCode).delete();
  }

  // Stream du statut d'une invitation précise — utilisé par celui qui invite
Stream<String> watchInvitationStatus(String invitationId) {
  return _db
      .collection('invitations')
      .doc(invitationId)
      .snapshots()
      .map((doc) => doc.data()?['status'] ?? 'pending');
}
}