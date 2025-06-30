// Game configuration model for Phase 10
class Game {
  final int maxRounds;
  final int numPhases;
  final int numPlayers;
  final bool enablePhases;

  const Game({
    this.maxRounds = 14,
    this.numPhases = 10,
    this.numPlayers = 8,
    this.enablePhases = true,
  });
}
