import 'dart:async';

import 'package:fs_score_card/sync/game_sync_log.dart';
import 'package:fs_score_card/sync/game_sync_protocol.dart';
import 'package:fs_score_card/sync/game_sync_transport.dart';

/// In-memory transport for unit/widget tests (no real network).
class FakeGameSyncTransport implements GameSyncTransport {
  final _connectionController =
      StreamController<GameSyncConnectionState>.broadcast();
  final _snapshotController = StreamController<GameSyncSnapshot>.broadcast();

  GameSyncConnectionState _state = GameSyncConnectionState.idle;
  GameSyncConnectionState? _loggedConnectionState;
  bool pinAccepted = true;
  bool appVersionAccepted = true;
  String? expectedHostAppVersion;

  @override
  Stream<GameSyncConnectionState> get connectionState =>
      _connectionController.stream;

  @override
  Stream<GameSyncSnapshot> get snapshots => _snapshotController.stream;

  @override
  Future<void> connect({
    required String wsUrl,
    required String pin,
    String? spectatorName,
    String? appVersion,
  }) async {
    gameSyncLog(
      'FakeGameSyncTransport connect wsUrl=$wsUrl pin=$pin',
      name: 'FakeGameSyncTransport',
    );
    _setState(GameSyncConnectionState.connecting);
    await Future<void>.delayed(Duration.zero);
    if (!pinAccepted) {
      _setState(GameSyncConnectionState.wrongPin);
      return;
    }
    if (!appVersionAccepted ||
        !gameSyncAppVersionsMatch(expectedHostAppVersion, appVersion)) {
      _setState(GameSyncConnectionState.versionMismatch);
      return;
    }
    _setState(GameSyncConnectionState.connected);
  }

  void emitSnapshot(GameSyncSnapshot snapshot) {
    if (!_snapshotController.isClosed) {
      _snapshotController.add(snapshot);
    }
  }

  void emitState(GameSyncConnectionState state) => _setState(state);

  void _setState(GameSyncConnectionState state) {
    _state = state;
    gameSyncLogConnectionState(
      'FakeGameSyncTransport',
      state,
      previous: _loggedConnectionState,
    );
    _loggedConnectionState = state;
    if (!_connectionController.isClosed) {
      _connectionController.add(state);
    }
  }

  @override
  Future<void> disconnect() async {
    gameSyncLog(
      'FakeGameSyncTransport disconnect',
      name: 'FakeGameSyncTransport',
    );
    _setState(GameSyncConnectionState.idle);
  }

  @override
  Future<void> dispose() async {
    await _connectionController.close();
    await _snapshotController.close();
  }

  GameSyncConnectionState get currentState => _state;
}
