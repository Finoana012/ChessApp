import 'package:equatable/equatable.dart';

// Enumérations — Principe POO : typage fort plutôt que strings
enum GameStatus { waiting, playing, ended, paused }
enum GameMode   { vsSystem, vsFriend }
enum GameColor  { white, black }

class GameEntity extends Equatable {
  final String id;
  final String fen;           // Position actuelle en notation FEN
  final GameStatus status;
  final GameMode mode;
  final GameColor currentTurn;
  final List<String> moveHistory; // Coups en notation algébrique
  final int difficulty;           // 1 à 5 — utilisé en mode vsSystem
  final bool isCheck;
  final bool isCheckMate;
  final bool isStalemate;

  const GameEntity({
    required this.id,
    required this.fen,
    this.status = GameStatus.waiting,
    this.mode = GameMode.vsSystem,
    this.currentTurn = GameColor.white,
    this.moveHistory = const [],
    this.difficulty = 1,
    this.isCheck = false,
    this.isCheckMate = false,
    this.isStalemate = false,
  });

  // La partie est terminée si mat ou pat
  bool get isGameOver => isCheckMate || isStalemate;

  // Le message d'état à afficher à l'utilisateur
  String get statusMessage {
    if (isCheckMate) return 'Échec et mat !';
    if (isStalemate) return 'Pat — match nul';
    if (isCheck)     return 'Échec au roi !';
    if (currentTurn == GameColor.white) return 'Tour des Blancs';
    return 'Tour des Noirs';
  }

  GameEntity copyWith({
    String? id, String? fen, GameStatus? status,
    GameMode? mode, GameColor? currentTurn,
    List<String>? moveHistory, int? difficulty,
    bool? isCheck, bool? isCheckMate, bool? isStalemate,
  }) {
    return GameEntity(
      id: id ?? this.id,
      fen: fen ?? this.fen,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      currentTurn: currentTurn ?? this.currentTurn,
      moveHistory: moveHistory ?? this.moveHistory,
      difficulty: difficulty ?? this.difficulty,
      isCheck: isCheck ?? this.isCheck,
      isCheckMate: isCheckMate ?? this.isCheckMate,
      isStalemate: isStalemate ?? this.isStalemate,
    );
  }

  @override
  List<Object?> get props => [
        id, fen, status, mode, currentTurn,
        moveHistory, difficulty,
        isCheck, isCheckMate, isStalemate,
      ];
}