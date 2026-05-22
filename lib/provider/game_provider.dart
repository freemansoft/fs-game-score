import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/data/game_repository.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';

/// Supplies a [GameRepository] wired to [sharedPreferencesProvider].
///
/// Stateless persistence only — use [gameNotifierProvider] for live game state.
/// See `docs/State-Management.md`.
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GameRepository(prefs);
});

/// Live [Game] session (configuration + [Game.gameId]).
///
/// Widgets should `ref.watch` this provider or `ref.read` its notifier for
/// actions. Do not read [gameRepositoryProvider] from UI code.
final gameNotifierProvider = NotifierProvider<GameNotifier, Game>(
  GameNotifier.new,
);

/// Holds and mutates the active [Game]; restores from disk in [build].
class GameNotifier extends Notifier<Game> {
  @override
  Game build() {
    final repository = ref.watch(gameRepositoryProvider);
    return repository.loadGame() ?? Game();
  }

  /// Replaces the in-memory game (new [Game.gameId]) and persists configuration.
  ///
  /// Call from UI via `ref.read(gameNotifierProvider.notifier).newGame(...)`.
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
