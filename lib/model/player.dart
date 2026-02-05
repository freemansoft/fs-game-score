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

  /// Creates a Player instance from a JSON map
  Player.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      scores = Scores.fromJson(json['scores'] as List<dynamic>),
      phases = Phases.fromJson(json['phases'] as List<dynamic>),
      roundStates = RoundStates.fromJson(json['roundStates'] as List<dynamic>);

  final String name;
  final Scores scores;
  final Phases phases;
  final RoundStates roundStates;

  int get totalScore => scores.total;

  /// Converts player to a JSON-serializable map
  Map<String, dynamic> toJson() => {
    'name': name,
    'scores': scores.toJson(),
    'phases': phases.toJson(),
    'roundStates': roundStates.toJson(),
    'totalScore': totalScore,
  };
}
