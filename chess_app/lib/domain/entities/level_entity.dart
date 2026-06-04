import 'package:equatable/equatable.dart';

class LevelEntity extends Equatable {
  final int number;      // 1 à 5
  final bool unlocked;   // Débloqué par le joueur
  final bool completed;  // Gagné au moins une fois
  final int difficulty;  // Profondeur Minimax

  const LevelEntity({
    required this.number,
    this.unlocked = false,
    this.completed = false,
    required this.difficulty,
  });

  // Le niveau 1 est toujours accessible
  bool get isAccessible => number == 1 || unlocked;

  LevelEntity copyWith({
    int? number, bool? unlocked,
    bool? completed, int? difficulty,
  }) {
    return LevelEntity(
      number: number ?? this.number,
      unlocked: unlocked ?? this.unlocked,
      completed: completed ?? this.completed,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  List<Object?> get props => [number, unlocked, completed, difficulty];
}