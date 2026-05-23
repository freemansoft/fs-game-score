import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/sync/fake_game_sync_transport.dart';
import 'package:fs_score_card/sync/game_sync_app_version.dart';
import 'package:fs_score_card/sync/game_sync_lan.dart';
import 'package:fs_score_card/sync/game_sync_log.dart';
import 'package:fs_score_card/sync/game_sync_mapper.dart';
import 'package:fs_score_card/sync/game_sync_platform.dart';
import 'package:fs_score_card/sync/game_sync_protocol.dart';
import 'package:fs_score_card/sync/game_sync_qr.dart';
import 'package:fs_score_card/sync/game_sync_transport.dart';

/// Outcome of [GameSyncSpectatorNotifier.connect] after the handshake finishes.
enum GameSyncConnectResult {
  connected,
  wrongPin,
  versionMismatch,
  cannotReachHost,
  hostClosed,
  failed,
  timedOut,
}

/// Spectator-side live sync: connection status + mirrored game state.
class GameSyncSpectatorState {
  const GameSyncSpectatorState({
    this.connectionState = GameSyncConnectionState.idle,
    this.game,
    this.players,
    this.hostDeviceName,
    this.connectedHostIp,
    this.discoveredHosts = const [],
    this.errorMessage,
  });

  final GameSyncConnectionState connectionState;
  final Game? game;
  final Players? players;
  final String? hostDeviceName;
  final String? connectedHostIp;
  final List<DiscoveredGameSyncHost> discoveredHosts;
  final String? errorMessage;

  bool get isConnected =>
      connectionState == GameSyncConnectionState.connected &&
      game != null &&
      players != null;

  GameSyncSpectatorState copyWith({
    GameSyncConnectionState? connectionState,
    Game? game,
    Players? players,
    String? hostDeviceName,
    String? connectedHostIp,
    List<DiscoveredGameSyncHost>? discoveredHosts,
    String? errorMessage,
    bool clearGame = false,
  }) {
    return GameSyncSpectatorState(
      connectionState: connectionState ?? this.connectionState,
      game: clearGame ? null : (game ?? this.game),
      players: clearGame ? null : (players ?? this.players),
      hostDeviceName: hostDeviceName ?? this.hostDeviceName,
      connectedHostIp: connectedHostIp ?? this.connectedHostIp,
      discoveredHosts: discoveredHosts ?? this.discoveredHosts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final gameSyncSpectatorProvider =
    NotifierProvider<GameSyncSpectatorNotifier, GameSyncSpectatorState>(
      GameSyncSpectatorNotifier.new,
    );

/// Override in tests with a factory that returns [FakeGameSyncTransport].
final gameSyncTransportFactoryProvider = Provider<GameSyncTransport Function()>(
  (
    ref,
  ) {
    if (canJoinLiveSync) {
      return createLanGameSyncTransport;
    }
    return FakeGameSyncTransport.new;
  },
);

class GameSyncSpectatorNotifier extends Notifier<GameSyncSpectatorState> {
  GameSyncTransport? _transport;
  StreamSubscription<GameSyncConnectionState>? _connectionSub;
  StreamSubscription<GameSyncSnapshot>? _snapshotSub;

  @override
  GameSyncSpectatorState build() {
    ref.onDispose(_teardown);
    return const GameSyncSpectatorState();
  }

  Future<void> startDiscovery() async {
    await stopDiscovery();
    await startGameSyncDiscovery((hosts) {
      if (!ref.mounted) return;
      state = state.copyWith(discoveredHosts: hosts);
    });
  }

  Future<void> stopDiscovery() async {
    await stopGameSyncDiscovery();
    if (!ref.mounted) return;
    state = state.copyWith(discoveredHosts: []);
  }

  Future<GameSyncConnectResult> connect({
    required String wsUrl,
    required String pin,
    String? spectatorName,
    String? appVersion,
  }) async {
    final connectionInfo = decodeGameSyncConnectionUrl(wsUrl);
    final connectedHostIp = connectionInfo?.host;
    gameSyncLog(
      'GameSyncSpectatorNotifier connect wsUrl=$wsUrl pin=$pin '
      'hostIp=$connectedHostIp',
      name: 'GameSyncSpectatorNotifier',
    );
    await _releaseTransport();
    _transport = ref.read(gameSyncTransportFactoryProvider)();

    final completer = Completer<GameSyncConnectResult>();
    late final Timer timeout;

    void finish(GameSyncConnectResult result) {
      if (completer.isCompleted) return;
      timeout.cancel();
      gameSyncLog(
        'GameSyncSpectatorNotifier connect finished: $result',
        name: 'GameSyncSpectatorNotifier',
      );
      completer.complete(result);
    }

    void finishIfReady() {
      if (state.isConnected) {
        finish(GameSyncConnectResult.connected);
      }
    }

    GameSyncConnectResult? terminalResult(
      GameSyncConnectionState connectionState,
    ) {
      return switch (connectionState) {
        GameSyncConnectionState.wrongPin => GameSyncConnectResult.wrongPin,
        GameSyncConnectionState.versionMismatch =>
          GameSyncConnectResult.versionMismatch,
        GameSyncConnectionState.cannotReachHost =>
          GameSyncConnectResult.cannotReachHost,
        GameSyncConnectionState.hostClosed => GameSyncConnectResult.hostClosed,
        GameSyncConnectionState.failed => GameSyncConnectResult.failed,
        _ => null,
      };
    }

    _connectionSub = _transport!.connectionState.listen((connectionState) {
      if (!ref.mounted) return;
      gameSyncLogConnectionState(
        'GameSyncSpectatorNotifier',
        connectionState,
        previous: state.connectionState,
      );
      state = state.copyWith(
        connectionState: connectionState,
        connectedHostIp: connectedHostIp,
        clearGame:
            connectionState == GameSyncConnectionState.idle ||
            connectionState == GameSyncConnectionState.wrongPin ||
            connectionState == GameSyncConnectionState.versionMismatch ||
            connectionState == GameSyncConnectionState.hostClosed,
      );
      final terminal = terminalResult(connectionState);
      if (terminal != null) {
        finish(terminal);
      }
    });
    _snapshotSub = _transport!.snapshots.listen((snapshot) {
      if (!ref.mounted) return;
      gameSyncLog(
        'GameSyncSpectatorNotifier snapshot revision=${snapshot.revision} '
        'gameId=${snapshot.gameId}',
        name: 'GameSyncSpectatorNotifier',
      );
      final parsed = gameAndPlayersFromSnapshot(snapshot);
      state = state.copyWith(
        game: parsed.game,
        players: parsed.players,
        hostDeviceName: snapshot.hostDeviceName,
        connectedHostIp: connectedHostIp,
        connectionState: GameSyncConnectionState.connected,
      );
      finishIfReady();
    });

    timeout = Timer(const Duration(seconds: 15), () {
      gameSyncLog(
        'GameSyncSpectatorNotifier connect timed out',
        name: 'GameSyncSpectatorNotifier',
      );
      unawaited(_releaseTransport());
      finish(GameSyncConnectResult.timedOut);
    });

    final syncAppVersion =
        appVersion ?? resolveLiveSyncAppVersion(ref.read(gameNotifierProvider));
    try {
      await _transport!.connect(
        wsUrl: wsUrl,
        pin: pin,
        spectatorName: spectatorName,
        appVersion: syncAppVersion,
      );
    } on Object {
      gameSyncLog(
        'GameSyncSpectatorNotifier transport.connect threw',
        name: 'GameSyncSpectatorNotifier',
      );
      finish(GameSyncConnectResult.failed);
    }

    return completer.future;
  }

  Future<GameSyncConnectResult> connectToDiscovered(
    DiscoveredGameSyncHost host,
  ) async {
    final url = wsUrlForDiscoveredHost(host);
    final pin = host.pin;
    if (url == null || pin == null) {
      state = state.copyWith(
        connectionState: GameSyncConnectionState.failed,
        errorMessage: 'missing_connection_info',
      );
      return GameSyncConnectResult.failed;
    }
    return connect(wsUrl: url, pin: pin);
  }

  Future<void> disconnect() async {
    gameSyncLog(
      'GameSyncSpectatorNotifier disconnect',
      name: 'GameSyncSpectatorNotifier',
    );
    await _releaseTransport();
    if (!ref.mounted) return;
    state = const GameSyncSpectatorState();
  }

  Future<void> _teardown() async {
    await stopDiscovery();
    await _releaseTransport();
  }

  Future<void> _releaseTransport() async {
    gameSyncLog(
      'GameSyncSpectatorNotifier release transport',
      name: 'GameSyncSpectatorNotifier',
    );
    await _connectionSub?.cancel();
    await _snapshotSub?.cancel();
    _connectionSub = null;
    _snapshotSub = null;
    await _transport?.dispose();
    _transport = null;
  }
}
