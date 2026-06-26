import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.roomCode,
    required super.hostUid,
    required super.hostUsername,
    super.guestUid,
    super.guestUsername,
    super.status,
    super.fen,
    super.currentTurn,
    super.winnerUid,
    required super.createdAt,
  });

  factory RoomModel.fromFirestore(Map<String, dynamic> data, String roomCode) {
    return RoomModel(
      roomCode: roomCode,
      hostUid: data['hostUid'] ?? '',
      hostUsername: data['hostUsername'] ?? '',
      guestUid: data['guestUid'],
      guestUsername: data['guestUsername'],
      status: RoomStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => RoomStatus.waiting,
      ),
      fen: data['fen'] ??
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      currentTurn: data['currentTurn'] ?? 'white',
      winnerUid: data['winnerUid'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hostUid': hostUid,
      'hostUsername': hostUsername,
      'guestUid': guestUid,
      'guestUsername': guestUsername,
      'status': status.name,
      'fen': fen,
      'currentTurn': currentTurn,
      'winnerUid': winnerUid,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}