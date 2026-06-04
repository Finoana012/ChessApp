import 'package:equatable/equatable.dart';

class PlayerEntity extends Equatable {
  final String uid;            // Identifiant Firebase unique
  final String username;       // Nom d'affichage
  final String email;          // Email Firebase
  final int currentLevel;      // Niveau débloqué actuel (1 à 5)
  final List<String> completedTutorials; // IDs des leçons terminées
  final int totalGamesPlayed;  // Statistiques
  final int totalWins;         // Victoires

  const PlayerEntity({
    required this.uid,
    required this.username,
    required this.email,
    this.currentLevel = 1,
    this.completedTutorials = const [],
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
  });

  // Pourcentage de victoires — calculé à la volée
  double get winRate =>
      totalGamesPlayed == 0 ? 0 : totalWins / totalGamesPlayed;

  // copyWith — immuabilité : on ne modifie pas l'objet, on en crée un nouveau
  // C'est le pattern fondamental de la programmation fonctionnelle en Dart
  PlayerEntity copyWith({
    String? uid,
    String? username,
    String? email,
    int? currentLevel,
    List<String>? completedTutorials,
    int? totalGamesPlayed,
    int? totalWins,
  }) {
    return PlayerEntity(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      currentLevel: currentLevel ?? this.currentLevel,
      completedTutorials: completedTutorials ?? this.completedTutorials,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
    );
  }

  @override
  List<Object?> get props => [
        uid, username, email,
        currentLevel, completedTutorials,
        totalGamesPlayed, totalWins,
      ];
}