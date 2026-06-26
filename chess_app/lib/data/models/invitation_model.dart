import '../../domain/entities/invitation_entity.dart';

class InvitationModel extends InvitationEntity {
  const InvitationModel({
    required super.id,
    required super.roomCode,
    required super.fromUid,
    required super.fromUsername,
    required super.toEmail,
    super.status,
    required super.createdAt,
  });

  factory InvitationModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return InvitationModel(
      id: id,
      roomCode: data['roomCode'] ?? '',
      fromUid: data['fromUid'] ?? '',
      fromUsername: data['fromUsername'] ?? '',
      toEmail: data['toEmail'] ?? '',
      status: InvitationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => InvitationStatus.pending,
      ),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roomCode': roomCode,
      'fromUid': fromUid,
      'fromUsername': fromUsername,
      'toEmail': toEmail,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}