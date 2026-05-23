import 'package:fs_score_card/sync/fake_game_sync_transport.dart';
import 'package:fs_score_card/sync/game_sync_protocol.dart';
import 'package:fs_score_card/sync/game_sync_transport.dart';

/// Host session metadata when live sharing is active.
class GameSyncHostSession {
  const GameSyncHostSession({
    required this.wsUrl,
    required this.hostIp,
    required this.port,
    required this.pin,
    required this.gameId,
    required this.serviceName,
  });

  final String wsUrl;
  final String hostIp;
  final int port;
  final String pin;
  final String gameId;
  final String serviceName;
}

/// Discovered host on the LAN.
class DiscoveredGameSyncHost {
  const DiscoveredGameSyncHost({
    required this.name,
    required this.host,
    required this.port,
    this.gameId,
    this.pin,
  });

  final String name;
  final String host;
  final int port;
  final String? gameId;
  final String? pin;
}

Future<GameSyncHostSession> startGameSyncHost({
  required GameSyncSnapshot initialSnapshot,
  required String pin,
  required String requiredAppVersion,
}) {
  throw UnsupportedError('LAN live sync is not available on this platform.');
}

Future<void> stopGameSyncHost() async {}

Future<String?> resolveLanIPv4() async => null;

Future<void> startGameSyncDiscovery(
  void Function(List<DiscoveredGameSyncHost> hosts) onUpdated,
) async {}

Future<void> stopGameSyncDiscovery() async {}

void broadcastGameSyncSnapshot(GameSyncSnapshot snapshot) {}

String getHostDeviceName() => 'Score host';

String? wsUrlForDiscoveredHost(DiscoveredGameSyncHost host) => null;

GameSyncTransport createLanGameSyncTransport() => FakeGameSyncTransport();
