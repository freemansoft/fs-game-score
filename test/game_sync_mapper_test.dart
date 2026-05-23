import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/sync/game_sync_mapper.dart';

void main() {
  test('snapshot round-trip preserves game and players', () {
    final game = Game(
      configuration: GameConfiguration(numPlayers: 2, maxRounds: 3),
      gameId: 'test-game-id',
    );
    final players = Players(numPlayers: 2, maxRounds: 3);
    final snapshot = snapshotFromGame(
      game: game,
      players: players,
      revision: 1,
      hostDeviceName: 'Test Host',
    );
    final restored = gameAndPlayersFromSnapshot(snapshot);
    expect(restored.game.gameId, 'test-game-id');
    expect(restored.game.configuration.maxRounds, 3);
    expect(restored.players.length, 2);
    expect(restored.players[0].name, 'Player 1');
  });
}
