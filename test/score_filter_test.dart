import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/game.dart';

void main() {
  group('Game Score Filter Tests', () {
    test('should create game with default empty score filter', () {
      final game = Game();
      expect(game.scoreFilter, equals(''));
    });

    test('should create game with custom score filter', () {
      final game = Game(scoreFilter: r'^[0-9]*[05]$');
      expect(game.scoreFilter, equals(r'^[0-9]*[05]$'));
    });

    test('should serialize and deserialize score filter correctly', () {
      final originalGame = Game(scoreFilter: r'^[0-9]*[05]$');
      final jsonString = originalGame.toJson();
      final deserializedGame = Game.fromJson(jsonString);

      expect(deserializedGame.scoreFilter, equals(originalGame.scoreFilter));
    });

    test('should copy game with new score filter', () {
      final originalGame = Game(scoreFilter: '');
      final newGame = originalGame.copyWith(scoreFilter: r'^[0-9]*[05]$');

      expect(newGame.scoreFilter, equals(r'^[0-9]*[05]$'));
      expect(originalGame.scoreFilter, equals('')); // Original unchanged
    });
  });

  group('Score Filter Regex Validation Tests', () {
    test('should validate scores ending in 5 or 0', () {
      final regex = RegExp(r'^[0-9]*[05]$');

      // Valid scores
      expect(regex.hasMatch('0'), isTrue);
      expect(regex.hasMatch('5'), isTrue);
      expect(regex.hasMatch('10'), isTrue);
      expect(regex.hasMatch('15'), isTrue);
      expect(regex.hasMatch('20'), isTrue);
      expect(regex.hasMatch('25'), isTrue);
      expect(regex.hasMatch('100'), isTrue);
      expect(regex.hasMatch('105'), isTrue);

      // Invalid scores
      expect(regex.hasMatch('1'), isFalse);
      expect(regex.hasMatch('2'), isFalse);
      expect(regex.hasMatch('3'), isFalse);
      expect(regex.hasMatch('4'), isFalse);
      expect(regex.hasMatch('6'), isFalse);
      expect(regex.hasMatch('7'), isFalse);
      expect(regex.hasMatch('8'), isFalse);
      expect(regex.hasMatch('9'), isFalse);
      expect(regex.hasMatch('11'), isFalse);
      expect(regex.hasMatch('12'), isFalse);
      expect(regex.hasMatch('13'), isFalse);
      expect(regex.hasMatch('14'), isFalse);
    });
  });
}
