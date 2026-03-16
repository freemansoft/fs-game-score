import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/data/game_repository.dart';
import 'package:fs_score_card/model/game.dart';

class GameNotifier extends Notifier<Game> {
  @override
  Game build() {
    return GameRepository().loadedPrefsGame ?? Game();
  }

  // is this the pattern or anti pattern and they should use ref.read?
  Game stateValue() => state;

  Future<void> newGame({
    int? maxRounds,
    int? numPlayers,
    GameMode? gameMode,
    String? scoreFilter,
    int? endGameScore,
    String? version,
  }) async {
    state = Game(
      configuration: GameConfiguration(
        maxRounds: maxRounds ?? state.configuration.maxRounds,
        numPlayers: numPlayers ?? state.configuration.numPlayers,
        gameMode: gameMode ?? state.configuration.gameMode,
        scoreFilter: scoreFilter ?? state.configuration.scoreFilter,
        endGameScore: endGameScore ?? state.configuration.endGameScore,
        version: version ?? state.configuration.version,
      ),
      // gameId will be automatically generated as a new UUID
    );
    await GameRepository().saveGameToPrefs(state);
  }

  /// Use this when you want to set the game state loaded from the repository.
  /// Usually called by the repository when loading from prefs.
  // ignore: use_setters_to_change_properties
  void repositoryDidLoadPrefs(Game game) {
    state = game;

    /// do not save because this was probably loaded from prefs
  }
}

final gameProvider = NotifierProvider<GameNotifier, Game>(GameNotifier.new);
