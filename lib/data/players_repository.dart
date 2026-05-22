import 'dart:developer' as developer;

import 'package:fs_score_card/model/players.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting [Players] state using [SharedPreferences].
///
/// Instances are created via `playersRepositoryProvider` and receive their
/// [SharedPreferences] dependency through the constructor, enabling clean
/// testability and eliminating the need for singleton global state.
class PlayersRepository {
  PlayersRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _playersPrefsKey = 'players_state';

  /// Synchronously load the players from shared preferences.
  /// Returns `null` if no players were found or deserialization fails.
  Players? loadPlayers() {
    final playersJson = _prefs.getString(_playersPrefsKey);
    if (playersJson != null && playersJson.isNotEmpty) {
      try {
        final loaded = Players.fromJson(playersJson);
        assert(() {
          developer.log(
            'Players loaded from prefs.',
            name: runtimeType.toString(),
          );
          return true;
        }());
        return loaded;
        // We don't know what all the errors could be across platforms
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // If deserialization fails, clear the loaded state
        return null;
      }
    } else {
      assert(() {
        developer.log(
          'Players not found in prefs.',
          name: runtimeType.toString(),
        );
        return true;
      }());
      return null;
    }
  }

  /// Save players state to shared preferences.
  Future<void> savePlayers(Players players) async {
    await _prefs.setString(_playersPrefsKey, players.toJson());
    assert(() {
      developer.log(
        'Players saved to prefs.',
        name: runtimeType.toString(),
      );
      return true;
    }());
  }

  /// Clear players state from shared preferences.
  Future<void> clearPlayers() async {
    await _prefs.remove(_playersPrefsKey);
    assert(() {
      developer.log(
        'Players cleared from prefs',
        name: runtimeType.toString(),
      );
      return true;
    }());
  }
}
