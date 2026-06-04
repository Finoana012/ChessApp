import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player_model.dart';

// Principe S — cette classe gère UNIQUEMENT l'authentification Firebase
// Principe D — les repositories dépendent de cette classe via injection

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Injection de dépendance par constructeur
  const FirebaseAuthDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  // Inscription — crée l'utilisateur Firebase + profil Firestore
  Future<PlayerModel> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    // Mise à jour du nom d'affichage Firebase
    await user.updateDisplayName(username);

    // Création du document Firestore pour ce joueur
    final player = PlayerModel(
      uid: user.uid,
      username: username,
      email: email,
    );

    await _firestore
        .collection('players')
        .doc(user.uid)
        .set(player.toFirestore());

    return player;
  }

  // Connexion — récupère le profil depuis Firestore
  Future<PlayerModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    return _getPlayerFromFirestore(uid);
  }

  // Déconnexion
  Future<void> signOut() async => _auth.signOut();

  // Vérifie l'utilisateur connecté au démarrage de l'app
  Future<PlayerModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _getPlayerFromFirestore(user.uid);
  }

  // Récupère le profil Firestore — méthode privée réutilisable
  Future<PlayerModel> _getPlayerFromFirestore(String uid) async {
    final doc = await _firestore.collection('players').doc(uid).get();
    if (!doc.exists) throw Exception('Profil introuvable');
    return PlayerModel.fromFirestore(doc.data()!, uid);
  }
}