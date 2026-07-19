import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
import 'package:fs_score_card/model/french_driving_round_attributes.dart';
import 'package:fs_score_card/model/phases.dart';
import 'package:fs_score_card/model/round_states.dart';
import 'package:fs_score_card/model/scores.dart';

/// A Player in a game
class Player {
  Player({required this.name, required int maxRounds})
    : scores = Scores(maxRounds),
      phases = Phases(maxRounds),
      frenchDrivingAttributes = List.generate(
        maxRounds,
        (_) => FrenchDrivingRoundAttributes(),
      ),
      bidTricksAttributes = List.generate(
        maxRounds,
        (_) => BidTricksRoundAttributes(),
      ),
      roundStates = RoundStates(maxRounds);

  Player.withData({
    required this.name,
    required this.scores,
    required this.phases,
    required this.frenchDrivingAttributes,
    List<BidTricksRoundAttributes>? bidTricksAttributes,
    RoundStates? roundStates,
  }) : bidTricksAttributes =
           bidTricksAttributes ??
           List.generate(
             scores.roundScores.length,
             (_) => BidTricksRoundAttributes(),
           ),
       roundStates = roundStates ?? RoundStates(scores.roundScores.length);

  /// Creates a Player instance from a JSON map
  Player.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      scores = Scores.fromJson(json['scores'] as List<dynamic>),
      phases = Phases.fromJson(json['phases'] as List<dynamic>),
      frenchDrivingAttributes =
          (json['frenchDrivingAttributes'] as List<dynamic>?)
              ?.map(
                (e) => FrenchDrivingRoundAttributes.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      bidTricksAttributes =
          (json['bidTricksAttributes'] as List<dynamic>?)
              ?.map(
                (e) => BidTricksRoundAttributes.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          List.generate(
            (json['scores'] as List<dynamic>).length,
            (_) => BidTricksRoundAttributes(),
          ),
      roundStates = RoundStates.fromJson(json['roundStates'] as List<dynamic>);

  Player copyWith({
    String? name,
    Scores? scores,
    Phases? phases,
    List<FrenchDrivingRoundAttributes>? frenchDrivingAttributes,
    List<BidTricksRoundAttributes>? bidTricksAttributes,
    RoundStates? roundStates,
  }) {
    return Player.withData(
      name: name ?? this.name,
      scores:
          scores ?? Scores.fromJson(List<int?>.from(this.scores.roundScores)),
      phases:
          phases ??
          Phases.fromJson(List<int?>.from(this.phases.completedPhases)),
      frenchDrivingAttributes:
          frenchDrivingAttributes ??
          this.frenchDrivingAttributes.map((e) => e.copyWith()).toList(),
      bidTricksAttributes:
          bidTricksAttributes ??
          this.bidTricksAttributes.map((e) => e.copyWith()).toList(),
      roundStates:
          roundStates ??
          RoundStates.fromJson(List<bool>.from(this.roundStates.enabledRounds)),
    );
  }

  final String name;
  final Scores scores;
  final Phases phases;
  final List<FrenchDrivingRoundAttributes> frenchDrivingAttributes;
  final List<BidTricksRoundAttributes> bidTricksAttributes;
  final RoundStates roundStates;

  int get totalScore => scores.total;

  /// Converts player to a JSON-serializable map
  Map<String, dynamic> toJson() => {
    'name': name,
    'scores': scores.toJson(),
    'phases': phases.toJson(),
    'frenchDrivingAttributes': frenchDrivingAttributes
        .map((e) => e.toJson())
        .toList(),
    'bidTricksAttributes': bidTricksAttributes.map((e) => e.toJson()).toList(),
    'roundStates': roundStates.toJson(),
    'totalScore': totalScore,
  };
}
