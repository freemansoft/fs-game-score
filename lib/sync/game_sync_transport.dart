import 'package:fs_score_card/sync/game_sync_protocol.dart';

/// Connection lifecycle for live sync (spectator or host observers).
enum GameSyncConnectionState {
  idle,
  connecting,
  connected,
  reconnecting,
  wrongPin,
  versionMismatch,
  cannotReachHost,
  hostClosed,
  failed,
}

/// Abstraction over LAN WebSocket (v1) and future WebRTC (Option D).
abstract class GameSyncTransport {
  Stream<GameSyncConnectionState> get connectionState;

  Stream<GameSyncSnapshot> get snapshots;

  Future<void> connect({
    required String wsUrl,
    required String pin,
    String? spectatorName,
    String? appVersion,
  });

  Future<void> disconnect();

  Future<void> dispose() async {}
}
