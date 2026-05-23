import 'package:fs_score_card/sync/game_sync_protocol.dart';

/// Encodes a LAN WebSocket connection URL for QR display and manual entry.
///
/// Example: `ws://192.168.1.5:8765?game=uuid&pin=123456`
String encodeGameSyncConnectionUrl({
  required String host,
  required int port,
  required String gameId,
  required String pin,
}) {
  final uri = Uri(
    scheme: 'ws',
    host: host,
    port: port,
    queryParameters: {
      'game': gameId,
      'pin': pin,
    },
  );
  return uri.toString();
}

/// Parsed connection details from a host QR or pasted URL.
class GameSyncConnectionInfo {
  const GameSyncConnectionInfo({
    required this.host,
    required this.port,
    required this.gameId,
    required this.pin,
    required this.wsUrl,
  });

  final String host;
  final int port;
  final String gameId;
  final String pin;
  final String wsUrl;
}

/// Decodes [raw] as `ws://host:port?game=...&pin=...`.
GameSyncConnectionInfo? decodeGameSyncConnectionUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  Uri? uri;
  try {
    uri = Uri.parse(trimmed);
  } on FormatException {
    return null;
  }
  if (uri.scheme != 'ws' && uri.scheme != 'wss') return null;
  final host = uri.host;
  if (host.isEmpty) return null;
  final gameId = uri.queryParameters['game'];
  final pin = uri.queryParameters['pin'];
  if (gameId == null || gameId.isEmpty || pin == null || pin.isEmpty) {
    return null;
  }
  final port = uri.hasPort ? uri.port : gameSyncDefaultPort;
  return GameSyncConnectionInfo(
    host: host,
    port: port,
    gameId: gameId,
    pin: pin,
    wsUrl: uri.replace(port: port).toString(),
  );
}
