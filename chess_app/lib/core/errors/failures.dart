import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Erreur réseau — Firebase non disponible
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur de connexion réseau']);
}

// Erreur d'authentification Firebase
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Erreur d\'authentification']);
}

// Erreur base de données Firestore
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Erreur de base de données']);
}

// Erreur logique de jeu — coup illégal
class GameFailure extends Failure {
  const GameFailure([super.message = 'Coup illégal']);
}

// Erreur générique inattendue
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Erreur inattendue']);
}