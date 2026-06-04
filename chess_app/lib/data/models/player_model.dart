import '../../domain/entities/player_entity.dart';

// Principe POO — Héritage : PlayerModel étend PlayerEntity
// PlayerModel ajoute la sérialisation JSON / Firestore
// sans polluer l'entité du domaine avec des détails techniques

class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.uid,
    required super.username,
    required super.email,
    super.currentLevel,
    super.completedTutorials,
    super.totalGamesPlayed,
    super.totalWins,
  });

  // Crée un PlayerModel depuis un document Firestore
  factory PlayerModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return PlayerModel(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      currentLevel: data['currentLevel'] ?? 1,
      completedTutorials:
          List<String>.from(data['completedTutorials'] ?? []),
      totalGamesPlayed: data['totalGamesPlayed'] ?? 0,
      totalWins: data['totalWins'] ?? 0,
    );
  }

  // Convertit en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'currentLevel': currentLevel,
      'completedTutorials': completedTutorials,
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Crée depuis une entité du domaine (pour la conversion)
  factory PlayerModel.fromEntity(PlayerEntity entity) {
    return PlayerModel(
      uid: entity.uid,
      username: entity.username,
      email: entity.email,
      currentLevel: entity.currentLevel,
      completedTutorials: entity.completedTutorials,
      totalGamesPlayed: entity.totalGamesPlayed,
      totalWins: entity.totalWins,
    );
  }
}