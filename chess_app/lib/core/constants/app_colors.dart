import 'package:flutter/material.dart';

class AppColors {
  // Constructeur privé — empêche l'instanciation (classe utilitaire)
  AppColors._();

  // Couleurs principales — compatibles avec le logo ChessApp
  static const Color primary     = Color(0xFF1E1B4B); // Nuit royale
  static const Color primaryDark = Color(0xFF3730A3); // Indigo vif
  static const Color accent      = Color(0xFFD4AF37); // Or pur
  static const Color background  = Color(0xFFF8F4E8); // Parchemin
  static const Color surface     = Colors.white;

  // Couleurs échiquier
  static const Color lightSquare = Color(0xFFF0D9B5); // Ivoire
  static const Color darkSquare  = Color(0xFFB58863); // Bois

  // Couleurs sémantiques
  static const Color success = Color(0xFF1D9E75);
  static const Color error   = Color(0xFFE24B4A);
  static const Color warning = Color(0xFFEF9F27);
  static const Color info    = Color(0xFF378ADD);

  // Couleurs jeu
  static const Color selectedSquare = Color(0xFF534AB7);
  static const Color legalMove      = Color(0xFF7FC97A);
  static const Color lastMove       = Color(0xFFCDD16E);
  static const Color checkSquare    = Color(0xFFE24B4A);

  // Niveaux
  static const List<Color> levelColors = [
    Color(0xFF1D9E75), // Niveau 1 — vert
    Color(0xFF378ADD), // Niveau 2 — bleu
    Color(0xFFD4AF37), // Niveau 3 — or
    Color(0xFFEF9F27), // Niveau 4 — orange
    Color(0xFFE24B4A), // Niveau 5 — rouge
  ];
}