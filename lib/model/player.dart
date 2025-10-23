import 'package:fs_score_card/model/scores.dart';
import 'package:fs_score_card/model/phases.dart';
import 'package:fs_score_card/model/round_states.dart';

class Player {
  final String name;
  final Scores scores;
  final Phases phases;
  final RoundStates roundStates;

  Player({required this.name, required int maxRounds, required int numPhases})
    : scores = Scores(maxRounds),
      phases = Phases(numPhases),
      roundStates = RoundStates(maxRounds);

  Player.withData({
    required this.name,
    required this.scores,
    required this.phases,
    RoundStates? roundStates,
  }) : roundStates = roundStates ?? RoundStates(scores.roundScores.length);

  int get totalScore => scores.total;
}
