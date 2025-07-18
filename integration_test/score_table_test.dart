import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fs_game_score/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Navigates to the scoring table and verifies the table functionality
  /// including changing the player name, cell score and column locking
  testWidgets('Score table displays correct rows and widgets for 2 players', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Only press Continue (no dropdown changes)
    final continueButton = find.byKey(const ValueKey('splash_continue_button'));
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);

    // Verify 2 player rows (excluding header)
    final playerNameFields = find.byKey(const ValueKey('player_name_field_0'));
    expect(playerNameFields, findsOneWidget);
    expect(find.byKey(const ValueKey('player_name_field_1')), findsOneWidget);

    // Verify 5 round columns for each player (score fields only)
    for (int playerIdx = 0; playerIdx < 2; playerIdx++) {
      for (int round = 0; round < 5; round++) {
        final scoreKey = ValueKey('round_score_p${playerIdx}_r$round');
        expect(
          find.byKey(scoreKey),
          findsOneWidget,
          reason: 'Score field for player $playerIdx round $round',
        );
      }
    }

    // Enter the value "20" in the round score field for player 1 round 1
    final scoreField1 = find.byKey(const ValueKey('round_score_p0_r0'));
    expect(scoreField1, findsOneWidget);
    await tester.enterText(scoreField1, '20');
    await tester.pumpAndSettle();

    // Enter the value "40" in the round score field for player 1 round 2
    final scoreField2 = find.byKey(const ValueKey('round_score_p0_r1'));
    expect(scoreField2, findsOneWidget);
    await tester.enterText(scoreField2, '40');
    await tester.pumpAndSettle();

    // Validate the total score value for player 1 is "60"
    final totalScoreField = find.byKey(const ValueKey('player_total_score_0'));
    expect(totalScoreField, findsOneWidget);
    // Find the Text descendant of the TotalScoreField
    final textField = find.descendant(
      of: totalScoreField,
      matching: find.byType(Text),
    );
    expect(textField, findsOneWidget);
    final textFieldWidget = tester.widget<Text>(textField);
    final totalScoreText = textFieldWidget.data;
    expect(totalScoreText, '60');

    // Validate the player 0 score is zero
    final totalScoreFieldP0 = find.byKey(
      const ValueKey('player_total_score_1'),
    );
    expect(totalScoreFieldP0, findsOneWidget);
    final textFieldP0 = find.descendant(
      of: totalScoreFieldP0,
      matching: find.byType(Text),
    );
    expect(textFieldP0, findsOneWidget);
    final textFieldWidgetP0 = tester.widget<Text>(textFieldP0);
    final totalScoreTextP0 = textFieldWidgetP0.data;
    expect(totalScoreTextP0, '0');

    // Click on the lock icon in round 3 to lock the column (header row)
    final lockIcon = find.byKey(const ValueKey('lock_round_3'));
    expect(lockIcon, findsOneWidget);
    await tester.tap(lockIcon);
    await tester.pumpAndSettle();

    // Validate the round score field at player 1 round 3 is disabled
    final roundScoreFieldP1R3 = find.byKey(const ValueKey('round_score_p0_r3'));
    expect(roundScoreFieldP1R3, findsOneWidget);
    // Find the TextFormField descendant of the RoundScoreField
    final textFormFieldP1R3 = find.descendant(
      of: roundScoreFieldP1R3,
      matching: find.byType(TextFormField),
    );
    expect(textFormFieldP1R3, findsOneWidget);
    final widgetP1R3 = tester.widget<TextFormField>(textFormFieldP1R3);
    expect(widgetP1R3.enabled, isFalse);

    // Validate the player 1 score is still 60
    final totalScoreFieldP1Again = find.byKey(
      const ValueKey('player_total_score_0'),
    );
    expect(totalScoreFieldP1Again, findsOneWidget);
    final textFieldP1Again = find.descendant(
      of: totalScoreFieldP1Again,
      matching: find.byType(Text),
    );
    expect(textFieldP1Again, findsOneWidget);
    final textFieldWidgetP1Again = tester.widget<Text>(textFieldP1Again);
    final totalScoreTextP1Again = textFieldWidgetP1Again.data;
    expect(totalScoreTextP1Again, '60');

    // Validate the player 0 score is still 0
    final totalScoreFieldP0Again = find.byKey(
      const ValueKey('player_total_score_1'),
    );
    expect(totalScoreFieldP0Again, findsOneWidget);
    final textFieldP0Again = find.descendant(
      of: totalScoreFieldP0Again,
      matching: find.byType(Text),
    );
    expect(textFieldP0Again, findsOneWidget);
    final textFieldWidgetP0Again = tester.widget<Text>(textFieldP0Again);
    final totalScoreTextP0Again = textFieldWidgetP0Again.data;
    expect(totalScoreTextP0Again, '0');

    // Enable editing in player 1 round 3 and validate that the round_score for player 0 round 3 is enabled for editing
    // Click on the lock icon in round 3 to unlock the column (header row)
    final unlockIcon = find.byKey(const ValueKey('lock_round_3'));
    expect(unlockIcon, findsOneWidget);
    await tester.tap(unlockIcon);
    await tester.pumpAndSettle();

    // Validate the round score field at player 1 round 3 is enabled
    final roundScoreFieldP1R3Enabled = find.byKey(
      const ValueKey('round_score_p0_r3'),
    );
    expect(roundScoreFieldP1R3Enabled, findsOneWidget);
    // Find the TextFormField descendant of the RoundScoreField
    final textFormFieldP1R3Enabled = find.descendant(
      of: roundScoreFieldP1R3Enabled,
      matching: find.byType(TextFormField),
    );
    expect(textFormFieldP1R3Enabled, findsOneWidget);
    final widgetP1R3Enabled = tester.widget<TextFormField>(
      textFormFieldP1R3Enabled,
    );
    expect(widgetP1R3Enabled.enabled, isTrue);

    // Validate the player 1 score is still 60
    expect(totalScoreTextP1Again, '60');
  });
}
