import 'dart:convert';

import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/player.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/sync/game_sync_protocol.dart';

/// Maps live [Game] + [Players] to a wire [GameSyncSnapshot].
GameSyncSnapshot snapshotFromGame({
  required Game game,
  required Players players,
  required int revision,
  required String hostDeviceName,
  String status = 'playing',
}) {
  return GameSyncSnapshot(
    protocolVersion: gameSyncProtocolVersion,
    gameId: game.gameId,
    revision: revision,
    configuration: game.configuration.toJson(),
    players: players.players.map((p) => p.toJson()).toList(),
    hostDeviceName: hostDeviceName,
    status: status,
  );
}

/// Restores [Game] and [Players] from a [GameSyncSnapshot].
({Game game, Players players}) gameAndPlayersFromSnapshot(
  GameSyncSnapshot snapshot,
) {
  final config = GameConfiguration.fromJson(snapshot.configuration);
  final game = Game(configuration: config, gameId: snapshot.gameId);
  final playerMaps = snapshot.players;
  if (playerMaps.isEmpty) {
    throw const FormatException('Snapshot has no players');
  }
  final parsed = playerMaps.map(Player.fromJson).toList();
  final maxRounds = parsed.first.scores.roundScores.length;
  final players = Players(
    numPlayers: parsed.length,
    maxRounds: maxRounds,
    initialPlayers: parsed,
  );
  return (game: game, players: players);
}

/// Convenience for persisting snapshot JSON in tests.
String snapshotToJsonString(GameSyncSnapshot snapshot) {
  return jsonEncode(snapshot.toJson());
}
