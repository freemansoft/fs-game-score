import 'package:flutter_test/flutter_test.dart';
// game.dart re-exports game_rules.dart (WinDirection).
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/players.dart';

void main() {
  group('leaderIndices', () {
    // Builds N players on a single round; null leaves that player's board empty.
    Players build(List<int?> firstRoundScores) {
      final players = Players(
        numPlayers: firstRoundScores.length,
        maxRounds: 1,
      );
      for (var i = 0; i < firstRoundScores.length; i++) {
        final score = firstRoundScores[i];
        if (score != null) players[i].scores.setScore(0, score);
      }
      return players;
    }

    test('empty board returns no leader', () {
      final players = build([null, null, null]);
      expect(players.leaderIndices(WinDirection.lowestWins), isEmpty);
      expect(players.leaderIndices(WinDirection.highestWins), isEmpty);
    });

    test('lowestWins picks the minimum total', () {
      final players = build([10, 3, 7]);
      expect(players.leaderIndices(WinDirection.lowestWins), [1]);
    });

    test('highestWins picks the maximum total', () {
      final players = build([10, 3, 7]);
      expect(players.leaderIndices(WinDirection.highestWins), [0]);
    });

    test('ties return every matching index', () {
      final players = build([5, 5, 9]);
      expect(players.leaderIndices(WinDirection.lowestWins), [0, 1]);
    });
  });
}
