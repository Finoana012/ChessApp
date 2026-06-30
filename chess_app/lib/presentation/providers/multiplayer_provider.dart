import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/dependency_injection.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/invitation_entity.dart';

// État de l'écran multijoueur
class MultiplayerState {
  final RoomEntity? room;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedSquare;
  final List<String> legalMoves;
  final String? pendingInvitationId;

  const MultiplayerState({
    this.room,
    this.isLoading = false,
    this.errorMessage,
    this.selectedSquare,
    this.legalMoves = const [],
    this.pendingInvitationId,
  });

  chess_lib.Chess get chess =>
      chess_lib.Chess.fromFEN(room?.fen ?? chess_lib.Chess.DEFAULT_POSITION);

  MultiplayerState copyWith({
    RoomEntity? room,
    bool? isLoading,
    String? errorMessage,
    String? selectedSquare,
    List<String>? legalMoves,
    String? pendingInvitationId,
    bool clearSelected = false,
    bool clearError = false,
    bool clearInvitation = false,
  }) {
    return MultiplayerState(
      room: room ?? this.room,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      selectedSquare:
          clearSelected ? null : selectedSquare ?? this.selectedSquare,
      legalMoves: clearSelected ? [] : legalMoves ?? this.legalMoves,
      pendingInvitationId: clearInvitation
          ? null
          : pendingInvitationId ?? this.pendingInvitationId,
    );
  }
}

class MultiplayerNotifier extends StateNotifier<MultiplayerState> {
  MultiplayerNotifier(this._ref) : super(const MultiplayerState());

  final Ref _ref;
  bool _isLeavingVoluntarily = false;

  // Crée une nouvelle salle de jeu
  Future<String?> createRoom(String hostUid, String hostUsername) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = _ref.read(multiplayerRepositoryProvider);
    final result = await repo.createRoom(
      hostUid: hostUid,
      hostUsername: hostUsername,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return null;
      },
      (room) {
        state = state.copyWith(isLoading: false, room: room);
        _listenToRoom(room.roomCode);
        return room.roomCode;
      },
    );
  }

  // Recherche un joueur par email avant d'envoyer l'invitation
  Future<Map<String, String>?> searchPlayer(String email) async {
    final repo = _ref.read(multiplayerRepositoryProvider);
    final result = await repo.searchPlayerByEmail(email);
    return result.fold((failure) => null, (player) => player);
  }

  // Envoie une invitation
  Future<String?> sendInvitation({
    required String fromUid,
    required String fromUsername,
    required String fromEmail,
    required String toEmail,
  }) async {
    if (state.room == null) return 'Aucune salle créée';

    final repo = _ref.read(multiplayerRepositoryProvider);
    final result = await repo.sendInvitation(
      roomCode: state.room!.roomCode,
      fromUid: fromUid,
      fromUsername: fromUsername,
      fromEmail: fromEmail,
      toEmail: toEmail,
    );

    return result.fold(
      (failure) => failure.message,
      (invitation) {
        // On stocke l'ID et on commence à écouter son statut
        state = state.copyWith(pendingInvitationId: invitation.id);
        _listenToInvitationStatus(invitation.id);
        return null;
      },
    );
  }

// NOUVELLE MÉTHODE — écoute le statut de l'invitation envoyée
  void _listenToInvitationStatus(String invitationId) {
    final repo = _ref.read(multiplayerRepositoryProvider);
    repo.watchInvitationStatus(invitationId).listen((status) {
      if (status == 'declined') {
        // Le joueur a refusé → on ferme la salle créée et on prévient
        if (state.room != null) {
          repo.leaveRoom(state.room!.roomCode);
        }
        state = state.copyWith(
          room: null,
          errorMessage: 'invitation_declined',
          clearInvitation: true,
        );
      }
    });
  }

  // Accepte une invitation reçue
  Future<bool> acceptInvitation({
    required String invitationId,
    required String roomCode,
    required String guestUid,
    required String guestUsername,
  }) async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(multiplayerRepositoryProvider);
    final result = await repo.acceptInvitation(
      invitationId: invitationId,
      roomCode: roomCode,
      guestUid: guestUid,
      guestUsername: guestUsername,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (room) {
        state = state.copyWith(isLoading: false, room: room);
        _listenToRoom(room.roomCode);
        return true;
      },
    );
  }

  // Écoute les changements de la salle en temps réel
   void _listenToRoom(String roomCode) {
    final repo = _ref.read(multiplayerRepositoryProvider);
    repo.watchRoom(roomCode).listen((room) {
      if (room == null) {
        // Si c'est NOUS qui avons supprimé la salle, on ignore l'alerte
        if (_isLeavingVoluntarily) {
          _isLeavingVoluntarily = false; // reset pour la prochaine fois
          return;
        }
        // Sinon, c'est vraiment l'adversaire qui est parti
        state = state.copyWith(
          room: null,
          errorMessage: 'opponent_left',
        );
      } else {
        state = state.copyWith(room: room, clearSelected: true);
      }
    });
  }
  // Gère le tap sur une case (identique à GameNotifier mais synchronisé)
  void onSquareTap(String square, String myUid) {
    if (state.room == null) return;
    final chess = state.chess;
    final piece = chess.get(square);

    // Vérifie que c'est bien le tour du joueur courant
    final isMyTurn = (state.room!.currentTurn == 'white' &&
            myUid == state.room!.hostUid) ||
        (state.room!.currentTurn == 'black' && myUid == state.room!.guestUid);

    if (!isMyTurn) return; // Pas le tour du joueur

    if (state.selectedSquare == null) {
      if (piece == null) return;
      final moves = chess.moves({'square': square, 'verbose': true});
      state = state.copyWith(
        selectedSquare: square,
        legalMoves:
            moves.map((m) => m is Map ? m['to'].toString() : '').toList(),
      );
      return;
    }

    if (state.legalMoves.contains(square)) {
      chess.move({'from': state.selectedSquare, 'to': square});
      final nextTurn = chess.turn == chess_lib.Color.WHITE ? 'white' : 'black';

      final repo = _ref.read(multiplayerRepositoryProvider);
      repo.makeMove(
        roomCode: state.room!.roomCode,
        newFen: chess.fen,
        nextTurn: nextTurn,
      );

      if (chess.game_over) {
        final winnerUid = chess.in_checkmate
            ? (chess.turn == chess_lib.Color.BLACK
                ? state.room!.hostUid
                : state.room!.guestUid)
            : null;
        repo.endGame(roomCode: state.room!.roomCode, winnerUid: winnerUid);
      }

      state = state.copyWith(clearSelected: true);
      return;
    }

    state = state.copyWith(clearSelected: true);
  }

  void leaveRoom() {
    if (state.room != null) {
      _isLeavingVoluntarily = true; // ← AJOUT : on prévient qu'on quitte nous-même
      _ref.read(multiplayerRepositoryProvider).leaveRoom(state.room!.roomCode);
    }
    state = const MultiplayerState();
  }

  void clearState() {
    state = const MultiplayerState();
  }
}

final multiplayerProvider =
    StateNotifierProvider<MultiplayerNotifier, MultiplayerState>(
        (ref) => MultiplayerNotifier(ref));

// Stream des invitations reçues — écoute en temps réel
final invitationsStreamProvider =
    StreamProvider.family<List<InvitationEntity>, String>((ref, email) {
  final repo = ref.read(multiplayerRepositoryProvider);
  return repo.watchInvitations(email);
});
