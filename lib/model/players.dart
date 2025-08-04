import 'player.dart';

class Players {
  Players withPlayer(Player player, int index) {
    final newPlayers = List<Player>.from(players);
    newPlayers[index] = player;
    final first = newPlayers.isNotEmpty ? newPlayers[0] : null;
    return Players(
      newPlayers.length,
      first?.scores.roundScores.length ?? 0,
      first?.phases.completedPhases.length ?? 0,
    )..players.setAll(0, newPlayers);
  }

  final List<Player> players;

  Players(int numPlayers, int maxRounds, int numPhases)
    : players = List.generate(
        numPlayers,
        (i) => Player(
          name: 'Player ${i + 1}',
          maxRounds: maxRounds,
          numPhases: numPhases,
        ),
      );
  bool allPlayersEnabledForRound(int round) {
    return players.every(
      (p) => p.scores.isEnabled(round) && p.phases.isEnabled(round),
    );
  }

  Player operator [](int index) => players[index];
  int get length => players.length;
  List<Player> get asList => players;

  // Optionally, implement iterator and other List methods as needed
}
