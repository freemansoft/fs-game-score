import 'dart:convert';
import 'package:uuid/uuid.dart';

// Game configuration model for Phase 10
class Game {
  /// Serializes the game configuration to a JSON string.
  /// This is useful for saving and loading game state.
  String toJson() {
    return _encodeJson({
      'maxRounds': maxRounds,
      'numPhases': numPhases,
      'numPlayers': numPlayers,
      'enablePhases': enablePhases,
      'scoreFilter': scoreFilter,
      'version': version,
    });
  }

  /// Creates a Game instance from a JSON string.
  /// If a key is missing, it uses default values.
  /// Note: gameId is not deserialized - each load creates a new game instance with a fresh UUID.
  factory Game.fromJson(String jsonString) {
    final json = _decodeJson(jsonString);
    return Game(
      maxRounds: json['maxRounds'] ?? 14,
      numPhases: json['numPhases'] ?? 10,
      numPlayers: json['numPlayers'] ?? 8,
      enablePhases: json['enablePhases'] ?? true,
      scoreFilter: json['scoreFilter'] ?? '',
      version: json['version'],
      // gameId is intentionally omitted - will generate new UUID via constructor
    );
  }

  static Map<String, dynamic> _decodeJson(String jsonString) {
    return jsonString.isNotEmpty
        ? Map<String, dynamic>.from(jsonDecode(jsonString))
        : {};
  }

  static String _encodeJson(Map<String, dynamic> map) {
    return jsonEncode(map);
  }

  final int maxRounds;
  final int numPhases;
  final int numPlayers;
  final bool enablePhases;
  final String scoreFilter;
  final String? version; // initialized from app version - stored in prefs
  final String gameId; // the gameId is really a game session id

  Game({
    this.maxRounds = 14,
    this.numPhases = 10,
    this.numPlayers = 8,
    this.enablePhases = true,
    this.scoreFilter = '',
    this.version = '0.0.0+0',
    String? gameId,
  }) : gameId = gameId ?? const Uuid().v4();

  Game copyWith({
    int? maxRounds,
    int? numPhases,
    int? numPlayers,
    bool? enablePhases,
    String? scoreFilter,
    String? version,
    String? gameId,
  }) {
    return Game(
      maxRounds: maxRounds ?? this.maxRounds,
      numPhases: numPhases ?? this.numPhases,
      numPlayers: numPlayers ?? this.numPlayers,
      enablePhases: enablePhases ?? this.enablePhases,
      scoreFilter: scoreFilter ?? this.scoreFilter,
      version: version ?? this.version,
      gameId: gameId ?? this.gameId,
    );
  }
}
