class AppStrings {
  AppStrings._();

  static const String appName    = 'ChessApp';
  static const String tagline    = 'Apprenez · Progressez · Jouez';

  // Auth
  static const String login      = 'Se connecter';
  static const String register   = 'S\'inscrire';
  static const String email      = 'Email';
  static const String password   = 'Mot de passe';
  static const String logout     = 'Se déconnecter';

  // Navigation
  static const String home       = 'Accueil';
  static const String tutorials  = 'Tutoriels';
  static const String levels     = 'Niveaux';
  static const String play       = 'Jouer';
  static const String profile    = 'Profil';

  // Jeu
  static const String vsSystem   = 'Contre le système';
  static const String vsFriend   = 'Contre un ami';
  static const String checkMate  = 'Échec et mat !';
  static const String stalemate  = 'Pat — match nul';
  static const String check      = 'Échec au roi !';
  static const String whiteTurn  = 'Tour des Blancs';
  static const String blackTurn  = 'Tour des Noirs';
  static const String newGame    = 'Nouvelle partie';

  // Niveaux
  static const List<String> levelNames = [
    'Débutant', 'Facile', 'Intermédiaire', 'Fort', 'Expert'
  ];
  static const List<String> levelEmojis = [
    '🌱', '⭐', '🔥', '💪', '👑'
  ];
}