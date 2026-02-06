import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/data/game_repository.dart';
import 'package:fs_score_card/model/game.dart';

class GameNotifier extends Notifier<Game> {
  @override
  Game build() {
    state = GameRepository().loadedPrefsGame ?? Game();
    return state;
  }

  Game stateValue() => state;

  Future<void> newGame({
    int? maxRounds,
    int? numPhases,
    int? numPlayers,
    bool? enablePhases,
    String? scoreFilter,
    int? endGameScore,
    String? version,
  }) async {
    state = Game(
      configuration: GameConfiguration(
        maxRounds: maxRounds ?? state.configuration.maxRounds,
        numPhases: numPhases ?? state.configuration.numPhases,
        numPlayers: numPlayers ?? state.configuration.numPlayers,
        enablePhases: enablePhases ?? state.configuration.enablePhases,
        scoreFilter: scoreFilter ?? state.configuration.scoreFilter,
        endGameScore: endGameScore ?? state.configuration.endGameScore,
        version: version ?? state.configuration.version,
      ),
      // gameId will be automatically generated as a new UUID
    );
    await GameRepository().saveGameToPrefs(state);
  }
}

final gameProvider = NotifierProvider<GameNotifier, Game>(GameNotifier.new);
