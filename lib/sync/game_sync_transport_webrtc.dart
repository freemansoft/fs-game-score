import 'package:fs_score_card/sync/game_sync_protocol.dart';
import 'package:fs_score_card/sync/game_sync_transport.dart';

/// Placeholder for Option D (cross-network WebRTC). Not used in v1.
class WebRtcGameSyncTransport implements GameSyncTransport {
  @override
  Stream<GameSyncConnectionState> get connectionState =>
      Stream.value(GameSyncConnectionState.failed);

  @override
  Stream<GameSyncSnapshot> get snapshots => const Stream.empty();

  @override
  Future<void> connect({
    required String wsUrl,
    required String pin,
    String? spectatorName,
    String? appVersion,
  }) async {
    throw UnsupportedError('WebRTC live sync is not implemented (Option D).');
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> dispose() async {}
}
