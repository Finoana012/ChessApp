import 'package:equatable/equatable.dart';

enum InvitationStatus { pending, accepted, declined, expired }

class InvitationEntity extends Equatable {
  final String id;
  final String roomCode;
  final String fromUid;
  final String fromUsername;
  final String toEmail;        // Email du joueur invité
  final InvitationStatus status;
  final DateTime createdAt;

  const InvitationEntity({
    required this.id,
    required this.roomCode,
    required this.fromUid,
    required this.fromUsername,
    required this.toEmail,
    this.status = InvitationStatus.pending,
    required this.createdAt,
  });

  // Une invitation expire après 10 minutes
  bool get isExpired =>
      DateTime.now().difference(createdAt).inMinutes > 10;

  @override
  List<Object?> get props =>
      [id, roomCode, fromUid, fromUsername, toEmail, status, createdAt];
}