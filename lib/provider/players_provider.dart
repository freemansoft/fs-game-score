import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/data/players_repository.dart';
import 'package:fs_score_card/model/french_driving_round_attributes.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/player.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';

/// Idle time before persisting player edits during gameplay.
const Duration kPlayersSaveDebounceDuration = Duration(seconds: 3);

/// Returns true when persisted [players] dimensions match [config].
///
/// Used by `PlayersNotifier.build` and `initialLocation` for resume routing.
/// Compares round list lengths to `maxRounds`, not `numPhases`.
bool playersMatchConfiguration(Players players, GameConfiguration config) {
  if (players.players.isEmpty) {
    return false;
  }
  if (players.players.length != config.numPlayers) {
    return false;
  }
  final firstPlayer = players.players[0];
  return firstPlayer.scores.roundScores.length == config.maxRounds &&
      firstPlayer.phases.completedPhases.length == config.maxRounds;
}

/// Supplies a [PlayersRepository] wired to [sharedPreferencesProvider].
///
/// Stateless persistence only — use [playersNotifierProvider] for the live roster.
final playersRepositoryProvider = Provider<PlayersRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PlayersRepository(prefs);
});

/// Live [Players] roster (scores, names, phases, round locks).
///
/// Widgets should `ref.watch` this provider or `ref.read` its notifier for
/// mutations. Debounced saves run from mutation methods only, not from `build`.
final playersNotifierProvider = NotifierProvider<PlayersNotifier, Players>(
  PlayersNotifier.new,
);

/// Manages player data; watches [gameNotifierProvider] and restores from disk in [build].
///
/// Do not schedule saves or timers in [build] — use [_scheduleSave] from mutators.
class PlayersNotifier extends Notifier<Players> {
  Timer? _saveTimer;
  int _persistGeneration = 0;
  Future<void>? _splashEntryInProgress;

  @override
  Players build() {
    final game = ref.watch(gameNotifierProvider);
    final repository = ref.watch(playersRepositoryProvider);

    // Register a dispose callback once to immediately flush state
    // if timer is active
    ref.onDispose(() {
      if (_saveTimer?.isActive ?? false) {
        _saveTimer?.cancel();
        final generation = _persistGeneration;
        unawaited(() async {
          if (generation == _persistGeneration) {
            await repository.savePlayers(state);
          }
        }());
      }
    });

    // Check if we have loaded players from repository
    final loadedPlayers = repository.loadPlayers();

    // If loaded players exist and match game configuration, use them
    if (loadedPlayers != null &&
        playersMatchConfiguration(loadedPlayers, game.configuration)) {
      return loadedPlayers;
    }

    // Otherwise create new players based on game configuration
    return Players(
      numPlayers: game.configuration.numPlayers,
      maxRounds: game.configuration.maxRounds,
    );
  }

  /// Clears persisted players and resets in-memory roster when the splash screen
  /// is shown. Cancels any pending debounced save so gameplay scores are not
  /// written back to disk after [PlayersRepository.clearPlayers].
  ///
  /// Safe to call multiple times; concurrent callers share one in-flight future.
  Future<void> prepareForSplashEntry() async {
    if (_splashEntryInProgress != null) {
      return _splashEntryInProgress;
    }
    final future = _prepareForSplashEntryImpl();
    _splashEntryInProgress = future;
    try {
      await future;
    } finally {
      if (identical(_splashEntryInProgress, future)) {
        _splashEntryInProgress = null;
      }
    }
  }

  Future<void> _prepareForSplashEntryImpl() async {
    _persistGeneration++;
    _saveTimer?.cancel();
    _saveTimer = null;
    await ref.read(playersRepositoryProvider).clearPlayers();
    final game = ref.read(gameNotifierProvider);
    state = Players(
      numPlayers: game.configuration.numPlayers,
      maxRounds: game.configuration.maxRounds,
    );
  }

  /// Schedule a save to repository after [kPlayersSaveDebounceDuration] of idle time
  void _scheduleSave() {
    _saveTimer?.cancel();
    final generation = _persistGeneration;
    _saveTimer = Timer(kPlayersSaveDebounceDuration, () {
      if (generation != _persistGeneration) {
        return;
      }
      unawaited(ref.read(playersRepositoryProvider).savePlayers(state));
    });
  }

  void updateScore(int playerIdx, int round, int? score) {
    final player = state.players[playerIdx].copyWith();
    player.scores.setScore(round, score);
    state = state.withPlayer(player, playerIdx);
    _scheduleSave();
  }

  void updateFrenchDrivingAttributes(
    int playerIdx,
    int round,
    FrenchDrivingRoundAttributes attributes,
  ) {
    final player = state.players[playerIdx].copyWith();
    player.frenchDrivingAttributes[round] = attributes;
    player.scores.setScore(round, attributes.calculateScore());
    state = state.withPlayer(player, playerIdx);
    _scheduleSave();
  }

  void updatePhase(int playerIdx, int round, int? phase) {
    final player = state.players[playerIdx].copyWith();
    player.phases.setPhase(round, phase);
    state = state.withPlayer(player, playerIdx);
    _scheduleSave();
  }

  void updatePlayerName(int playerIdx, String name) {
    final player = state.players[playerIdx].copyWith(name: name);
    state = state.withPlayer(player, playerIdx);
    _scheduleSave();
  }

  // used when a new game is started usually via a modal dialog
  void resetGame({bool clearNames = false}) {
    final maxRounds = state.length > 0
        ? state.players[0].scores.roundScores.length
        : 0;
    final newPlayers = <Player>[];
    for (int i = 0; i < state.length; i++) {
      final oldPlayer = state.players[i];
      final newName = clearNames ? 'Player ${i + 1}' : oldPlayer.name;
      final newPlayer = Player(
        name: newName,
        maxRounds: maxRounds,
      );
      newPlayers.add(newPlayer);
    }
    state = Players(
      numPlayers: state.length,
      maxRounds: maxRounds,
      initialPlayers: newPlayers,
    );
    _scheduleSave();
  }

  void toggleRoundEnabled({required int round, required bool enabled}) {
    var newState = state;
    for (int i = 0; i < state.length; i++) {
      final player = state.players[i].copyWith();
      player.roundStates.setEnabled(round: round, enabled: enabled);
      newState = newState.withPlayer(player, i);
    }
    state = newState;
    _scheduleSave();
  }
}
