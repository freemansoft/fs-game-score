import 'package:fs_score_card/model/game_rules.dart';

/// Per-round inputs for a bid/tricks trick-taking game (Oh Hell, Wizard).
class BidTricksRoundAttributes {
  BidTricksRoundAttributes({this.bid = 0, this.tricksTaken = 0});

  factory BidTricksRoundAttributes.fromJson(Map<String, dynamic> json) {
    return BidTricksRoundAttributes(
      bid: (json['bid'] as num?)?.toInt() ?? 0,
      tricksTaken: (json['tricksTaken'] as num?)?.toInt() ?? 0,
    );
  }

  final int bid;
  final int tricksTaken;

  Map<String, dynamic> toJson() => {'bid': bid, 'tricksTaken': tricksTaken};

  BidTricksRoundAttributes copyWith({int? bid, int? tricksTaken}) {
    return BidTricksRoundAttributes(
      bid: bid ?? this.bid,
      tricksTaken: tricksTaken ?? this.tricksTaken,
    );
  }
}

/// Round score for a bid/tricks game, keyed by the descriptor's [RoundInput].
///
/// Oh Hell: making the bid exactly scores `10 + bid`; any miss scores 0.
/// Wizard: exact scores `20 + 10 * bid`; a miss scores `-10` per trick over or
/// under the bid.
int bidTricksScore(
  RoundInput input, {
  required int bid,
  required int tricksTaken,
}) {
  final exact = bid == tricksTaken;
  return switch (input) {
    RoundInput.calculatedOhHell => exact ? 10 + bid : 0,
    RoundInput.calculatedWizard =>
      exact ? 20 + 10 * bid : -10 * (bid - tricksTaken).abs(),
    RoundInput.typedScore || RoundInput.calculatedFrenchDriving => 0,
  };
}
