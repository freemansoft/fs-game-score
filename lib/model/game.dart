// Game configuration model for Phase 10
class Game {
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
