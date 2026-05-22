import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/data/game_repository.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the [GameRepository].
///
/// Watches [sharedPreferencesProvider] to obtain the [SharedPreferences]
/// instance and creates a [GameRepository] with it.
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GameRepository(prefs);
});

class GameNotifier extends Notifier<Game> {
  @override
  Game build() {
    final repository = ref.watch(gameRepositoryProvider);
    return repository.loadGame() ?? Game();
  }

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
    await ref.read(gameRepositoryProvider).saveGame(state);
  }
}

final gameProvider = NotifierProvider<GameNotifier, Game>(GameNotifier.new);
