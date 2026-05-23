import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:fs_score_card/sync/game_sync_log.dart';
import 'package:fs_score_card/sync/game_sync_protocol.dart';
import 'package:fs_score_card/sync/game_sync_qr.dart';
import 'package:fs_score_card/sync/game_sync_transport.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

HttpServer? _hostServer;
BonsoirBroadcast? _broadcast;
final Set<WebSocketChannel> _hostClients = {};
String? _hostPin;
String? _hostRequiredAppVersion;
GameSyncSnapshot? _latestSnapshot;
Timer? _hostPingTimer;

Future<String?> resolveLanIPv4() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      if (!addr.isLoopback) {
        return addr.address;
      }
    }
  }
  return null;
}

Future<GameSyncHostSession> startGameSyncHost({
  required GameSyncSnapshot initialSnapshot,
  required String pin,
  required String requiredAppVersion,
}) async {
  await stopGameSyncHost();
  _hostPin = pin;
  _hostRequiredAppVersion = requiredAppVersion;
  _latestSnapshot = initialSnapshot;

  final hostIp = await resolveLanIPv4();
  if (hostIp == null) {
    throw StateError('Could not determine LAN IPv4 address');
  }

  final handler = webSocketHandler((channel, _) {
    unawaited(_handleHostClient(channel));
  });

  _hostServer = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    gameSyncDefaultPort,
  );
  final port = _hostServer!.port;

  final serviceName = 'fs-score-${initialSnapshot.gameId.substring(0, 8)}';
  final service = BonsoirService(
    name: serviceName,
    type: gameSyncServiceType,
    port: port,
    attributes: {
      'gameId': initialSnapshot.gameId,
      'pin': pin,
    },
  );
  _broadcast = BonsoirBroadcast(service: service);
  await _broadcast!.initialize();
  await _broadcast!.start();

  final wsUrl = encodeGameSyncConnectionUrl(
    host: hostIp,
    port: port,
    gameId: initialSnapshot.gameId,
    pin: pin,
  );

  _hostPingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    _broadcastSnapshotToClients();
  });

  return GameSyncHostSession(
    wsUrl: wsUrl,
    hostIp: hostIp,
    port: port,
    pin: pin,
    gameId: initialSnapshot.gameId,
    serviceName: serviceName,
  );
}

Future<void> _handleHostClient(WebSocketChannel channel) async {
  var admitted = false;
  try {
    await for (final raw in channel.stream) {
      if (raw is! String) continue;
      GameSyncMessage message;
      try {
        message = decodeGameSyncMessage(raw);
      } on Object {
        continue;
      }
      switch (message.type) {
        case GameSyncMessageType.hello:
          if (!isValidGameSyncPin(message.pin) || message.pin != _hostPin) {
            channel.sink.add(
              encodeGameSyncMessage(
                const GameSyncMessage(
                  type: GameSyncMessageType.reject,
                  reason: gameSyncRejectWrongPin,
                ),
              ),
            );
            await channel.sink.close();
            return;
          }
          if (!gameSyncAppVersionsMatch(
            _hostRequiredAppVersion,
            message.appVersion,
          )) {
            channel.sink.add(
              encodeGameSyncMessage(
                const GameSyncMessage(
                  type: GameSyncMessageType.reject,
                  reason: gameSyncRejectVersionMismatch,
                ),
              ),
            );
            await channel.sink.close();
            return;
          }
          admitted = true;
          _hostClients.add(channel);
          channel.sink.add(
            encodeGameSyncMessage(
              GameSyncMessage(
                type: GameSyncMessageType.welcome,
                appVersion: _hostRequiredAppVersion,
              ),
            ),
          );
          final snapshot = _latestSnapshot;
          if (snapshot != null) {
            channel.sink.add(
              encodeGameSyncMessage(
                GameSyncMessage(
                  type: GameSyncMessageType.snapshot,
                  snapshot: snapshot,
                ),
              ),
            );
          }
        case GameSyncMessageType.ping:
          if (admitted) {
            channel.sink.add(
              encodeGameSyncMessage(
                const GameSyncMessage(type: GameSyncMessageType.pong),
              ),
            );
          }
        case GameSyncMessageType.welcome:
        case GameSyncMessageType.reject:
        case GameSyncMessageType.snapshot:
        case GameSyncMessageType.pong:
        case GameSyncMessageType.hostClosed:
          break;
      }
    }
  } finally {
    _hostClients.remove(channel);
  }
}

void broadcastGameSyncSnapshot(GameSyncSnapshot snapshot) {
  _latestSnapshot = snapshot;
  _broadcastSnapshotToClients();
}

void _broadcastSnapshotToClients() {
  final snapshot = _latestSnapshot;
  if (snapshot == null) return;
  final payload = encodeGameSyncMessage(
    GameSyncMessage(type: GameSyncMessageType.snapshot, snapshot: snapshot),
  );
  for (final client in List<WebSocketChannel>.from(_hostClients)) {
    try {
      client.sink.add(payload);
    } on Object {
      _hostClients.remove(client);
    }
  }
}

Future<void> stopGameSyncHost() async {
  _hostPingTimer?.cancel();
  _hostPingTimer = null;
  for (final client in List<WebSocketChannel>.from(_hostClients)) {
    try {
      client.sink.add(
        encodeGameSyncMessage(
          const GameSyncMessage(type: GameSyncMessageType.hostClosed),
        ),
      );
      await client.sink.close();
    } on Object {
      // ignore close errors
    }
  }
  _hostClients.clear();
  await _broadcast?.stop();
  _broadcast = null;
  await _hostServer?.close(force: true);
  _hostServer = null;
  _hostPin = null;
  _hostRequiredAppVersion = null;
  _latestSnapshot = null;
}

BonsoirDiscovery? _discovery;
final Map<String, DiscoveredGameSyncHost> _discovered = {};
void Function(List<DiscoveredGameSyncHost> hosts)? _discoveryCallback;
StreamSubscription<BonsoirDiscoveryEvent>? _discoverySub;

Future<void> startGameSyncDiscovery(
  void Function(List<DiscoveredGameSyncHost> hosts) onUpdated,
) async {
  await stopGameSyncDiscovery();
  _discoveryCallback = onUpdated;
  _discovered.clear();
  _discovery = BonsoirDiscovery(type: gameSyncServiceType);
  await _discovery!.initialize();
  _discoverySub = _discovery!.eventStream?.listen((event) async {
    if (event is BonsoirDiscoveryServiceFoundEvent) {
      try {
        await event.service.resolve(_discovery!.serviceResolver);
      } on Object {
        return;
      }
    } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
      final service = event.service;
      final host = service.hostAddress;
      if (host == null || host.isEmpty) return;
      final attrs = service.attributes;
      _discovered[service.name] = DiscoveredGameSyncHost(
        name: service.name,
        host: host,
        port: service.port,
        gameId: attrs['gameId'],
        pin: attrs['pin'],
      );
      _notifyDiscoveryListeners();
    } else if (event is BonsoirDiscoveryServiceLostEvent) {
      _discovered.remove(event.service.name);
      _notifyDiscoveryListeners();
    }
  });
  await _discovery!.start();
}

void _notifyDiscoveryListeners() {
  final callback = _discoveryCallback;
  if (callback == null) return;
  callback(_discovered.values.toList());
}

Future<void> stopGameSyncDiscovery() async {
  _discoveryCallback = null;
  await _discoverySub?.cancel();
  _discoverySub = null;
  await _discovery?.stop();
  _discovery = null;
  _discovered.clear();
}

GameSyncTransport createLanGameSyncTransport() => LanWsGameSyncTransport();

/// Spectator WebSocket client (Option A).
class LanWsGameSyncTransport implements GameSyncTransport {
  LanWsGameSyncTransport();

  final _connectionController =
      StreamController<GameSyncConnectionState>.broadcast();
  final _snapshotController = StreamController<GameSyncSnapshot>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  String? _wsUrl;
  String? _pin;
  String? _spectatorName;
  String? _appVersion;
  var _intentionalDisconnect = false;
  var _reconnectAttempts = 0;
  GameSyncConnectionState? _loggedConnectionState;
  static const _maxReconnectAttempts = 5;

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
      'LanWsGameSyncTransport connect wsUrl=$wsUrl pin=$pin '
      'appVersion=$appVersion',
      name: 'LanWsGameSyncTransport',
    );
    _intentionalDisconnect = false;
    _reconnectAttempts = 0;
    _wsUrl = wsUrl;
    _pin = pin;
    _spectatorName = spectatorName;
    _appVersion = appVersion;
    await _openSocket();
  }

  Future<void> _openSocket() async {
    final url = _wsUrl;
    final pin = _pin;
    if (url == null || pin == null) return;
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _channel?.sink.close();
    } on Object {
      // ignore close errors from a previous socket
    }
    _channel = null;
    _setState(
      _reconnectAttempts > 0
          ? GameSyncConnectionState.reconnecting
          : GameSyncConnectionState.connecting,
    );
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: (_) => _handleDisconnect(),
        onDone: _handleDisconnect,
      );
      _channel!.sink.add(
        encodeGameSyncMessage(
          GameSyncMessage(
            type: GameSyncMessageType.hello,
            pin: pin,
            spectatorName: _spectatorName ?? 'Spectator',
            appVersion: _appVersion,
          ),
        ),
      );
    } on Object {
      _setState(GameSyncConnectionState.cannotReachHost);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    if (_intentionalDisconnect || _connectionController.isClosed) return;
    if (raw is! String) return;
    GameSyncMessage message;
    try {
      message = decodeGameSyncMessage(raw);
    } on Object {
      return;
    }
    switch (message.type) {
      case GameSyncMessageType.reject:
        _setState(
          message.reason == gameSyncRejectVersionMismatch
              ? GameSyncConnectionState.versionMismatch
              : GameSyncConnectionState.wrongPin,
        );
        unawaited(disconnect());
      case GameSyncMessageType.welcome:
        if (!gameSyncAppVersionsMatch(_appVersion, message.appVersion)) {
          _setState(GameSyncConnectionState.versionMismatch);
          unawaited(disconnect());
          return;
        }
        _reconnectAttempts = 0;
        _setState(GameSyncConnectionState.connected);
      case GameSyncMessageType.snapshot:
        final snapshot = message.snapshot;
        if (snapshot != null) {
          _emitSnapshot(snapshot);
          if (_connectionController.hasListener) {
            _setState(GameSyncConnectionState.connected);
          }
        }
      case GameSyncMessageType.hostClosed:
        _setState(GameSyncConnectionState.hostClosed);
        unawaited(disconnect());
      case GameSyncMessageType.pong:
        break;
      case GameSyncMessageType.hello:
      case GameSyncMessageType.ping:
        break;
    }
  }

  void _handleDisconnect() {
    if (_intentionalDisconnect) return;
    _setState(GameSyncConnectionState.cannotReachHost);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        _setState(GameSyncConnectionState.failed);
      }
      return;
    }
    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      unawaited(_openSocket());
    });
  }

  void _setState(GameSyncConnectionState state) {
    gameSyncLogConnectionState(
      'LanWsGameSyncTransport',
      state,
      previous: _loggedConnectionState,
    );
    _loggedConnectionState = state;
    if (!_connectionController.isClosed) {
      _connectionController.add(state);
    }
  }

  void _emitSnapshot(GameSyncSnapshot snapshot) {
    if (!_snapshotController.isClosed) {
      _snapshotController.add(snapshot);
    }
  }

  @override
  Future<void> disconnect() async {
    gameSyncLog(
      'LanWsGameSyncTransport disconnect',
      name: 'LanWsGameSyncTransport',
    );
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _channel?.sink.close();
    } on Object {
      // ignore close errors
    }
    _channel = null;
    _setState(GameSyncConnectionState.idle);
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _connectionController.close();
    await _snapshotController.close();
  }
}

String getHostDeviceName() {
  try {
    return Platform.localHostname;
  } on Object {
    return 'Score host';
  }
}

/// Builds ws URL from discovery entry when attributes are present.
String? wsUrlForDiscoveredHost(DiscoveredGameSyncHost host) {
  final gameId = host.gameId;
  final pin = host.pin;
  if (gameId == null || pin == null) return null;
  return encodeGameSyncConnectionUrl(
    host: host.host,
    port: host.port,
    gameId: gameId,
    pin: pin,
  );
}
