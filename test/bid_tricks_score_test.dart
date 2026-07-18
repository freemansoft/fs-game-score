import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
import 'package:fs_score_card/model/game.dart'; // re-exports RoundInput

void main() {
  group('bidTricksScore', () {
    test('Oh Hell: exact bid scores 10 + bid', () {
      expect(
        bidTricksScore(RoundInput.calculatedOhHell, bid: 3, tricksTaken: 3),
        13,
      );
      expect(
        bidTricksScore(RoundInput.calculatedOhHell, bid: 0, tricksTaken: 0),
        10,
      );
    });

    test('Oh Hell: any miss scores 0', () {
      expect(
        bidTricksScore(RoundInput.calculatedOhHell, bid: 3, tricksTaken: 2),
        0,
      );
      expect(
        bidTricksScore(RoundInput.calculatedOhHell, bid: 1, tricksTaken: 4),
        0,
      );
    });

    test('Wizard: exact bid scores 20 + 10*bid', () {
      expect(
        bidTricksScore(RoundInput.calculatedWizard, bid: 2, tricksTaken: 2),
        40,
      );
      expect(
        bidTricksScore(RoundInput.calculatedWizard, bid: 0, tricksTaken: 0),
        20,
      );
    });

    test('Wizard: miss scores -10 per trick over/under', () {
      expect(
        bidTricksScore(RoundInput.calculatedWizard, bid: 3, tricksTaken: 5),
        -20,
      );
      expect(
        bidTricksScore(RoundInput.calculatedWizard, bid: 4, tricksTaken: 1),
        -30,
      );
    });

    test('non-bid RoundInput scores 0', () {
      expect(bidTricksScore(RoundInput.typedScore, bid: 3, tricksTaken: 3), 0);
    });
  });

  group('BidTricksRoundAttributes', () {
    test('round-trips through JSON', () {
      final attrs = BidTricksRoundAttributes(bid: 3, tricksTaken: 2);
      final restored = BidTricksRoundAttributes.fromJson(attrs.toJson());
      expect(restored.bid, 3);
      expect(restored.tricksTaken, 2);
    });

    test('fromJson defaults missing fields to 0', () {
      final restored = BidTricksRoundAttributes.fromJson(<String, dynamic>{});
      expect(restored.bid, 0);
      expect(restored.tricksTaken, 0);
    });
  });
}
