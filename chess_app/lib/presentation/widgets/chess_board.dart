import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import '../../core/constants/app_colors.dart';

// Principe S — ce widget fait UNE chose : afficher l'échiquier
// Principe O — extensible via les paramètres sans modifier le code

class ChessBoardWidget extends StatelessWidget {
  final chess_lib.Chess chess;
  final String? selectedSquare;
  final List<String> legalMoves;
  final Function(String) onSquareTap;
  final bool flipped;

  const ChessBoardWidget({
    super.key,
    required this.chess,
    required this.onSquareTap,
    this.selectedSquare,
    this.legalMoves = const [],
    this.flipped = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: List.generate(8, (rowIndex) {
            final rank = flipped ? rowIndex : 7 - rowIndex;
            return Expanded(
              child: Row(
                children: List.generate(8, (colIndex) {
                  final file = flipped ? 7 - colIndex : colIndex;
                  final squareName =
                      '${'abcdefgh'[file]}${rank + 1}';
                  return _buildSquare(squareName, rank, file);
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSquare(String squareName, int rank, int file) {
    final isLight = (rank + file) % 2 == 0;
    final piece = chess.get(squareName);
    final isSelected = squareName == selectedSquare;
    final isLegal = legalMoves.contains(squareName);
    final isKingInCheck = piece != null &&
        piece.type == chess_lib.Chess.KING &&
        piece.color == chess.turn &&
        chess.in_check;

    Color bgColor = isLight
        ? AppColors.lightSquare
        : AppColors.darkSquare;
    if (isSelected)    bgColor = AppColors.selectedSquare.withOpacity(0.7);
    if (isKingInCheck) bgColor = AppColors.checkSquare.withOpacity(0.7);

    return Expanded(
      child: GestureDetector(
        onTap: () => onSquareTap(squareName),
        child: Container(
          color: bgColor,
          child: Stack(
            children: [
              // Point vert sur les cases légales
              if (isLegal)
                Center(
                  child: Container(
                    width: piece != null ? double.infinity : 26,
                    height: piece != null ? double.infinity : 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: piece == null
                          ? AppColors.legalMove.withOpacity(0.55)
                          : Colors.transparent,
                      border: piece != null
                          ? Border.all(
                              color: AppColors.legalMove.withOpacity(0.7),
                              width: 3)
                          : null,
                    ),
                  ),
                ),

              // La pièce en emoji
              if (piece != null)
                Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        _pieceToEmoji(piece),
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),

              // Coordonnées
              if (file == 0)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      '${rank + 1}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isLight
                            ? AppColors.darkSquare
                            : AppColors.lightSquare,
                      ),
                    ),
                  ),
                ),
              if (rank == 0)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      'abcdefgh'[file],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isLight
                            ? AppColors.darkSquare
                            : AppColors.lightSquare,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _pieceToEmoji(chess_lib.Piece piece) {
    final w = piece.color == chess_lib.Color.WHITE;
    switch (piece.type.name) {
      case 'k': return w ? '♔' : '♚';
      case 'q': return w ? '♕' : '♛';
      case 'r': return w ? '♖' : '♜';
      case 'b': return w ? '♗' : '♝';
      case 'n': return w ? '♘' : '♞';
      case 'p': return w ? '♙' : '♟';
      default:  return '';
    }
  }
}