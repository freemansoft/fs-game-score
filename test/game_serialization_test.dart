import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/game.dart';

Game defaultGame() => const Game();

Game gameWithValues() => const Game(
  maxRounds: 20,
  numPhases: 12,
  numPlayers: 4,
  enablePhases: false,
  version: '1.2.3',
);

void main() {
  test('Game serializes to JSON and back (default)', () {
    final game = defaultGame();
    final json = game.toJson();
    final fromJson = Game.fromJson(json);
    expect(fromJson.maxRounds, game.maxRounds);
    expect(fromJson.numPhases, game.numPhases);
    expect(fromJson.numPlayers, game.numPlayers);
    expect(fromJson.enablePhases, game.enablePhases);
    expect(fromJson.version, game.version);
  });

  test('Game serializes to JSON and back (custom values)', () {
    final game = gameWithValues();
    final json = game.toJson();
    final fromJson = Game.fromJson(json);
    expect(fromJson.maxRounds, game.maxRounds);
    expect(fromJson.numPhases, game.numPhases);
    expect(fromJson.numPlayers, game.numPlayers);
    expect(fromJson.enablePhases, game.enablePhases);
    expect(fromJson.version, game.version);
  });
}
