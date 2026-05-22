import 'dart:developer' as developer;

import 'package:fs_score_card/model/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting [Game] configuration using [SharedPreferences].
///
/// Instances are created via `gameRepositoryProvider` and receive their
/// [SharedPreferences] dependency through the constructor, enabling clean
/// testability and eliminating the need for singleton global state.
class GameRepository {
  GameRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _gamePrefsKey = 'game_state';

  /// Synchronously load the game from shared preferences.
  /// Returns `null` if no game was found or deserialization fails.
  Game? loadGame() {
    final gameJson = _prefs.getString(_gamePrefsKey);
    if (gameJson != null && gameJson.isNotEmpty) {
      try {
        final gameFromPrefs = Game.fromJson(gameJson);
        final loaded = Game(
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
            'Game loaded from prefs: ${loaded.toJson()}',
            name: runtimeType.toString(),
          );
          return true;
        }());
        return loaded;
        // We don't know what all the errors could be across platforms
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // If deserialization fails, fall back to null
        return null;
      }
    } else {
      assert(() {
        developer.log(
          'Game not found in prefs.',
          name: runtimeType.toString(),
        );
        return true;
      }());
      return null;
    }
  }

  /// Save game state to shared preferences.
  Future<void> saveGame(Game aGame) async {
    await _prefs.setString(_gamePrefsKey, aGame.toJson());
    assert(() {
      developer.log(
        'Game saved to prefs: ${aGame.toJson()}',
        name: runtimeType.toString(),
      );
      return true;
    }());
  }

  /// Clear game state from shared preferences.
  Future<void> clearGame() async {
    await _prefs.remove(_gamePrefsKey);
    assert(() {
      developer.log(
        'Game cleared from prefs',
        name: runtimeType.toString(),
      );
      return true;
    }());
  }
}
