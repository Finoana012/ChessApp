import 'package:equatable/equatable.dart';

// Statuts possibles d'une salle de jeu en ligne
enum RoomStatus { waiting, playing, finished }

class RoomEntity extends Equatable {
  final String roomCode;        // Code à 5 caractères (ex: "XK7F2")
  final String hostUid;         // UID du créateur de la salle
  final String hostUsername;
  final String? guestUid;       // UID de l'invité (null si pas encore rejoint)
  final String? guestUsername;
  final RoomStatus status;
  final String fen;             // Position actuelle de la partie
  final String currentTurn;     // 'white' ou 'black'
  final String? winnerUid;      // UID du gagnant (null si en cours)
  final DateTime createdAt;

  const RoomEntity({
    required this.roomCode,
    required this.hostUid,
    required this.hostUsername,
    this.guestUid,
    this.guestUsername,
    this.status = RoomStatus.waiting,
    this.fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
    this.currentTurn = 'white',
    this.winnerUid,
    required this.createdAt,
  });

  bool get isFull => guestUid != null;
  bool get isPlaying => status == RoomStatus.playing;
  bool get isFinished => status == RoomStatus.finished;

  RoomEntity copyWith({
    String? roomCode,
    String? hostUid,
    String? hostUsername,
    String? guestUid,
    String? guestUsername,
    RoomStatus? status,
    String? fen,
    String? currentTurn,
    String? winnerUid,
    DateTime? createdAt,
  }) {
    return RoomEntity(
      roomCode: roomCode ?? this.roomCode,
      hostUid: hostUid ?? this.hostUid,
      hostUsername: hostUsername ?? this.hostUsername,
      guestUid: guestUid ?? this.guestUid,
      guestUsername: guestUsername ?? this.guestUsername,
      status: status ?? this.status,
      fen: fen ?? this.fen,
      currentTurn: currentTurn ?? this.currentTurn,
      winnerUid: winnerUid ?? this.winnerUid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        roomCode, hostUid, hostUsername, guestUid, guestUsername,
        status, fen, currentTurn, winnerUid, createdAt,
      ];
}