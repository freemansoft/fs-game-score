import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fs_score_card/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Clear SharedPreferences for 'game_state' before each test
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_state');
  });

  /// Navigates to the scoring table and verifies the table functionality
  /// including changing the player name, cell score and column locking
  testWidgets('Score table displays correct rows and widgets for 2 players', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Define all ValueKeys used in the test
    const splashContinueButtonKey = ValueKey('splash_continue_button');
    const playerNameField0Key = ValueKey('player_name_field_0');
    const playerNameField1Key = ValueKey('player_name_field_1');
    const roundScoreP0R0Key = ValueKey('round_score_p0_r0');
    const roundScoreP0R1Key = ValueKey('round_score_p0_r1');
    const roundScoreP0R3Key = ValueKey('round_score_p0_r3');
    const roundScoreP1R3Key = ValueKey('round_score_p1_r3');
    const playerTotalScore0Key = ValueKey('player_total_score_0');
    const playerTotalScore1Key = ValueKey('player_total_score_1');
    const lockRound3Key = ValueKey('lock_round_3');

    // Only press Continue (no dropdown changes)
    final continueButton = find.byKey(splashContinueButtonKey);
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);

    // Verify 2 player rows (excluding header)
    final playerNameFields = find.byKey(playerNameField0Key);
    expect(playerNameFields, findsOneWidget);
    expect(find.byKey(playerNameField1Key), findsOneWidget);

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
    final scoreField1 = find.byKey(roundScoreP0R0Key);
    expect(scoreField1, findsOneWidget);
    await tester.enterText(scoreField1, '20');
    await tester.pumpAndSettle();

    // Enter the value "40" in the round score field for player 1 round 2
    final scoreField2 = find.byKey(roundScoreP0R1Key);
    expect(scoreField2, findsOneWidget);
    await tester.enterText(scoreField2, '40');
    await tester.pumpAndSettle();

    // Validate the total score value for player 1 is "60"
    final totalScoreField = find.byKey(playerTotalScore0Key);
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
    final totalScoreFieldP0 = find.byKey(playerTotalScore1Key);
    expect(totalScoreFieldP0, findsOneWidget);
    final textFieldP0 = find.descendant(
      of: totalScoreFieldP0,
      matching: find.byType(Text),
    );
    expect(textFieldP0, findsOneWidget);
    final textFieldWidgetP0 = tester.widget<Text>(textFieldP0);
    final totalScoreTextP0 = textFieldWidgetP0.data;
    expect(totalScoreTextP0, '0');

    // Enter values of 5*(player number +1) in column 3 (round 3) for all players
    // Player 0: 5*(0+1) = 5, Player 1: 5*(1+1) = 10
    final round3ScoreFieldP0 = find.byKey(roundScoreP0R3Key);
    expect(round3ScoreFieldP0, findsOneWidget);
    await tester.enterText(round3ScoreFieldP0, '5');
    await tester.pumpAndSettle();

    final round3ScoreFieldP1 = find.byKey(roundScoreP1R3Key);
    expect(round3ScoreFieldP1, findsOneWidget);
    await tester.enterText(round3ScoreFieldP1, '10');
    await tester.pumpAndSettle();

    // Verify the fields contain the right values
    final textFormFieldP0R3 = find.descendant(
      of: round3ScoreFieldP0,
      matching: find.byType(TextFormField),
    );
    expect(textFormFieldP0R3, findsOneWidget);
    final widgetP0R3 = tester.widget<TextFormField>(textFormFieldP0R3);
    expect(widgetP0R3.controller?.text, '5');

    final textFormFieldP1R3 = find.descendant(
      of: round3ScoreFieldP1,
      matching: find.byType(TextFormField),
    );
    expect(textFormFieldP1R3, findsOneWidget);
    final widgetP1R3 = tester.widget<TextFormField>(textFormFieldP1R3);
    expect(widgetP1R3.controller?.text, '10');

    // Verify the totals reflect the new values
    // Player 0: 20 + 40 + 5 = 65, Player 1: 0 + 0 + 10 = 10
    final totalScoreFieldP0Updated = find.byKey(playerTotalScore0Key);
    expect(totalScoreFieldP0Updated, findsOneWidget);
    final textFieldP0Updated = find.descendant(
      of: totalScoreFieldP0Updated,
      matching: find.byType(Text),
    );
    expect(textFieldP0Updated, findsOneWidget);
    final textFieldWidgetP0Updated = tester.widget<Text>(textFieldP0Updated);
    final totalScoreTextP0Updated = textFieldWidgetP0Updated.data;
    expect(totalScoreTextP0Updated, '65');

    final totalScoreFieldP1Updated = find.byKey(playerTotalScore1Key);
    expect(totalScoreFieldP1Updated, findsOneWidget);
    final textFieldP1Updated = find.descendant(
      of: totalScoreFieldP1Updated,
      matching: find.byType(Text),
    );
    expect(textFieldP1Updated, findsOneWidget);
    final textFieldWidgetP1Updated = tester.widget<Text>(textFieldP1Updated);
    final totalScoreTextP1Updated = textFieldWidgetP1Updated.data;
    expect(totalScoreTextP1Updated, '10');

    // Click on the lock icon in round 3 to lock the column (header row)
    final lockIcon = find.byKey(lockRound3Key);
    expect(lockIcon, findsOneWidget);
    await tester.tap(lockIcon);
    await tester.pumpAndSettle();

    // Validate the round score field at player 1 round 3 is disabled
    final roundScoreFieldP0R3Locked = find.byKey(roundScoreP0R3Key);
    expect(roundScoreFieldP0R3Locked, findsOneWidget);
    // Find the TextFormField descendant of the RoundScoreField
    final textFormFieldP0R3Locked = find.descendant(
      of: roundScoreFieldP0R3Locked,
      matching: find.byType(TextFormField),
    );
    expect(textFormFieldP0R3Locked, findsOneWidget);
    final widgetP0R3Locked = tester.widget<TextFormField>(
      textFormFieldP0R3Locked,
    );
    expect(widgetP0R3Locked.enabled, isFalse);

    // Verify that the locked fields still contain the same values
    expect(widgetP0R3Locked.controller?.text, '5');

    final roundScoreFieldP1R3Locked = find.byKey(roundScoreP1R3Key);
    expect(roundScoreFieldP1R3Locked, findsOneWidget);
    final textFormFieldP1R3Locked = find.descendant(
      of: roundScoreFieldP1R3Locked,
      matching: find.byType(TextFormField),
    );
    expect(textFormFieldP1R3Locked, findsOneWidget);
    final widgetP1R3Locked = tester.widget<TextFormField>(
      textFormFieldP1R3Locked,
    );
    expect(widgetP1R3Locked.enabled, isFalse);
    expect(widgetP1R3Locked.controller?.text, '10');

    // Validate the player 0 score is still 65 (after adding 5 to round 3)
    final totalScoreFieldP0Again = find.byKey(playerTotalScore0Key);
    expect(totalScoreFieldP0Again, findsOneWidget);
    final textFieldP0Again = find.descendant(
      of: totalScoreFieldP0Again,
      matching: find.byType(Text),
    );
    expect(textFieldP0Again, findsOneWidget);
    final textFieldWidgetP0Again = tester.widget<Text>(textFieldP0Again);
    final totalScoreTextP0Again = textFieldWidgetP0Again.data;
    expect(totalScoreTextP0Again, '65');

    // Validate the player 1 score is still 10 (after adding 10 to round 3)
    final totalScoreFieldP1Again = find.byKey(playerTotalScore1Key);
    expect(totalScoreFieldP1Again, findsOneWidget);
    final textFieldP1Again = find.descendant(
      of: totalScoreFieldP1Again,
      matching: find.byType(Text),
    );
    expect(textFieldP1Again, findsOneWidget);
    final textFieldWidgetP1Again = tester.widget<Text>(textFieldP1Again);
    final totalScoreTextP1Again = textFieldWidgetP1Again.data;
    expect(totalScoreTextP1Again, '10');

    // Enable editing in player 1 round 3 and validate that the round_score for player 0 round 3 is enabled for editing
    // Click on the lock icon in round 3 to unlock the column (header row)
    final unlockIcon = find.byKey(lockRound3Key);
    expect(unlockIcon, findsOneWidget);
    await tester.tap(unlockIcon);
    await tester.pumpAndSettle();

    // Validate the round score field at player 1 round 3 is enabled
    final roundScoreFieldP1R3Enabled = find.byKey(roundScoreP0R3Key);
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

    // Verify that after unlocking, the fields still contain the same values
    expect(widgetP1R3Enabled.controller?.text, '5');

    final roundScoreFieldP1R3Enabled2 = find.byKey(roundScoreP1R3Key);
    expect(roundScoreFieldP1R3Enabled2, findsOneWidget);
    final textFormFieldP1R3Enabled2 = find.descendant(
      of: roundScoreFieldP1R3Enabled2,
      matching: find.byType(TextFormField),
    );
    expect(textFormFieldP1R3Enabled2, findsOneWidget);
    final widgetP1R3Enabled2 = tester.widget<TextFormField>(
      textFormFieldP1R3Enabled2,
    );
    expect(widgetP1R3Enabled2.enabled, isTrue);
    expect(widgetP1R3Enabled2.controller?.text, '10');

    // Verify that after unlocking, the totals still have the same values
    final totalScoreFieldP0Final = find.byKey(playerTotalScore0Key);
    expect(totalScoreFieldP0Final, findsOneWidget);
    final textFieldP0Final = find.descendant(
      of: totalScoreFieldP0Final,
      matching: find.byType(Text),
    );
    expect(textFieldP0Final, findsOneWidget);
    final textFieldWidgetP0Final = tester.widget<Text>(textFieldP0Final);
    final totalScoreTextP0Final = textFieldWidgetP0Final.data;
    expect(totalScoreTextP0Final, '65');

    final totalScoreFieldP1Final = find.byKey(playerTotalScore1Key);
    expect(totalScoreFieldP1Final, findsOneWidget);
    final textFieldP1Final = find.descendant(
      of: totalScoreFieldP1Final,
      matching: find.byType(Text),
    );
    expect(textFieldP1Final, findsOneWidget);
    final textFieldWidgetP1Final = tester.widget<Text>(textFieldP1Final);
    final totalScoreTextP1Final = textFieldWidgetP1Final.data;
    expect(totalScoreTextP1Final, '10');

    // Validate the player 0 score is still 65 and player 1 score is still 10
    expect(totalScoreTextP0Again, '65');
    expect(totalScoreTextP1Again, '10');
  });
}
