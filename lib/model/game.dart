import 'dart:convert';

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
      'version': version,
    });
  }

  /// Creates a Game instance from a JSON string.
  /// If a key is missing, it uses default values.
  factory Game.fromJson(String jsonString) {
    final json = _decodeJson(jsonString);
    return Game(
      maxRounds: json['maxRounds'] ?? 14,
      numPhases: json['numPhases'] ?? 10,
      numPlayers: json['numPlayers'] ?? 8,
      enablePhases: json['enablePhases'] ?? true,
      version: json['version'],
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
  final String? version;

  const Game({
    this.maxRounds = 14,
    this.numPhases = 10,
    this.numPlayers = 8,
    this.enablePhases = true,
    this.version,
  });

  Game copyWith({
    int? maxRounds,
    int? numPhases,
    int? numPlayers,
    bool? enablePhases,
    String? version,
  }) {
    return Game(
      maxRounds: maxRounds ?? this.maxRounds,
      numPhases: numPhases ?? this.numPhases,
      numPlayers: numPlayers ?? this.numPlayers,
      enablePhases: enablePhases ?? this.enablePhases,
      version: version ?? this.version,
    );
  }
}
