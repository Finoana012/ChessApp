import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player_model.dart';

// Principe S — gère UNIQUEMENT les opérations Firestore (hors auth)

class FirestoreDataSource {
  final FirebaseFirestore _db;

  const FirestoreDataSource({required FirebaseFirestore db}) : _db = db;

  // Récupère le profil d'un joueur
  Future<PlayerModel> getPlayer(String uid) async {
    final doc = await _db.collection('players').doc(uid).get();
    if (!doc.exists) throw Exception('Joueur introuvable');
    return PlayerModel.fromFirestore(doc.data()!, uid);
  }

  // Sauvegarde le profil
  Future<void> savePlayer(PlayerModel player) async {
    await _db
        .collection('players')
        .doc(player.uid)
        .set(player.toFirestore(), SetOptions(merge: true));
  }

  // Met à jour un champ spécifique
  Future<void> updateField(
      String uid, String field, dynamic value) async {
    await _db.collection('players').doc(uid).update({
      field: value,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Ajoute un tutoriel complété (arrayUnion = pas de doublons)
  Future<void> addCompletedTutorial(
      String uid, String tutorialId) async {
    await _db.collection('players').doc(uid).update({
      'completedTutorials': FieldValue.arrayUnion([tutorialId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Incrémente les statistiques
  Future<void> incrementStats(
      String uid, {required bool won}) async {
    await _db.collection('players').doc(uid).update({
      'totalGamesPlayed': FieldValue.increment(1),
      if (won) 'totalWins': FieldValue.increment(1),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Sauvegarde une partie jouée dans l'historique
  Future<void> saveGameHistory(
      String uid, Map<String, dynamic> gameData) async {
    await _db
        .collection('players')
        .doc(uid)
        .collection('games')
        .add({
      ...gameData,
      'playedAt': DateTime.now().toIso8601String(),
    });
  }
}