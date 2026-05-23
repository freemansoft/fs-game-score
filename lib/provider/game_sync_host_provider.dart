import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:fs_score_card/sync/game_sync_app_version.dart';
import 'package:fs_score_card/sync/game_sync_connection_label.dart';
import 'package:fs_score_card/sync/game_sync_lan.dart';
import 'package:fs_score_card/sync/game_sync_mapper.dart';
import 'package:fs_score_card/sync/game_sync_protocol.dart';

/// Active host session details for the Live Share UI.
class GameSyncHostState {
  const GameSyncHostState({
    this.isHosting = false,
    this.session,
    this.pin,
    this.revision = 0,
    this.errorMessage,
  });

  const GameSyncHostState.idle() : this();

  final bool isHosting;
  final GameSyncHostSession? session;
  final String? pin;
  final int revision;
  final String? errorMessage;

  GameSyncHostState copyWith({
    bool? isHosting,
    GameSyncHostSession? session,
    String? pin,
    int? revision,
    String? errorMessage,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return GameSyncHostState(
      isHosting: isHosting ?? this.isHosting,
      session: clearSession ? null : (session ?? this.session),
      pin: pin ?? this.pin,
      revision: revision ?? this.revision,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final gameSyncHostProvider =
    NotifierProvider<GameSyncHostNotifier, GameSyncHostState>(
      GameSyncHostNotifier.new,
    );

class GameSyncHostNotifier extends Notifier<GameSyncHostState> {
  ProviderSubscription<Game>? _gameSub;
  ProviderSubscription<Players>? _playersSub;

  @override
  GameSyncHostState build() {
    ref.onDispose(_stopHosting);
    return const GameSyncHostState.idle();
  }

  Future<void> startHosting() async {
    if (state.isHosting) return;
    final game = ref.read(gameNotifierProvider);
    final players = ref.read(playersNotifierProvider);
    final pin = generateGameSyncPin();
    final requiredAppVersion = resolveLiveSyncAppVersion(game);
    if (requiredAppVersion == null) {
      state = const GameSyncHostState(
        errorMessage: 'live_sync_app_version_unknown',
      );
      return;
    }
    final snapshot = snapshotFromGame(
      game: game,
      players: players,
      revision: 1,
      hostDeviceName: liveSyncConnectionLabel(gameId: game.gameId),
    );
    try {
      final session = await startGameSyncHost(
        initialSnapshot: snapshot,
        pin: pin,
        requiredAppVersion: requiredAppVersion,
      );
      state = GameSyncHostState(
        isHosting: true,
        session: session,
        pin: pin,
        revision: 1,
      );
      _attachListeners();
      broadcastCurrentState();
    } on Object catch (e) {
      state = GameSyncHostState(
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> stopHosting() async {
    await _stopHosting();
    state = const GameSyncHostState.idle();
  }

  Future<void> _stopHosting() async {
    _gameSub?.close();
    _playersSub?.close();
    _gameSub = null;
    _playersSub = null;
    await stopGameSyncHost();
  }

  void _attachListeners() {
    _gameSub?.close();
    _playersSub?.close();
    _gameSub = ref.listen(gameNotifierProvider, (_, _) {
      broadcastCurrentState();
    });
    _playersSub = ref.listen(playersNotifierProvider, (_, _) {
      broadcastCurrentState();
    });
  }

  void broadcastCurrentState() {
    if (!state.isHosting) return;
    final game = ref.read(gameNotifierProvider);
    final players = ref.read(playersNotifierProvider);
    final nextRevision = state.revision + 1;
    final snapshot = snapshotFromGame(
      game: game,
      players: players,
      revision: nextRevision,
      hostDeviceName: liveSyncConnectionLabel(
        gameId: game.gameId,
        hostIp: state.session?.hostIp,
      ),
    );
    broadcastGameSyncSnapshot(snapshot);
    state = state.copyWith(revision: nextRevision);
  }
}
