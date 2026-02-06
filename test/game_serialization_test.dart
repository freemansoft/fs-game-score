import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/game.dart';

Game defaultGame() => Game();

Game gameWithValues() => Game(
  configuration: GameConfiguration(
    maxRounds: 20,
    numPhases: 12,
    numPlayers: 4,
    // Being specific about the values here so the test work if defaults change
    // ignore: avoid_redundant_argument_values
    enablePhases: false,
    // Being specific about the values here so the test work if defaults change
    // ignore: avoid_redundant_argument_values
    scoreFilter: '',
    // Being specific about the values here so the test work if defaults change
    // ignore: avoid_redundant_argument_values
    endGameScore: 0,
    version: '1.2.3',
  ),
);

void main() {
  test('Game serializes to JSON and back (default)', () {
    final game = defaultGame();
    final json = game.toJson();
    final fromJson = Game.fromJson(json);
    expect(fromJson.configuration.maxRounds, game.configuration.maxRounds);
    expect(fromJson.configuration.numPhases, game.configuration.numPhases);
    expect(fromJson.configuration.numPlayers, game.configuration.numPlayers);
    expect(
      fromJson.configuration.enablePhases,
      game.configuration.enablePhases,
    );
    expect(fromJson.configuration.version, game.configuration.version);
  });

  test('Game serializes to JSON and back (custom values)', () {
    final game = gameWithValues();
    final json = game.toJson();
    final fromJson = Game.fromJson(json);
    expect(fromJson.configuration.maxRounds, game.configuration.maxRounds);
    expect(fromJson.configuration.numPhases, game.configuration.numPhases);
    expect(fromJson.configuration.numPlayers, game.configuration.numPlayers);
    expect(
      fromJson.configuration.enablePhases,
      game.configuration.enablePhases,
    );
    expect(fromJson.configuration.version, game.configuration.version);
  });

  test('New Game instances have unique gameIds', () {
    final game1 = Game();
    final game2 = Game();
    final game3 = Game();

    expect(game1.gameId, isNotEmpty);
    expect(game2.gameId, isNotEmpty);
    expect(game3.gameId, isNotEmpty);

    expect(game1.gameId, isNot(equals(game2.gameId)));
    expect(game1.gameId, isNot(equals(game3.gameId)));
    expect(game2.gameId, isNot(equals(game3.gameId)));
  });

  test('copyWith preserves original gameId', () {
    final originalGame = Game(
      configuration: GameConfiguration(maxRounds: 10),
    );
    final originalGameId = originalGame.gameId;

    final copiedGame = originalGame.copyWith(
      configuration: originalGame.configuration.copyWith(maxRounds: 20),
    );

    expect(copiedGame.gameId, equals(originalGameId));
    expect(copiedGame.configuration.maxRounds, equals(20));
    expect(
      copiedGame.configuration.numPhases,
      equals(originalGame.configuration.numPhases),
    );
  });

  test('toJson does not include gameId', () {
    final game = Game();
    final json = game.toJson();

    // Parse the JSON to check its contents
    final decoded = Game.fromJson(json);

    // The JSON string should not contain the gameId field
    expect(json.contains('gameId'), isFalse);

    // When deserialized, it should create a new gameId
    expect(decoded.gameId, isNot(equals(game.gameId)));
  });

  test('fromJson creates new gameId (different from original)', () {
    final originalGame = Game(
      configuration: GameConfiguration(maxRounds: 15, numPlayers: 6),
    );
    final originalGameId = originalGame.gameId;

    final json = originalGame.toJson();
    final deserializedGame = Game.fromJson(json);

    expect(deserializedGame.gameId, isNot(equals(originalGameId)));
    expect(
      deserializedGame.configuration.maxRounds,
      equals(originalGame.configuration.maxRounds),
    );
    expect(
      deserializedGame.configuration.numPlayers,
      equals(originalGame.configuration.numPlayers),
    );
    expect(deserializedGame.gameId, isNotEmpty);
  });

  test('GameId format is valid UUID', () {
    final game = Game();
    final gameId = game.gameId;

    // UUID format: 8-4-4-4-12 characters
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    );
    expect(gameId, matches(uuidPattern));
  });
}
