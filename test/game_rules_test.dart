import 'package:flutter_test/flutter_test.dart';
// game.dart re-exports game_rules.dart (GameMode, GameRules, rulesFor, ...).
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/score_filters.dart';

void main() {
  group('rulesFor', () {
    test('every GameMode resolves to a descriptor', () {
      for (final mode in GameMode.values) {
        expect(rulesFor(mode), isA<GameRules>());
      }
    });

    test('standard mode rules match legacy behavior', () {
      final rules = rulesFor(GameMode.standard);
      expect(rules.roundInput, RoundInput.typedScore);
      expect(rules.allowNegativeScores, isFalse);
      expect(rules.enablePhases, isFalse);
      expect(rules.numPhases, 0);
      expect(rules.suggestedScoreFilter, ScoreFilters.none);
      expect(rules.suggestedEndGameScore, 0);
    });

    test('phase10 mode rules match legacy behavior', () {
      final rules = rulesFor(GameMode.phase10);
      expect(rules.roundInput, RoundInput.typedScore);
      expect(rules.allowNegativeScores, isFalse);
      expect(rules.enablePhases, isTrue);
      expect(rules.numPhases, 10);
      expect(rules.suggestedScoreFilter, ScoreFilters.endsWith0or5);
      expect(rules.suggestedEndGameScore, 0);
    });

    test('frenchDriving mode rules match legacy behavior', () {
      final rules = rulesFor(GameMode.frenchDriving);
      expect(rules.roundInput, RoundInput.calculatedFrenchDriving);
      expect(rules.allowNegativeScores, isFalse);
      expect(rules.enablePhases, isFalse);
      expect(rules.numPhases, 0);
      expect(rules.suggestedScoreFilter, ScoreFilters.endsWith0or5);
      expect(rules.suggestedEndGameScore, 5000);
    });

    test('skyjo mode rules match legacy behavior', () {
      final rules = rulesFor(GameMode.skyjo);
      expect(rules.roundInput, RoundInput.typedScore);
      expect(rules.allowNegativeScores, isTrue);
      expect(rules.enablePhases, isFalse);
      expect(rules.numPhases, 0);
      expect(rules.suggestedScoreFilter, ScoreFilters.none);
      expect(rules.suggestedEndGameScore, 100);
    });

    test(
      'Tier 0 aggregation/end-condition hooks are the single value today',
      () {
        for (final mode in GameMode.values) {
          final rules = rulesFor(mode);
          expect(rules.aggregation, ScoreAggregation.sumPerPlayer);
          expect(rules.endCondition, EndCondition.reachTargetHighlight);
        }
      },
    );
  });

  group('GameConfiguration getters delegate to rules', () {
    test(
      'numPhases, allowNegativeScores, enablePhases match the descriptor',
      () {
        for (final mode in GameMode.values) {
          final config = GameConfiguration(gameMode: mode);
          final rules = rulesFor(mode);
          expect(config.numPhases, rules.numPhases, reason: '$mode numPhases');
          expect(
            config.allowNegativeScores,
            rules.allowNegativeScores,
            reason: '$mode allowNegativeScores',
          );
          expect(
            config.enablePhases,
            rules.enablePhases,
            reason: '$mode enablePhases',
          );
          expect(config.rules, same(rules), reason: '$mode rules identity');
        }
      },
    );

    test('legacy per-mode expectations still hold', () {
      expect(GameConfiguration(gameMode: GameMode.phase10).numPhases, 10);
      // standard is the default mode; stated explicitly for test clarity.
      // ignore: avoid_redundant_argument_values
      expect(GameConfiguration(gameMode: GameMode.standard).numPhases, 0);
      expect(
        GameConfiguration(gameMode: GameMode.skyjo).allowNegativeScores,
        isTrue,
      );
      expect(
        // standard is the default mode; stated explicitly for test clarity.
        // ignore: avoid_redundant_argument_values
        GameConfiguration(gameMode: GameMode.standard).allowNegativeScores,
        isFalse,
      );
      expect(
        GameConfiguration(gameMode: GameMode.phase10).enablePhases,
        isTrue,
      );
      expect(
        GameConfiguration(gameMode: GameMode.frenchDriving).enablePhases,
        isFalse,
      );
    });
  });
}
