import 'package:fs_score_card/model/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameRepository {
  factory GameRepository() {
    return _instance;
  }

  GameRepository._internal();

  static final GameRepository _instance = GameRepository._internal();

  static const String _gamePrefsKey = 'game_state';

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
            enablePhases: gameFromPrefs.configuration.enablePhases,
            endGameScore: gameFromPrefs.configuration.endGameScore,
            maxRounds: gameFromPrefs.configuration.maxRounds,
            numPhases: gameFromPrefs.configuration.numPhases,
            numPlayers: gameFromPrefs.configuration.numPlayers,
            scoreFilter: gameFromPrefs.configuration.scoreFilter,
            version: gameFromPrefs.configuration.version,
          ),
        );
        // We don't know what all the errors could be across platforms
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // If deserialization fails, fall back to a new game
        loadedPrefsGame = Game();
      }
    } else {
      loadedPrefsGame = Game();
    }
  }

  /// Save game state to shared preferences.
  Future<void> saveGameToPrefs(Game aGame) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gamePrefsKey, aGame.toJson());
    // save ourselves an extra load cycle
    loadedPrefsGame = aGame;
  }

  Future<void> clearGameFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gamePrefsKey);
    loadedPrefsGame = null;
  }
}
