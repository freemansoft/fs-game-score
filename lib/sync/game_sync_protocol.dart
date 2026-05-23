import 'dart:convert';

/// Current wire protocol version for live score sync.
const int gameSyncProtocolVersion = 1;

/// Service type advertised via mDNS (Bonjour).
const String gameSyncServiceType = '_fsscore._tcp';

/// Default WebSocket listen port when hosting.
const int gameSyncDefaultPort = 8765;

/// Message types exchanged over WebSocket (transport-agnostic).
enum GameSyncMessageType {
  hello,
  welcome,
  reject,
  snapshot,
  ping,
  pong,
  hostClosed,
}

/// Full authoritative game state broadcast by the host.
class GameSyncSnapshot {
  const GameSyncSnapshot({
    required this.protocolVersion,
    required this.gameId,
    required this.revision,
    required this.configuration,
    required this.players,
    required this.hostDeviceName,
    this.status = 'playing',
  });

  factory GameSyncSnapshot.fromJson(Map<String, dynamic> json) {
    return GameSyncSnapshot(
      protocolVersion: json['protocolVersion'] as int? ?? 1,
      gameId: json['gameId'] as String,
      revision: json['revision'] as int,
      configuration: Map<String, dynamic>.from(
        json['configuration'] as Map<dynamic, dynamic>,
      ),
      players: (json['players'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
          .toList(),
      hostDeviceName: json['hostDeviceName'] as String? ?? '',
      status: json['status'] as String? ?? 'playing',
    );
  }

  final int protocolVersion;
  final String gameId;
  final int revision;
  final Map<String, dynamic> configuration;
  final List<Map<String, dynamic>> players;
  final String hostDeviceName;
  final String status;

  Map<String, dynamic> toJson() => {
    'protocolVersion': protocolVersion,
    'gameId': gameId,
    'revision': revision,
    'configuration': configuration,
    'players': players,
    'hostDeviceName': hostDeviceName,
    'status': status,
  };
}

/// Parsed inbound or outbound sync message.
class GameSyncMessage {
  const GameSyncMessage({
    required this.type,
    this.pin,
    this.appVersion,
    this.spectatorName,
    this.reason,
    this.snapshot,
  });

  factory GameSyncMessage.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    final type = GameSyncMessageType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => GameSyncMessageType.ping,
    );
    return GameSyncMessage(
      type: type,
      pin: json['pin'] as String?,
      appVersion: json['appVersion'] as String?,
      spectatorName: json['spectatorName'] as String?,
      reason: json['reason'] as String?,
      snapshot: json['snapshot'] != null
          ? GameSyncSnapshot.fromJson(
              Map<String, dynamic>.from(
                json['snapshot'] as Map<dynamic, dynamic>,
              ),
            )
          : null,
    );
  }

  final GameSyncMessageType type;
  final String? pin;
  final String? appVersion;
  final String? spectatorName;
  final String? reason;
  final GameSyncSnapshot? snapshot;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type.name};
    if (pin != null) map['pin'] = pin;
    if (appVersion != null) map['appVersion'] = appVersion;
    if (spectatorName != null) map['spectatorName'] = spectatorName;
    if (reason != null) map['reason'] = reason;
    if (snapshot != null) map['snapshot'] = snapshot!.toJson();
    return map;
  }
}

String encodeGameSyncMessage(GameSyncMessage message) {
  return jsonEncode(message.toJson());
}

GameSyncMessage decodeGameSyncMessage(String raw) {
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  return GameSyncMessage.fromJson(decoded);
}

/// Validates a 6-digit session PIN.
bool isValidGameSyncPin(String? pin) {
  if (pin == null || pin.length != 6) return false;
  return RegExp(r'^\d{6}$').hasMatch(pin);
}

/// Generates a random 6-digit PIN for session admission.
String generateGameSyncPin() {
  final value = DateTime.now().millisecondsSinceEpoch % 1000000;
  return value.toString().padLeft(6, '0');
}

/// Reject reason when the spectator PIN does not match the host session.
const String gameSyncRejectWrongPin = 'wrong_pin';

/// Reject reason when spectator app major version does not match the host.
const String gameSyncRejectVersionMismatch = 'version_mismatch';

/// Major semver segment from an app version (e.g. `1.12.0+236` → `1`).
String? gameSyncAppVersionMajor(String? version) {
  if (version == null || version.isEmpty) {
    return null;
  }
  final core = version.trim().split('+').first.split('-').first;
  final major = core.split('.').firstOrNull;
  if (major == null || major.isEmpty) {
    return null;
  }
  return major;
}

/// True when both sides report the same non-empty app major version.
bool gameSyncAppVersionsMatch(String? hostVersion, String? spectatorVersion) {
  final hostMajor = gameSyncAppVersionMajor(hostVersion);
  final spectatorMajor = gameSyncAppVersionMajor(spectatorVersion);
  if (hostMajor == null || spectatorMajor == null) {
    return false;
  }
  return hostMajor == spectatorMajor;
}
