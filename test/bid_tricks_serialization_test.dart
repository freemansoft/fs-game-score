import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
import 'package:fs_score_card/model/player.dart';

void main() {
  test('Player round-trips bidTricksAttributes', () {
    final player = Player(name: 'A', maxRounds: 3);
    player.bidTricksAttributes[0] = BidTricksRoundAttributes(
      bid: 2,
      tricksTaken: 2,
    );
    final restored = Player.fromJson(player.toJson());
    expect(restored.bidTricksAttributes.length, 3);
    expect(restored.bidTricksAttributes[0].bid, 2);
    expect(restored.bidTricksAttributes[0].tricksTaken, 2);
  });

  test('Player.fromJson defaults bidTricksAttributes when key absent', () {
    // Simulate an older snapshot that predates the field.
    final json = Player(name: 'B', maxRounds: 4).toJson()
      ..remove('bidTricksAttributes');
    final restored = Player.fromJson(json);
    // Padded to the score length so bid/tricks modes never index out of range.
    expect(restored.bidTricksAttributes.length, 4);
    expect(restored.bidTricksAttributes[0].bid, 0);
  });
}
