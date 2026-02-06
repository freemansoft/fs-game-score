import 'package:fs_score_card/model/players.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayersRepository {
  factory PlayersRepository() {
    return _instance;
  }

  PlayersRepository._internal();

  static final PlayersRepository _instance = PlayersRepository._internal();

  static const String _playersPrefsKey = 'players_state';

  /// Loaded from shared preferences
  Players? loadedPrefsPlayers;

  Future<void> clearPrefsPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playersPrefsKey);
    loadedPrefsPlayers = null;
  }

  /// Load players state from shared preferences.
  ///
  /// This hack should probably be replaced with AsyncNotifier
  Future<void> loadPlayersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString(_playersPrefsKey);
    if (playersJson != null && playersJson.isNotEmpty) {
      try {
        loadedPrefsPlayers = Players.fromJson(playersJson);
        // We don't know what all the errors could be across platforms
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // If deserialization fails, clear the loaded state
        loadedPrefsPlayers = null;
      }
    } else {
      loadedPrefsPlayers = null;
    }
  }

  /// Save players state to shared preferences.
  Future<void> savePlayersToPrefs(Players players) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playersPrefsKey, players.toJson());
    // save ourselves an extra load cycle
    loadedPrefsPlayers = players;
  }

  Future<void> clearPlayersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playersPrefsKey);
    loadedPrefsPlayers = null;
  }
}
