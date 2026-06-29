import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/usecases/complete_tutorial_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/unlock_level_usecase.dart';

// Providers Riverpod — Principe D : injection de dépendances
// Chaque provider déclare ses dépendances explicitement
import '../../data/datasources/multiplayer_datasource.dart';
import '../../data/repositories/multiplayer_repository_impl.dart';
import '../../domain/repositories/i_multiplayer_repository.dart';

final multiplayerDataSourceProvider =
    Provider<MultiplayerDataSource>((ref) => MultiplayerDataSource(
          db: ref.read(firestoreProvider),
        ));

final multiplayerRepositoryProvider =
    Provider<IMultiplayerRepository>((ref) => MultiplayerRepositoryImpl(
          dataSource: ref.read(multiplayerDataSourceProvider),
        ));
// Firebase
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// DataSources
final firebaseAuthDataSourceProvider =
    Provider<FirebaseAuthDataSource>((ref) => FirebaseAuthDataSource(
          auth: ref.read(firebaseAuthProvider),
          firestore: ref.read(firestoreProvider),
        ));

final firestoreDataSourceProvider =
    Provider<FirestoreDataSource>((ref) => FirestoreDataSource(
          db: ref.read(firestoreProvider),
        ));

// Repositories
final authRepositoryProvider = Provider<IAuthRepository>((ref) =>
    AuthRepositoryImpl(
        dataSource: ref.read(firebaseAuthDataSourceProvider)));

final userRepositoryProvider = Provider<IUserRepository>((ref) =>
    UserRepositoryImpl(
        dataSource: ref.read(firestoreDataSourceProvider)));

// UseCases
final signInUseCaseProvider =
    Provider((ref) => SignInUseCase(ref.read(authRepositoryProvider)));

final signUpUseCaseProvider =
    Provider((ref) => SignUpUseCase(ref.read(authRepositoryProvider)));

final unlockLevelUseCaseProvider =
    Provider((ref) => UnlockLevelUseCase(
        ref.read(userRepositoryProvider)));

final completeTutorialUseCaseProvider =
    Provider((ref) => CompleteTutorialUseCase(
        ref.read(userRepositoryProvider)));