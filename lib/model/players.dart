import 'dart:convert';

import 'package:fs_score_card/model/player.dart';

/// The collection of players in a game.
class Players {
  Players({
    required int numPlayers,
    required int maxRounds,
    required int numPhases,
    List<Player>? initialPlayers,
  }) : players =
           initialPlayers ??
           List.generate(
             numPlayers,
             (i) => Player(
               name: 'Player ${i + 1}',
               maxRounds: maxRounds,
               numPhases: numPhases,
             ),
           );

  /// Creates a Players instance from a JSON string
  /// The JSON should be an array of player objects
  Players.fromJson(String jsonString)
    : players = _parsePlayersFromJson(jsonString);

  static List<Player> _parsePlayersFromJson(String jsonString) {
    if (jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Player.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Players withPlayer(Player player, int index) {
    final newPlayers = List<Player>.from(players);
    newPlayers[index] = player;
    final first = newPlayers.isNotEmpty ? newPlayers[0] : null;
    return Players(
      numPlayers: newPlayers.length,
      maxRounds: first?.scores.roundScores.length ?? 0,
      numPhases: first?.phases.completedPhases.length ?? 0,
      initialPlayers: newPlayers,
    );
  }

  /// The only actual state for this class is the list of players.
  final List<Player> players;

  bool allPlayersEnabledForRound(int round) {
    return players.every((p) => p.roundStates.isEnabled(round));
  }

  Player operator [](int index) => players[index];
  int get length => players.length;
  List<Player> get asList => players;

  // Optionally, implement iterator and other List methods as needed

  /// Converts player data to JSON format for persistence
  /// Returns a JSON string containing full player state including scores, phases, and round states
  String toJson() {
    final List<Map<String, dynamic>> playerData = players
        .map((player) => player.toJson())
        .toList();
    return jsonEncode(playerData);
  }

  /// Converts player data to JSON format for export
  /// Returns a JSON string containing player names, total scores, and round scores
  /// Empty round scores are converted to 0
  String toJsonExport() {
    final List<Map<String, dynamic>> playerData = [];

    for (final player in players) {
      final Map<String, dynamic> playerMap = {
        'name': player.name,
        'totalScore': player.totalScore,
        'roundScores': player.scores.roundScores
            .map((score) => score ?? 0)
            .toList(),
      };
      playerData.add(playerMap);
    }

    return jsonEncode(playerData);
  }

  /// Converts player data to CSV format
  /// Returns a CSV string with headers: name,totalScore,round1,round2,...
  /// Empty round scores are converted to 0
  /// Player names are wrapped in double quotes to handle commas in names
  String toCsv() {
    if (players.isEmpty) return '';

    final maxRounds = players.first.scores.roundScores.length;
    final List<String> lines = [];

    // Create header row
    final List<String> headers = ['name', 'totalScore'];
    for (int i = 1; i <= maxRounds; i++) {
      headers.add('round$i');
    }
    lines.add(headers.join(','));

    // Create data rows
    for (final player in players) {
      // Wrap player name in double quotes to handle commas
      final String quotedName = '"${player.name}"';
      final List<String> row = [quotedName, player.totalScore.toString()];

      // Add round scores, converting null to 0
      for (final score in player.scores.roundScores) {
        row.add((score ?? 0).toString());
      }

      lines.add(row.join(','));
    }

    return lines.join('\n');
  }

  /// Converts player data to a list of maps for easier testing and manipulation
  /// Returns a list where each map contains player name, total score, and round scores
  /// Empty round scores are converted to 0
  List<Map<String, dynamic>> toMapList() {
    final List<Map<String, dynamic>> playerData = [];

    for (final player in players) {
      final Map<String, dynamic> playerMap = {
        'name': player.name,
        'totalScore': player.totalScore,
        'roundScores': player.scores.roundScores
            .map((score) => score ?? 0)
            .toList(),
      };
      playerData.add(playerMap);
    }

    return playerData;
  }
}
