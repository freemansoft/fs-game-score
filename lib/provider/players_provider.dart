import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_game_score/model/player.dart';
import 'package:fs_game_score/provider/game_provider.dart';

final playersProvider = StateNotifierProvider<PlayersNotifier, List<Player>>((
  ref,
) {
  final game = ref.watch(gameProvider);
  return PlayersNotifier(game.numPlayers, game.maxRounds, game.numPhases);
});

class PlayersNotifier extends StateNotifier<List<Player>> {
  PlayersNotifier(int numPlayers, int maxRounds, int numPhases)
    : super(
        List.generate(
          numPlayers,
          (i) => Player(
            name: 'Player ${i + 1}',
            maxRounds: maxRounds,
            numPhases: numPhases,
          ),
        ),
      );

  void updateScore(int playerIdx, int round, int? score) {
    final player = state[playerIdx];
    player.scores.setScore(round, score);
    state = [...state];
  }

  void updatePhase(int playerIdx, int round, int? phase) {
    final player = state[playerIdx];
    player.phases.setPhase(round, phase);
    state = [...state];
  }

  void updatePlayerName(int playerIdx, String name) {
    final player = state[playerIdx];
    state[playerIdx] = Player.withData(
      name: name,
      scores: player.scores,
      phases: player.phases,
    );
    state = [...state];
  }

  void resetGame({bool clearNames = false}) {
    final maxRounds = state.isNotEmpty ? state[0].scores.roundScores.length : 0;
    final numPhases =
        state.isNotEmpty ? state[0].phases.completedPhases.length : 0;
    state = [
      for (int i = 0; i < state.length; i++)
        Player(
          name: clearNames ? 'Player ${i + 1}' : state[i].name,
          maxRounds: maxRounds,
          numPhases: numPhases,
        ),
    ];
  }

  void toggleRoundEnabled(int round, bool enabled) {
    for (var player in state) {
      player.scores.setEnabled(round, enabled);
      player.phases.setEnabled(round, enabled);
    }
    state = [...state];
  }
}
