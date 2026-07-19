import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'updateBidTricksAttributes writes the calculated Oh Hell score',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await container
          .read(gameNotifierProvider.notifier)
          .newGame(gameMode: GameMode.ohHell, numPlayers: 2, maxRounds: 3);

      container
          .read(playersNotifierProvider.notifier)
          .updateBidTricksAttributes(
            0,
            0,
            BidTricksRoundAttributes(bid: 3, tricksTaken: 3),
          );

      final players = container.read(playersNotifierProvider);
      // Exact bid -> 10 + 3 = 13 stored in scores.
      expect(players[0].scores.getScore(0), 13);
      expect(players[0].bidTricksAttributes[0].bid, 3);
    },
  );
}
