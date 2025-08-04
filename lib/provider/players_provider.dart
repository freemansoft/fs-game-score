import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_game_score/model/player.dart';
import 'package:fs_game_score/model/players.dart';
import 'package:fs_game_score/provider/game_provider.dart';

final playersProvider = StateNotifierProvider<PlayersNotifier, Players>((ref) {
  final game = ref.watch(gameProvider);
  return PlayersNotifier(
    Players(
      numPlayers: game.numPlayers,
      maxRounds: game.maxRounds,
      numPhases: game.numPhases,
    ),
  );
});

class PlayersNotifier extends StateNotifier<Players> {
  PlayersNotifier(super.players);

  void updateScore(int playerIdx, int round, int? score) {
    final player = state.players[playerIdx];
    player.scores.setScore(round, score);
    state = state.withPlayer(player, playerIdx);
  }

  void updatePhase(int playerIdx, int round, int? phase) {
    final player = state.players[playerIdx];
    player.phases.setPhase(round, phase);
    state = state.withPlayer(player, playerIdx);
  }

  void updatePlayerName(int playerIdx, String name) {
    final player = state.players[playerIdx];
    final updatedPlayer = Player.withData(
      name: name,
      scores: player.scores,
      phases: player.phases,
    );
    state = state.withPlayer(updatedPlayer, playerIdx);
  }

  void resetGame({bool clearNames = false}) {
    final maxRounds =
        state.length > 0 ? state.players[0].scores.roundScores.length : 0;
    final numPhases =
        state.length > 0 ? state.players[0].phases.completedPhases.length : 0;
    var newPlayers = <Player>[];
    for (int i = 0; i < state.length; i++) {
      final oldPlayer = state.players[i];
      final newName = clearNames ? 'Player ${i + 1}' : oldPlayer.name;
      final newPlayer = Player(
        name: newName,
        maxRounds: maxRounds,
        numPhases: numPhases,
      );
      newPlayers.add(newPlayer);
    }
    state = Players(
      numPlayers: state.length,
      maxRounds: maxRounds,
      numPhases: numPhases,
      initialPlayers: newPlayers,
    );
  }

  void toggleRoundEnabled(int round, bool enabled) {
    var newState = state;
    for (int i = 0; i < state.length; i++) {
      final player = state.players[i];
      player.scores.setEnabled(round, enabled);
      player.phases.setEnabled(round, enabled);
      newState = newState.withPlayer(player, i);
    }
    state = newState;
  }
}
