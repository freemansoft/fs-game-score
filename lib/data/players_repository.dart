import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayersRepository {
  factory PlayersRepository() {
    return _instance;
  }

  PlayersRepository._internal();

  static final PlayersRepository _instance = PlayersRepository._internal();

  static const String _playersPrefsKey = 'players_state';

  /// Optional ref used to notify providers after loading from prefs.
  ProviderContainer? _container;

  /// Call this once after [ProviderScope]/[ProviderContainer] is ready.
  /// The repository will use [container] to push loaded state into
  /// [playersProvider] instead of relying on the notifier to poll
  /// [loadedPrefsPlayers] during its build phase.
  // ignore: use_setters_to_change_properties
  void initialize(ProviderContainer container) {
    _container = container;
  }

  /// Loaded from shared preferences
  Players? loadedPrefsPlayers;

  Future<void> clearPrefsPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playersPrefsKey);
    loadedPrefsPlayers = null;
    assert(() {
      developer.log(
        'Players cleared from prefs',
        name: runtimeType.toString(),
      );
      return true;
    }());
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
        assert(() {
          developer.log(
            'Players loaded from prefs: ' /*${loadedPrefsPlayers!.toJson()}*/,
            name: runtimeType.toString(),
          );
          return true;
        }());
        _container
            ?.read(playersProvider.notifier)
            .repositoryDidLoadPrefs(loadedPrefsPlayers!);
        // We don't know what all the errors could be across platforms
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // If deserialization fails, clear the loaded state
        loadedPrefsPlayers = null;
      }
    } else {
      loadedPrefsPlayers = null;
      assert(() {
        developer.log(
          'Players not found in prefs. Created new players.',
          name: runtimeType.toString(),
        );
        return true;
      }());
    }
  }

  /// Save players state to shared preferences.
  Future<void> savePlayersToPrefs(Players players) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playersPrefsKey, players.toJson());
    // save ourselves an extra load cycle
    loadedPrefsPlayers = players;
    assert(() {
      developer.log(
        'Players saved to prefs: ' /*${players.toJson()}*/,
        name: runtimeType.toString(),
      );
      return true;
    }());
  }

  Future<void> clearPlayersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playersPrefsKey);
    loadedPrefsPlayers = null;
    assert(() {
      developer.log(
        'Players cleared from prefs',
        name: runtimeType.toString(),
      );
      return true;
    }());
  }
}
