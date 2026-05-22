import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/data/game_repository.dart';
import 'package:fs_score_card/data/players_repository.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:fs_score_card/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('playersMatchConfiguration', () {
    test('accepts players matching standard game configuration', () {
      final config = GameConfiguration(
        numPlayers: 2,
        maxRounds: 5,
        // I like being explcit so tests work if defaults change
        // ignore: avoid_redundant_argument_values
        gameMode: GameMode.standard,
      );
      final players = Players(numPlayers: 2, maxRounds: 5);

      expect(playersMatchConfiguration(players, config), isTrue);
    });

    test('accepts players matching phase10 game configuration', () {
      final config = GameConfiguration(
        numPlayers: 3,
        maxRounds: 10,
        gameMode: GameMode.phase10,
      );
      final players = Players(numPlayers: 3, maxRounds: 10);

      expect(playersMatchConfiguration(players, config), isTrue);
    });

    test('accepts round-trip serialized players', () {
      final config = GameConfiguration(numPlayers: 4, maxRounds: 7);
      final players = Players(numPlayers: 4, maxRounds: 7);
      final restored = Players.fromJson(players.toJson());

      expect(playersMatchConfiguration(restored, config), isTrue);
    });

    test('rejects empty players', () {
      final config = GameConfiguration(numPlayers: 2, maxRounds: 5);
      final players = Players.fromJson('[]');

      expect(playersMatchConfiguration(players, config), isFalse);
    });

    test('rejects mismatched numPlayers', () {
      final config = GameConfiguration(numPlayers: 4, maxRounds: 5);
      final players = Players(numPlayers: 2, maxRounds: 5);

      expect(playersMatchConfiguration(players, config), isFalse);
    });

    test('rejects mismatched maxRounds', () {
      final config = GameConfiguration(numPlayers: 2, maxRounds: 10);
      final players = Players(numPlayers: 2, maxRounds: 5);

      expect(playersMatchConfiguration(players, config), isFalse);
    });
  });

  group('initialLocation', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('returns splash when prefs are empty', () {
      expect(initialLocation(prefs), '/');
    });

    test('returns splash when only game state exists', () async {
      final game = Game(
        configuration: GameConfiguration(numPlayers: 2, maxRounds: 5),
      );
      await GameRepository(prefs).saveGame(game);

      expect(initialLocation(prefs), '/');
    });

    test('returns splash when only players state exists', () async {
      final players = Players(numPlayers: 2, maxRounds: 5);
      await PlayersRepository(prefs).savePlayers(players);

      expect(initialLocation(prefs), '/');
    });

    test('returns score table when game and players are restorable', () async {
      final config = GameConfiguration(numPlayers: 2, maxRounds: 5);
      await GameRepository(prefs).saveGame(Game(configuration: config));
      await PlayersRepository(prefs).savePlayers(
        Players(numPlayers: 2, maxRounds: 5),
      );

      expect(initialLocation(prefs), '/score-table');
    });

    test(
      'returns splash when keys exist but players do not match game',
      () async {
        await GameRepository(prefs).saveGame(
          Game(configuration: GameConfiguration(numPlayers: 4, maxRounds: 5)),
        );
        await PlayersRepository(prefs).savePlayers(
          Players(numPlayers: 2, maxRounds: 5),
        );

        expect(initialLocation(prefs), '/');
      },
    );

    test('returns splash when game key has invalid JSON', () async {
      await prefs.setString('game_state', 'not-json');
      await PlayersRepository(prefs).savePlayers(
        Players(numPlayers: 2, maxRounds: 5),
      );

      expect(initialLocation(prefs), '/');
    });
  });
}
