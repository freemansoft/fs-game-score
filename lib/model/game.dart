import 'dart:convert';
import 'package:uuid/uuid.dart';

enum GameMode {
  standard,
  phase10,
  frenchDriving,
}

class GameConfiguration {
  GameConfiguration({
    this.maxRounds = defaultMaxRounds,
    this.numPhases = defaultNumPhases,
    this.numPlayers = defaultNumPlayers,
    this.gameMode = defaultGameMode,
    this.scoreFilter = defaultScoreFilter,
    this.endGameScore = defaultEndGameScore,
    this.version = '0.0.0+0',
  });

  factory GameConfiguration.fromJson(Map<String, dynamic> json) {
    var mode = defaultGameMode;
    if (json['gameMode'] != null) {
      mode = GameMode.values.firstWhere(
        (e) => e.toString() == json['gameMode'],
        orElse: () => defaultGameMode,
      );
    } else if (json['enablePhases'] == true) {
      // backward compatibility
      mode = GameMode.phase10;
    }

    return GameConfiguration(
      maxRounds: (json['maxRounds'] as int?) ?? defaultMaxRounds,
      numPhases: (json['numPhases'] as int?) ?? defaultNumPhases,
      numPlayers: (json['numPlayers'] as int?) ?? defaultNumPlayers,
      gameMode: mode,
      scoreFilter: (json['scoreFilter'] as String?) ?? defaultScoreFilter,
      endGameScore: (json['endGameScore'] as int?) ?? defaultEndGameScore,
      version: json['version'] as String?,
    );
  }

  static const int defaultMaxRounds = 14;
  static const int defaultNumPhases = 10;
  static const int defaultNumPlayers = 8;
  // static const bool defaultEnablePhases = false;
  static const GameMode defaultGameMode = GameMode.standard;
  static const String defaultScoreFilter = '';
  static const int defaultEndGameScore = 0;

  final int maxRounds;
  final int numPhases;
  final int numPlayers;
  // final bool enablePhases;
  final GameMode gameMode;

  bool get enablePhases => gameMode == GameMode.phase10;
  final String scoreFilter;
  final int endGameScore;
  final String? version;

  Map<String, dynamic> toJson() {
    return {
      'maxRounds': maxRounds,
      'numPhases': numPhases,
      'numPlayers': numPlayers,
      'gameMode': gameMode.toString(),
      'enablePhases': enablePhases, // for backward compatibility
      'scoreFilter': scoreFilter,
      'endGameScore': endGameScore,
      'version': version,
    };
  }

  GameConfiguration copyWith({
    int? maxRounds,
    int? numPhases,
    int? numPlayers,
    bool? enablePhases, // deprecated in favor of gameMode
    GameMode? gameMode,
    String? scoreFilter,
    int? endGameScore,
    String? version,
  }) {
    return GameConfiguration(
      maxRounds: maxRounds ?? this.maxRounds,
      numPhases: numPhases ?? this.numPhases,
      numPlayers: numPlayers ?? this.numPlayers,
      gameMode:
          gameMode ??
          (enablePhases ?? (this.gameMode == GameMode.phase10)
              ? GameMode.phase10
              : GameMode.standard),
      scoreFilter: scoreFilter ?? this.scoreFilter,
      endGameScore: endGameScore ?? this.endGameScore,
      version: version ?? this.version,
    );
  }
}

class Game {
  // the gameId is really a game session id

  Game({
    GameConfiguration? configuration,
    String? gameId,
  }) : configuration = configuration ?? GameConfiguration(),
       gameId = gameId ?? const Uuid().v4();

  /// Creates a Game instance from a JSON string.
  /// If a key is missing, it uses default values.
  /// Note: gameId is not deserialized - each load creates a new game instance with a fresh UUID.
  factory Game.fromJson(String jsonString) {
    final json = _decodeJson(jsonString);
    final configJson = json['configuration'] as Map<String, dynamic>?;

    return Game(
      configuration: configJson != null
          // nested configuration
          ? GameConfiguration.fromJson(configJson)
          // flat configuration (backward compatibility)
          : GameConfiguration.fromJson(json),
    );
  }

  /// Serializes the game configuration to a JSON string.
  /// This is useful for saving and loading game state.
  String toJson() {
    return _encodeJson({
      'configuration': configuration.toJson(),
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

  final GameConfiguration configuration;
  final String gameId;

  // Convenience getters to avoid breaking changes locally if preferred,
  // but better to refactor call sites to be explicit.
  // I will refactor call sites.

  Game copyWith({
    GameConfiguration? configuration,
    String? gameId,
  }) {
    return Game(
      configuration: configuration ?? this.configuration,
      gameId: gameId ?? this.gameId,
    );
  }
}
