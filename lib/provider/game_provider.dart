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

  void newGame({
    int? maxRounds,
    int? numPhases,
    int? numPlayers,
    bool? enablePhases,
    String? scoreFilter,
    int? endGameScore,
    String? version,
  }) {
    state = Game(
      maxRounds: maxRounds ?? state.maxRounds,
      numPhases: numPhases ?? state.numPhases,
      numPlayers: numPlayers ?? state.numPlayers,
      enablePhases: enablePhases ?? state.enablePhases,
      scoreFilter: scoreFilter ?? state.scoreFilter,
      endGameScore: endGameScore ?? state.endGameScore,
      version: version ?? state.version,
      // gameId will be automatically generated as a new UUID
    );
    unawaited(GameRepository().saveGameToPrefs(state));
  }
}

final gameProvider = NotifierProvider<GameNotifier, Game>(GameNotifier.new);
