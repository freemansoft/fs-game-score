import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/phases.dart';
import 'package:fs_score_card/model/player.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/model/round_states.dart';
import 'package:fs_score_card/model/scores.dart';

void main() {
  group('Players Serialization Tests', () {
    late Players players;
    late Player player1;
    late Player player2;

    setUp(() {
      // Create test players with scores, phases, and round states
      player1 = Player.withData(
        name: 'Alice',
        scores: Scores(5)
          ..setScore(0, 10)
          ..setScore(1, 15)
          ..setScore(2, 20),
        phases: Phases(3)
          ..setPhase(0, 1)
          ..setPhase(1, 2),
        roundStates: RoundStates(5)
          ..setEnabled(round: 0, enabled: true)
          ..setEnabled(round: 1, enabled: false),
      );

      player2 = Player.withData(
        name: 'Bob',
        scores: Scores(5)
          ..setScore(0, 5)
          ..setScore(3, 25),
        phases: Phases(3)..setPhase(0, 1),
        roundStates: RoundStates(5)..setEnabled(round: 2, enabled: false),
      );

      players = Players(
        numPlayers: 2,
        maxRounds: 5,
        numPhases: 3,
        initialPlayers: [player1, player2],
      );
    });

    group('Scores serialization', () {
      test('should serialize and deserialize correctly', () {
        final scores = Scores(5)
          ..setScore(0, 10)
          ..setScore(2, 20);

        final json = scores.toJson();
        final deserialized = Scores.fromJson(json);

        expect(deserialized.roundScores.length, 5);
        expect(deserialized.getScore(0), 10);
        expect(deserialized.getScore(1), null);
        expect(deserialized.getScore(2), 20);
      });
    });

    group('Phases serialization', () {
      test('should serialize and deserialize correctly', () {
        final phases = Phases(3)
          ..setPhase(0, 1)
          ..setPhase(2, 3);

        final json = phases.toJson();
        final deserialized = Phases.fromJson(json);

        expect(deserialized.completedPhases.length, 3);
        expect(deserialized.getPhase(0), 1);
        expect(deserialized.getPhase(1), null);
        expect(deserialized.getPhase(2), 3);
      });
    });

    group('RoundStates serialization', () {
      test('should serialize and deserialize correctly', () {
        final roundStates = RoundStates(5)
          ..setEnabled(round: 0, enabled: false)
          ..setEnabled(round: 2, enabled: false);

        final json = roundStates.toJson();
        final deserialized = RoundStates.fromJson(json);

        expect(deserialized.enabledRounds.length, 5);
        expect(deserialized.isEnabled(0), false);
        expect(deserialized.isEnabled(1), true); // default is true
        expect(deserialized.isEnabled(2), false);
      });
    });

    group('Player serialization', () {
      test('should serialize and deserialize correctly', () {
        final player = Player.withData(
          name: 'Test Player',
          scores: Scores(3)
            ..setScore(0, 10)
            ..setScore(2, 30),
          phases: Phases(2)..setPhase(0, 1),
          roundStates: RoundStates(3)..setEnabled(round: 1, enabled: false),
        );

        final json = player.toJson();
        final deserialized = Player.fromJson(json);

        expect(deserialized.name, 'Test Player');
        expect(deserialized.scores.getScore(0), 10);
        expect(deserialized.scores.getScore(1), null);
        expect(deserialized.scores.getScore(2), 30);
        expect(deserialized.phases.getPhase(0), 1);
        expect(deserialized.roundStates.isEnabled(0), true);
        expect(deserialized.roundStates.isEnabled(1), false);
      });
    });

    group('Players serialization', () {
      test('should serialize to JSON string correctly', () {
        final jsonString = players.toJson();

        expect(jsonString, isA<String>());
        expect(jsonString.contains('Alice'), isTrue);
        expect(jsonString.contains('Bob'), isTrue);
      });

      test('should deserialize from JSON string correctly', () {
        final jsonString = players.toJson();
        final deserialized = Players.fromJson(jsonString);

        expect(deserialized.players.length, 2);
        expect(deserialized.players[0].name, 'Alice');
        expect(deserialized.players[1].name, 'Bob');
      });

      test('should preserve all player data through round-trip', () {
        final jsonString = players.toJson();
        final deserialized = Players.fromJson(jsonString);

        // Check Alice's data
        final alice = deserialized.players[0];
        expect(alice.name, 'Alice');
        expect(alice.scores.getScore(0), 10);
        expect(alice.scores.getScore(1), 15);
        expect(alice.scores.getScore(2), 20);
        expect(alice.phases.getPhase(0), 1);
        expect(alice.phases.getPhase(1), 2);
        expect(alice.roundStates.isEnabled(0), true);
        expect(alice.roundStates.isEnabled(1), false);

        // Check Bob's data
        final bob = deserialized.players[1];
        expect(bob.name, 'Bob');
        expect(bob.scores.getScore(0), 5);
        expect(bob.scores.getScore(1), null);
        expect(bob.scores.getScore(3), 25);
        expect(bob.phases.getPhase(0), 1);
        expect(bob.roundStates.isEnabled(2), false);
      });

      test('should handle empty players list', () {
        final emptyPlayers = Players(
          numPlayers: 0,
          maxRounds: 5,
          numPhases: 3,
        );

        final jsonString = emptyPlayers.toJson();
        final deserialized = Players.fromJson(jsonString);

        expect(deserialized.players, isEmpty);
      });

      test('should handle empty JSON string', () {
        final deserialized = Players.fromJson('');
        expect(deserialized.players, isEmpty);
      });
    });
  });
}
