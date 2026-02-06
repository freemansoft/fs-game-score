import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/data/players_repository.dart';
import 'package:fs_score_card/model/player.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/provider/game_provider.dart';

final playersProvider = NotifierProvider<PlayersNotifier, Players>(
  PlayersNotifier.new,
);

class PlayersNotifier extends Notifier<Players> {
  Timer? _saveTimer;

  @override
  Players build() {
    final game = ref.watch(gameProvider);

    // Check if we have loaded players from repository
    final loadedPlayers = PlayersRepository().loadedPrefsPlayers;

    // If loaded players exist and match game configuration, use them
    if (loadedPlayers != null &&
        loadedPlayers.players.isNotEmpty &&
        loadedPlayers.players.length == game.configuration.numPlayers) {
      final firstPlayer = loadedPlayers.players[0];
      if (firstPlayer.scores.roundScores.length ==
              game.configuration.maxRounds &&
          firstPlayer.phases.completedPhases.length ==
              game.configuration.numPhases) {
        return loadedPlayers;
      }
    }

    // Otherwise create new players based on game configuration
    return Players(
      numPlayers: game.configuration.numPlayers,
      maxRounds: game.configuration.maxRounds,
      numPhases: game.configuration.numPhases,
    );
  }

  /// Schedule a save to repository after 5 seconds of idle time
  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 5), () {
      unawaited(PlayersRepository().savePlayersToPrefs(state));
    });

    /// Cancel any pending save timer on dispose
    ref.onDispose(() {
      _saveTimer?.cancel();
    });
  }

  void updateScore(int playerIdx, int round, int? score) {
    final player = state.players[playerIdx];
    player.scores.setScore(round, score);
    state = state.withPlayer(player, playerIdx);
    _scheduleSave();
  }

  void updatePhase(int playerIdx, int round, int? phase) {
    final player = state.players[playerIdx];
    player.phases.setPhase(round, phase);
    state = state.withPlayer(player, playerIdx);
    _scheduleSave();
  }

  void updatePlayerName(int playerIdx, String name) {
    final player = state.players[playerIdx];
    final updatedPlayer = Player.withData(
      name: name,
      scores: player.scores,
      phases: player.phases,
      roundStates: player.roundStates,
    );
    state = state.withPlayer(updatedPlayer, playerIdx);
    _scheduleSave();
  }

  // used when a new game is started usually via a modal dialog
  void resetGame({bool clearNames = false}) {
    final maxRounds = state.length > 0
        ? state.players[0].scores.roundScores.length
        : 0;
    final numPhases = state.length > 0
        ? state.players[0].phases.completedPhases.length
        : 0;
    final newPlayers = <Player>[];
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
    _scheduleSave();
  }

  void toggleRoundEnabled({required int round, required bool enabled}) {
    var newState = state;
    for (int i = 0; i < state.length; i++) {
      final player = state.players[i];
      player.roundStates.setEnabled(round: round, enabled: enabled);
      newState = newState.withPlayer(player, i);
    }
    state = newState;
    _scheduleSave();
  }
}
