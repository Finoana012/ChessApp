import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:shared_preferences/shared_preferences.dart';

enum GameMode { vsSystem, vsFriend }

class GameProvider extends ChangeNotifier {
  chess_lib.Chess _chess = chess_lib.Chess();
  GameMode _mode = GameMode.vsSystem;
  int _level = 1;
  int _unlockedLevel = 1;
  List<String> _completedTutorials = [];

  chess_lib.Chess get chess => _chess;
  GameMode get mode => _mode;
  int get level => _level;
  int get unlockedLevel => _unlockedLevel;
  List<String> get completedTutorials => _completedTutorials;

  // turn est directement un attribut public dans Chess — pas besoin de getter
  String get turn =>
      _chess.turn == chess_lib.Color.WHITE ? 'Blancs' : 'Noirs';

  bool get isGameOver  => _chess.game_over;
  bool get isCheckMate => _chess.in_checkmate;
  bool get isPat       => _chess.in_stalemate;
  bool get isCheck     => _chess.in_check;

  // san_moves() retourne List<String?> — on enlève les nulls
  List<String> get moveHistory =>
      _chess.san_moves().whereType<String>().toList();

  void setMode(GameMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setLevel(int level) {
    _level = level;
    notifyListeners();
  }

  void resetGame() {
    _chess = chess_lib.Chess();
    notifyListeners();
  }

  // move() retourne bool — true si légal, false sinon
  bool makeMove(String from, String to) {
    final success = _chess.move({'from': from, 'to': to});
    if (success) {
      notifyListeners();
      return true;
    }
    return false;
  }

  // moves() avec verbose:true retourne des Map {'from', 'to', 'san', ...}
  List<String> getLegalMovesFrom(String square) {
    final moves = _chess.moves({'square': square, 'verbose': true});
    return moves.map((m) {
      if (m is Map) return m['to'].toString();
      return m.toString();
    }).toList();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _unlockedLevel = prefs.getInt('unlockedLevel') ?? 1;
    _completedTutorials =
        prefs.getStringList('completedTutorials') ?? [];
    notifyListeners();
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlockedLevel', _unlockedLevel);
    await prefs.setStringList('completedTutorials', _completedTutorials);
  }

  Future<void> unlockNextLevel() async {
    if (_unlockedLevel < 5) {
      _unlockedLevel++;
      await saveProgress();
      notifyListeners();
    }
  }
}