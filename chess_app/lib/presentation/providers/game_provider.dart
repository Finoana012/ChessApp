import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/dependency_injection.dart';
import '../../domain/entities/game_entity.dart';

// État complet de l'écran de jeu
// Principe S — cette classe représente UNIQUEMENT l'état du jeu
class GameState {
  final chess_lib.Chess chess;     // Moteur de jeu
  final GameEntity? entity;        // Entité du domaine
  final String? selectedSquare;    // Case sélectionnée
  final List<String> legalMoves;   // Mouvements légaux
  final bool isLoading;            // IA en train de réfléchir
  final bool gameOver;             // Partie terminée
  final bool flipped;              // Plateau retourné (mode 2 joueurs)
  final String? errorMessage;      // Message d'erreur éventuel

  const GameState({
    required this.chess,
    this.entity,
    this.selectedSquare,
    this.legalMoves = const [],
    this.isLoading = false,
    this.gameOver = false,
    this.flipped = false,
    this.errorMessage,
  });

  // Getters calculés depuis le moteur chess
  String get turn =>
      chess.turn == chess_lib.Color.WHITE ? 'Blancs' : 'Noirs';
  bool get isCheck     => chess.in_check;
  bool get isCheckMate => chess.in_checkmate;
  bool get isStalemate => chess.in_stalemate;

  String get statusMessage {
    if (isCheckMate) return '♔ Échec et mat !';
    if (isStalemate) return '🤝 Pat — match nul';
    if (isCheck)     return '⚠️ Échec au roi !';
    if (chess.turn == chess_lib.Color.WHITE) return 'Tour des Blancs ♙';
    return 'Tour des Noirs ♟';
  }

  List<String> get moveHistory =>
      chess.san_moves().whereType<String>().toList();

  GameState copyWith({
    chess_lib.Chess? chess,
    GameEntity? entity,
    String? selectedSquare,
    List<String>? legalMoves,
    bool? isLoading,
    bool? gameOver,
    bool? flipped,
    String? errorMessage,
    bool clearSelected = false,
    bool clearError = false,
  }) {
    return GameState(
      chess: chess ?? this.chess,
      entity: entity ?? this.entity,
      selectedSquare: clearSelected ? null : selectedSquare ?? this.selectedSquare,
      legalMoves: clearSelected ? [] : legalMoves ?? this.legalMoves,
      isLoading: isLoading ?? this.isLoading,
      gameOver: gameOver ?? this.gameOver,
      flipped: flipped ?? this.flipped,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(this._ref)
      : super(GameState(chess: chess_lib.Chess()));

  final Ref _ref;

  // Démarre une nouvelle partie
  void startGame({required GameMode mode, required int difficulty}) {
    final newChess = chess_lib.Chess();
    state = GameState(
      chess: newChess,
      entity: GameEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fen: newChess.fen,
        mode: mode,
        difficulty: difficulty,
        status: GameStatus.playing,
      ),
    );
  }

  // Gère le tap sur une case — logique complète
  void onSquareTap(String square) {
  if (state.gameOver || state.isLoading) return;

  final piece = state.chess.get(square);
  final isWhiteTurn = state.chess.turn == chess_lib.Color.WHITE;

  // CAS 1 — Aucune pièce sélectionnée
  if (state.selectedSquare == null) {
    if (piece == null) return;

    final isWhitePiece = piece.color == chess_lib.Color.WHITE;

    // Mode vsSystem : seuls les blancs jouent manuellement
    if (state.entity?.mode == GameMode.vsSystem && !isWhitePiece) return;
    // Vérification du tour
    if (isWhiteTurn != isWhitePiece) return;

    final moves = _getLegalMoves(square);
    if (moves.isEmpty) return; // Pas de mouvements légaux

    state = state.copyWith(
      selectedSquare: square,
      legalMoves: moves,
    );
    return;
  }

  // CAS 2 — Clic sur la même case = déselectionner
  if (state.selectedSquare == square) {
    state = state.copyWith(clearSelected: true);
    return;
  }

  // CAS 3 — Clic sur un mouvement légal = jouer le coup
  // PRIORITÉ sur tout le reste — même si la case a une pièce
  if (state.legalMoves.contains(square)) {
    _makeMove(state.selectedSquare!, square);
    return;
  }

  // CAS 4 — Clic sur une autre pièce alliée = changer la sélection
  if (piece != null) {
    final isWhitePiece = piece.color == chess_lib.Color.WHITE;
    if (isWhiteTurn == isWhitePiece) {
      // En mode vsSystem, seuls les blancs peuvent être sélectionnés
      if (state.entity?.mode == GameMode.vsSystem && !isWhitePiece) {
        state = state.copyWith(clearSelected: true);
        return;
      }
      final moves = _getLegalMoves(square);
      state = state.copyWith(
        selectedSquare: square,
        legalMoves: moves,
      );
      return;
    }
  }

  // CAS 5 — Rien de valide = déselectionner
  state = state.copyWith(clearSelected: true);
}

  // Joue le coup et vérifie l'état
  void _makeMove(String from, String to) {
  // Vérifie si c'est un coup de promotion (pion arrive en ligne 8 ou 1)
  final piece = state.chess.get(from);
  final isPromotion = piece != null &&
      piece.type.name == 'p' &&
      ((piece.color == chess_lib.Color.WHITE && to[1] == '8') ||
       (piece.color == chess_lib.Color.BLACK && to[1] == '1'));

  bool success;
  if (isPromotion) {
    // Promotion automatique en Dame
    success = state.chess.move({
      'from': from,
      'to': to,
      'promotion': 'q', // q = queen = Dame
    });
  } else {
    success = state.chess.move({'from': from, 'to': to});
  }

  if (!success) return;

  final isOver = state.chess.game_over;
  state = state.copyWith(
    clearSelected: true,
    gameOver: isOver,
  );

  if (!isOver &&
      state.entity?.mode == GameMode.vsSystem &&
      state.chess.turn == chess_lib.Color.BLACK) {
    _scheduleAiMove();
  }
}
  // L'IA joue après un délai (pour simuler la réflexion)
  void _scheduleAiMove() {
    state = state.copyWith(isLoading: true);
    Future.delayed(
      const Duration(milliseconds: 600),
      _playAiMove,
    );
  }

  void _playAiMove() {
    if (!mounted) return;
    final depth = state.entity?.difficulty ?? 1;
    final bestMove = _minimax(depth);

    if (bestMove != null) {
      state.chess.move({'from': bestMove['from'], 'to': bestMove['to']});
      final isOver = state.chess.game_over;
      state = state.copyWith(isLoading: false, gameOver: isOver);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  // Algorithme Minimax — difficulté = profondeur de recherche
  Map<String, String>? _minimax(int depth) {
    final moves = state.chess.moves({'verbose': true});
    if (moves.isEmpty) return null;

    Map<String, String>? best;
    int bestScore = -9999;

    for (final move in moves) {
      if (move is! Map) continue;
      final from = move['from'].toString();
      final to   = move['to'].toString();

      state.chess.move({'from': from, 'to': to});
      final score = depth <= 1
          ? DateTime.now().millisecondsSinceEpoch % 100  // Aléatoire niveau 1
          : _evaluate();
      state.chess.undo();

      if (score > bestScore) {
        bestScore = score;
        best = {'from': from, 'to': to};
      }
    }
    return best;
  }

  // Évalue la position — compte l'avantage matériel des Noirs
  int _evaluate() {
    const values = {'p':1,'n':3,'b':3,'r':5,'q':9,'k':0};
    int score = 0;
    for (final sq in chess_lib.Chess.SQUARES.keys) {
      final piece = state.chess.get(sq.toString());
      if (piece == null) continue;
      final val = values[piece.type.name] ?? 0;
      score += piece.color == chess_lib.Color.BLACK ? val : -val;
    }
    return score;
  }

  // Retourne les mouvements légaux depuis une case
  List<String> _getLegalMoves(String square) {
  // verbose:true retourne des Maps avec 'from', 'to', 'flags'
  // On doit utiliser moves() avec asObjects pour avoir tous les coups
  // incluant les promotions et captures
  final moves = state.chess.moves({
    'square': square,
    'verbose': true,
  });

  // Un pion en f7 qui capture en g8 génère 4 coups (un par promotion)
  // On déduplique les cases 'to' pour n'afficher qu'un seul point vert
  final Set<String> destinations = {};
  for (final move in moves) {
    if (move is Map) {
      destinations.add(move['to'].toString());
    } else {
      destinations.add(move.toString());
    }
  }
  return destinations.toList();
}

  // Retourne le plateau (mode 2 joueurs)
  void flipBoard() => state = state.copyWith(flipped: !state.flipped);

  // Recommence la partie
  void resetGame() {
    final mode = state.entity?.mode ?? GameMode.vsSystem;
    final diff = state.entity?.difficulty ?? 1;
    startGame(mode: mode, difficulty: diff);
  }

  // Sauvegarde la partie sur Firestore (appelé en fin de partie)
  Future<void> saveGame(String uid, {required bool won}) async {
    final userRepo = _ref.read(userRepositoryProvider);
    await userRepo.updateStats(uid, won: won);
    if (won && state.entity?.mode == GameMode.vsSystem) {
      final level = state.entity!.difficulty;
      final unlockUC = _ref.read(unlockLevelUseCaseProvider);
      await unlockUC(uid: uid, newLevel: level + 1);
    }
  }
}

// Providers globaux
final gameProvider =
    StateNotifierProvider<GameNotifier, GameState>(
        (ref) => GameNotifier(ref));