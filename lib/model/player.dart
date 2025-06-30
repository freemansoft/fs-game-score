import 'package:fs_game_score/model/scores.dart';
import 'package:fs_game_score/model/phases.dart';

class Player {
  final String name;
  final Scores scores;
  final Phases phases;

  Player({required this.name, required int maxRounds, required int numPhases})
    : scores = Scores(maxRounds),
      phases = Phases(numPhases);

  int get totalScore => scores.total;
}
