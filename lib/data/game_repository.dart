import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameRepository {
  factory GameRepository() {
    return _instance;
  }

  GameRepository._internal();

  static final GameRepository _instance = GameRepository._internal();

  static const String _gamePrefsKey = 'game_state';

  /// Optional ref used to notify providers after loading from prefs.
  ProviderContainer? _container;

  /// Call this once after [ProviderScope]/[ProviderContainer] is ready.
  /// The repository will use [container] to push loaded state into
  /// [gameProvider] instead of relying on the notifier to poll
  /// [loadedPrefsGame] during its build phase.
  // ignore: use_setters_to_change_properties
  void initialize(ProviderContainer container) {
    _container = container;
  }

  /// Loaded from shared preferences
  Game? loadedPrefsGame;

  /// Load game state from shared preferences.
  ///
  /// This hack should probably be replaced with AsyncNotifier
  Future<void> loadGameFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final gameJson = prefs.getString(_gamePrefsKey);
    if (gameJson != null && gameJson.isNotEmpty) {
      try {
        final gameFromPrefs = Game.fromJson(gameJson);
        loadedPrefsGame = Game(
          configuration: GameConfiguration(
            gameMode: gameFromPrefs.configuration.gameMode,
            endGameScore: gameFromPrefs.configuration.endGameScore,
            maxRounds: gameFromPrefs.configuration.maxRounds,
            numPlayers: gameFromPrefs.configuration.numPlayers,
            scoreFilter: gameFromPrefs.configuration.scoreFilter,
            version: gameFromPrefs.configuration.version,
          ),
        );
        assert(() {
          developer.log(
            'Game loaded from prefs: ${loadedPrefsGame!.toJson()}',
            name: runtimeType.toString(),
          );
          return true;
        }());
        _container
            ?.read(gameProvider.notifier)
            .repositoryDidLoadPrefs(loadedPrefsGame!);
        // We don't know what all the errors could be across platforms
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // If deserialization fails, fall back to a new game
        loadedPrefsGame = Game();
      }
    } else {
      loadedPrefsGame = Game();
      assert(() {
        developer.log(
          'Game not found in prefs. Created new game.',
          name: runtimeType.toString(),
        );
        return true;
      }());
    }
  }

  /// Save game state to shared preferences.
  Future<void> saveGameToPrefs(Game aGame) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gamePrefsKey, aGame.toJson());
    // save ourselves an extra load cycle
    loadedPrefsGame = aGame;
    assert(() {
      developer.log(
        'Game saved to prefs: ${aGame.toJson()}',
        name: runtimeType.toString(),
      );
      return true;
    }());
  }

  Future<void> clearGameFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gamePrefsKey);
    loadedPrefsGame = null;
    assert(() {
      developer.log(
        'Game cleared from prefs',
        name: runtimeType.toString(),
      );
      return true;
    }());
  }
}
