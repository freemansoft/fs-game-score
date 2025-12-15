import 'package:fs_score_card/model/phases.dart';
import 'package:fs_score_card/model/round_states.dart';
import 'package:fs_score_card/model/scores.dart';

class Player {
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
  final String name;
  final Scores scores;
  final Phases phases;
  final RoundStates roundStates;

  int get totalScore => scores.total;
}
