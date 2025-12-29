import 'dart:convert';
import 'package:uuid/uuid.dart';

// Game configuration model for Phase 10
class Game {
  // the gameId is really a game session id

  Game({
    this.maxRounds = defaultMaxRounds,
    this.numPhases = defaultNumPhases,
    this.numPlayers = defaultNumPlayers,
    this.enablePhases = defaultEnablePhases,
    this.scoreFilter = defaultScoreFilter,
    this.endGameScore = defaultEndGameScore,
    this.version = '0.0.0+0',
    String? gameId,
  }) : gameId = gameId ?? const Uuid().v4();

  /// Creates a Game instance from a JSON string.
  /// If a key is missing, it uses default values.
  /// Note: gameId is not deserialized - each load creates a new game instance with a fresh UUID.
  factory Game.fromJson(String jsonString) {
    final json = _decodeJson(jsonString);
    return Game(
      maxRounds: (json['maxRounds'] as int?) ?? defaultMaxRounds,
      numPhases: (json['numPhases'] as int?) ?? defaultNumPhases,
      numPlayers: (json['numPlayers'] as int?) ?? defaultNumPlayers,
      enablePhases: (json['enablePhases'] as bool?) ?? defaultEnablePhases,
      scoreFilter: (json['scoreFilter'] as String?) ?? defaultScoreFilter,
      endGameScore: (json['endGameScore'] as int?) ?? defaultEndGameScore,
      version: json['version'] as String?,
      // gameId is intentionally omitted - will generate new UUID via constructor
    );
  }
  static const int defaultMaxRounds = 14;
  static const int defaultNumPhases = 10;
  static const int defaultNumPlayers = 8;
  static const bool defaultEnablePhases = false;
  static const String defaultScoreFilter = '';
  static const int defaultEndGameScore = 0;

  /// Serializes the game configuration to a JSON string.
  /// This is useful for saving and loading game state.
  String toJson() {
    return _encodeJson({
      'maxRounds': maxRounds,
      'numPhases': numPhases,
      'numPlayers': numPlayers,
      'enablePhases': enablePhases,
      'scoreFilter': scoreFilter,
      'endGameScore': endGameScore,
      'version': version,
      // gameId is intentionally omitted - will generate new UUID via constructor
    });
  }

  static Map<String, dynamic> _decodeJson(String jsonString) {
    return jsonString.isNotEmpty
        ? Map<String, dynamic>.from(
            jsonDecode(jsonString) as Map<String, dynamic>,
          )
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
  final int endGameScore;
  final String? version; // initialized from app version - stored in prefs
  final String gameId;

  Game copyWith({
    int? maxRounds,
    int? numPhases,
    int? numPlayers,
    bool? enablePhases,
    String? scoreFilter,
    int? endGameScore,
    String? version,
    String? gameId,
  }) {
    return Game(
      maxRounds: maxRounds ?? this.maxRounds,
      numPhases: numPhases ?? this.numPhases,
      numPlayers: numPlayers ?? this.numPlayers,
      enablePhases: enablePhases ?? this.enablePhases,
      scoreFilter: scoreFilter ?? this.scoreFilter,
      endGameScore: endGameScore ?? this.endGameScore,
      version: version ?? this.version,
      gameId: gameId ?? this.gameId,
    );
  }
}
