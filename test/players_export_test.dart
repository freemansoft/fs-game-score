import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/model/player.dart';
import 'package:fs_score_card/model/scores.dart';
import 'package:fs_score_card/model/phases.dart';
import 'dart:convert';

void main() {
  group('Players Export Tests', () {
    late Players players;
    late Player player1;
    late Player player2;
    late Player player3;

    setUp(() {
      // Create test players with some scores and some empty scores
      player1 = Player.withData(
        name: 'Alice',
        scores:
            Scores(5)
              ..setScore(0, 10)
              ..setScore(1, 15)
              ..setScore(2, 20),
        phases: Phases(3),
      );

      player2 = Player.withData(
        name: 'Bob',
        scores:
            Scores(5)
              ..setScore(0, 5)
              ..setScore(3, 25),
        phases: Phases(3),
      );

      player3 = Player.withData(
        name: 'Charlie',
        scores:
            Scores(5)
              ..setScore(1, 30)
              ..setScore(4, 40),
        phases: Phases(3),
      );

      players = Players(
        numPlayers: 3,
        maxRounds: 5,
        numPhases: 3,
        initialPlayers: [player1, player2, player3],
      );
    });

    group('toJson() tests', () {
      test(
        'should convert players to valid JSON string with all required fields',
        () {
          final jsonString = players.toJson();

          // Verify it's valid JSON
          expect(() => jsonDecode(jsonString), returnsNormally);

          final decoded = jsonDecode(jsonString) as List;
          expect(decoded, hasLength(3));

          // Verify all required fields are present
          final firstPlayer = decoded[0] as Map<String, dynamic>;
          expect(firstPlayer.containsKey('name'), isTrue);
          expect(firstPlayer.containsKey('totalScore'), isTrue);
          expect(firstPlayer.containsKey('roundScores'), isTrue);
        },
      );

      test('should convert null round scores to 0 in JSON', () {
        final jsonString = players.toJson();
        final decoded = jsonDecode(jsonString) as List;

        // Check Alice's scores (rounds 0,1,2 have scores, 3,4 are null)
        final alice = decoded[0] as Map<String, dynamic>;
        final roundScores = alice['roundScores'] as List;
        expect(roundScores[0], 10); // round 0
        expect(roundScores[1], 15); // round 1
        expect(roundScores[2], 20); // round 2
        expect(roundScores[3], 0); // round 3 (null converted to 0)
        expect(roundScores[4], 0); // round 4 (null converted to 0)
      });

      test('should calculate correct total scores in JSON', () {
        final jsonString = players.toJson();
        final decoded = jsonDecode(jsonString) as List;

        // Alice: 10 + 15 + 20 = 45
        final alice = decoded[0] as Map<String, dynamic>;
        expect(alice['totalScore'], 45);

        // Bob: 5 + 25 = 30
        final bob = decoded[1] as Map<String, dynamic>;
        expect(bob['totalScore'], 30);

        // Charlie: 30 + 40 = 70
        final charlie = decoded[2] as Map<String, dynamic>;
        expect(charlie['totalScore'], 70);
      });

      test('should handle empty players list', () {
        final emptyPlayers = Players(numPlayers: 0, maxRounds: 5, numPhases: 3);
        final jsonString = emptyPlayers.toJson();

        expect(jsonString, '[]');
        expect(() => jsonDecode(jsonString), returnsNormally);
      });
    });

    group('toCsv() tests', () {
      test('should generate CSV with correct headers', () {
        final csv = players.toCsv();
        final lines = csv.split('\n');

        expect(lines[0], 'name,totalScore,round1,round2,round3,round4,round5');
      });

      test('should generate CSV with correct data rows', () {
        final csv = players.toCsv();
        final lines = csv.split('\n');

        expect(lines, hasLength(4)); // header + 3 players

        // Check Alice's row
        expect(lines[1], '"Alice",45,10,15,20,0,0');

        // Check Bob's row
        expect(lines[2], '"Bob",30,5,0,0,25,0');

        // Check Charlie's row
        expect(lines[3], '"Charlie",70,0,30,0,0,40');
      });

      test('should convert null round scores to 0 in CSV', () {
        final csv = players.toCsv();
        final lines = csv.split('\n');

        // Verify that null scores are converted to 0
        // Alice: 10,15,20,0,0 (rounds 3,4 are null)
        expect(lines[1], '"Alice",45,10,15,20,0,0');

        // Bob: 5,0,0,25,0 (rounds 1,2,4 are null)
        expect(lines[2], '"Bob",30,5,0,0,25,0');

        // Charlie: 0,30,0,0,40 (rounds 0,2,3 are null)
        expect(lines[3], '"Charlie",70,0,30,0,0,40');
      });

      test('should handle empty players list', () {
        final emptyPlayers = Players(numPlayers: 0, maxRounds: 5, numPhases: 3);
        final csv = emptyPlayers.toCsv();

        expect(csv, '');
      });

      test('should handle single player', () {
        // Create a player with only 3 rounds for this test
        final singlePlayerData = Player.withData(
          name: 'Alice',
          scores:
              Scores(3)
                ..setScore(0, 10)
                ..setScore(1, 15)
                ..setScore(2, 20),
          phases: Phases(2),
        );

        final singlePlayer = Players(
          numPlayers: 1,
          maxRounds: 3,
          numPhases: 2,
          initialPlayers: [singlePlayerData],
        );
        final csv = singlePlayer.toCsv();
        final lines = csv.split('\n');

        expect(lines, hasLength(2)); // header + 1 player
        expect(lines[0], 'name,totalScore,round1,round2,round3');
        expect(lines[1], '"Alice",45,10,15,20');
      });
    });

    group('toMapList() tests', () {
      test('should return list of maps with correct structure', () {
        final mapList = players.toMapList();

        expect(mapList, hasLength(3));

        for (final playerMap in mapList) {
          expect(playerMap.containsKey('name'), isTrue);
          expect(playerMap.containsKey('totalScore'), isTrue);
          expect(playerMap.containsKey('roundScores'), isTrue);
        }
      });

      test('should convert null round scores to 0 in map list', () {
        final mapList = players.toMapList();

        final alice = mapList[0];
        final roundScores = alice['roundScores'] as List;
        expect(roundScores[3], 0); // round 3 (null converted to 0)
        expect(roundScores[4], 0); // round 4 (null converted to 0)
      });

      test('should calculate correct total scores in map list', () {
        final mapList = players.toMapList();

        expect(mapList[0]['totalScore'], 45); // Alice
        expect(mapList[1]['totalScore'], 30); // Bob
        expect(mapList[2]['totalScore'], 70); // Charlie
      });

      test('should handle empty players list', () {
        final emptyPlayers = Players(numPlayers: 0, maxRounds: 5, numPhases: 3);
        final mapList = emptyPlayers.toMapList();

        expect(mapList, isEmpty);
      });
    });

    group('Integration tests', () {
      test('JSON and CSV should represent same data', () {
        final jsonString = players.toJson();
        final csv = players.toCsv();

        final jsonData = jsonDecode(jsonString) as List;
        final csvLines = csv.split('\n');

        // Skip header row
        for (int i = 1; i < csvLines.length; i++) {
          final csvRow = csvLines[i].split(',');
          final jsonPlayer = jsonData[i - 1] as Map<String, dynamic>;

          // Remove quotes from CSV name for comparison
          final csvName = csvRow[0].replaceAll('"', '');
          expect(csvName, jsonPlayer['name']); // name
          expect(int.parse(csvRow[1]), jsonPlayer['totalScore']); // total score

          // Check round scores
          final jsonRoundScores = jsonPlayer['roundScores'] as List;
          for (int j = 0; j < jsonRoundScores.length; j++) {
            expect(
              int.parse(csvRow[j + 2]),
              jsonRoundScores[j],
            ); // round scores
          }
        }
      });

      test('toMapList should match JSON structure', () {
        final jsonString = players.toJson();
        final mapList = players.toMapList();

        final jsonData = jsonDecode(jsonString) as List;

        expect(mapList.length, jsonData.length);

        for (int i = 0; i < mapList.length; i++) {
          final map = mapList[i];
          final json = jsonData[i] as Map<String, dynamic>;

          expect(map['name'], json['name']);
          expect(map['totalScore'], json['totalScore']);
          expect(map['roundScores'], json['roundScores']);
        }
      });
    });
  });
}
