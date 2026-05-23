import 'dart:developer' as developer;

import 'package:fs_score_card/sync/game_sync_transport.dart';

const String _gameSyncLogName = 'GameSync';

/// Debug-only log for live game sync (stripped in release builds).
void gameSyncLog(String message, {String? name}) {
  assert(() {
    developer.log(message, name: name ?? _gameSyncLogName);
    return true;
  }());
}

/// Debug-only log when [GameSyncConnectionState] changes.
void gameSyncLogConnectionState(
  String source,
  GameSyncConnectionState state, {
  GameSyncConnectionState? previous,
}) {
  if (previous != null && previous == state) {
    return;
  }
  final transition = previous == null
      ? 'connection state: $state'
      : 'connection state: $previous -> $state';
  gameSyncLog('$source $transition', name: 'GameSyncConnection');
}
