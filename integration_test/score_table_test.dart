import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/app.dart';
import 'package:fs_score_card/player_round_cell.dart';
import 'package:fs_score_card/player_round_modal.dart';
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
    const playerNameFieldP0Key = ValueKey('p0_name');
    const playerNameFieldP1Key = ValueKey('p1_name');

    // for lock/unlock tests
    const playerRoundCellP0R3Key = ValueKey('p0_r3_cell');
    const playerRoundCellP1R3Key = ValueKey('p1_r3_cell');

    // to tap and open the panel
    const playerRoundScoreP0R0Key = ValueKey('p0_r0_score');
    const playerRoundScoreP0R1Key = ValueKey('p0_r1_score');
    const playerRoundScoreP0R3Key = ValueKey('p0_r3_score');
    const playerRoundScoreP1R3Key = ValueKey('p1_r3_score');

    // actual fields in the modal
    const roundScoreFieldP0R0Key = ValueKey('p0_r0_score_field');
    const roundScoreFieldP0R1Key = ValueKey('p0_r1_score_field');
    const roundScoreFieldP0R3Key = ValueKey('p0_r3_score_field');
    const roundScoreFieldP1R3Key = ValueKey('p1_r3_score_field');

    const playerTotalScoreP0Key = ValueKey('p0_total_score');
    const playerTotalScoreP1Key = ValueKey('p1_total_score');
    const lockRound3Key = ValueKey('lock_r3');

    // Only press Continue (no dropdown changes)
    final continueButton = find.byKey(splashContinueButtonKey);
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);

    // Verify 2 player rows (excluding header)
    final playerNameFields = find.byKey(playerNameFieldP0Key);
    expect(playerNameFields, findsOneWidget);
    expect(find.byKey(playerNameFieldP1Key), findsOneWidget);

    // Verify 5 round columns for each player (score fields only)
    for (int playerIdx = 0; playerIdx < 2; playerIdx++) {
      for (int round = 0; round < 5; round++) {
        final scoreKey = ValueKey('p${playerIdx}_r${round}_score');
        expect(
          find.byKey(scoreKey),
          findsOneWidget,
          reason: 'Cannot find score field for player $playerIdx round $round',
        );
      }
    }

    // tap on the roundScoreP0R0 to open the PlayerRoundCellModelPanel
    await tester.tap(find.byKey(playerRoundScoreP0R0Key));
    await tester.pumpAndSettle();
    // verify the PlayerRoundModal is displayed
    expect(find.byType(PlayerRoundModal), findsOneWidget);

    // Enter the value "20" in the round score field for player 1 round 1
    final scoreField1 = find.byKey(roundScoreFieldP0R0Key);
    expect(scoreField1, findsOneWidget);
    await tester.enterText(scoreField1, '20');
    await tester.pumpAndSettle();

    // close the PlayerRoundCellModelPanel
    // find an object outside the modal - AlertDialog and tap to close
    await tester.tapAt(tester.getTopLeft(find.byType(Phase10App)));
    await tester.pumpAndSettle(); // Wait for the dialog to dismiss
    // validate that the text in the table matches the input
    expect(
      (tester.widget(find.byKey(playerRoundScoreP0R0Key)) as Text).data,
      '20',
    );

    // tap on the roundScoreP0R0 to open the PlayerRoundCellModelPanel
    await tester.tap(find.byKey(playerRoundScoreP0R1Key));
    await tester.pumpAndSettle();
    // verify the PlayerRoundModal is displayed
    expect(find.byType(PlayerRoundModal), findsOneWidget);

    // Enter the value "40" in the round score field for player 1 round 2
    final scoreField2 = find.byKey(roundScoreFieldP0R1Key);
    expect(scoreField2, findsOneWidget);
    await tester.enterText(scoreField2, '40');
    await tester.pumpAndSettle();

    // close the PlayerRoundCellModelPanel
    // find an object outside the modal - AlertDialog and tap to close
    await tester.tapAt(tester.getTopLeft(find.byType(Phase10App)));
    await tester.pumpAndSettle(); // Wait for the dialog to dismiss

    // validate that the text in the table matches the input
    expect(
      (tester.widget(find.byKey(playerRoundScoreP0R1Key)) as Text).data,
      '40',
    );

    // validate the player totals
    expect(
      (tester.widget(find.byKey(playerTotalScoreP0Key)) as Text).data,
      '60',
    );
    expect(
      (tester.widget(find.byKey(playerTotalScoreP1Key)) as Text).data,
      '0',
    );

    // additional redundant data entry testing

    // Enter values of 5*(player number +1) in column 3 (round 3) for all players
    // Player 0: 5*(0+1) = 5, Player 1: 5*(1+1) = 10
    // tap on the roundScoreP0R0 to open the PlayerRoundCellModelPanel

    // click to open the editing panel
    await tester.tap(find.byKey(playerRoundScoreP0R3Key));
    await tester.pumpAndSettle();
    // verify the PlayerRoundModal is displayed
    expect(find.byType(PlayerRoundModal), findsOneWidget);

    final round3ScoreFieldP0 = find.byKey(roundScoreFieldP0R3Key);
    expect(round3ScoreFieldP0, findsOneWidget);
    await tester.enterText(round3ScoreFieldP0, '5');
    await tester.pumpAndSettle();

    // close the PlayerRoundCellModelPanel
    // find an object outside the modal - AlertDialog and tap to close
    await tester.tapAt(tester.getTopLeft(find.byType(Phase10App)));
    await tester.pumpAndSettle(); // Wait for the dialog to dismiss

    // validate that the text in the table matches the input
    expect(
      (tester.widget(find.byKey(playerRoundScoreP0R3Key)) as Text).data,
      '5',
    );

    // validate the new total
    expect(
      (tester.widget(find.byKey(playerTotalScoreP0Key)) as Text).data,
      '65',
    );

    await tester.tap(find.byKey(playerRoundScoreP1R3Key));
    await tester.pumpAndSettle();
    // verify the PlayerRoundModal is displayed
    expect(find.byType(PlayerRoundModal), findsOneWidget);

    final round3ScoreFieldP1 = find.byKey(roundScoreFieldP1R3Key);
    expect(round3ScoreFieldP1, findsOneWidget);
    await tester.enterText(round3ScoreFieldP1, '10');
    await tester.pumpAndSettle();

    // close the PlayerRoundCellModelPanel
    // find an object outside the modal - AlertDialog and tap to close
    await tester.tapAt(tester.getTopLeft(find.byType(Phase10App)));
    await tester.pumpAndSettle(); // Wait for the dialog to dismiss

    // validate that the text in the table matches the input
    expect(
      (tester.widget(find.byKey(playerRoundScoreP1R3Key)) as Text).data,
      '10',
    );

    // validate the new total for this player
    expect(
      (tester.widget(find.byKey(playerTotalScoreP1Key)) as Text).data,
      '10',
    );

    // Click on the lock icon in round 3 to lock the column (header row)
    final lockIcon = find.byKey(lockRound3Key);
    expect(lockIcon, findsOneWidget);
    await tester.tap(lockIcon);
    await tester.pumpAndSettle();

    // Validate the round score field at player round 3 is disabled and has the same value
    expect(
      (tester.widget(find.byKey(playerRoundCellP0R3Key)) as PlayerRoundCell)
          .enabled,
      false,
    );
    expect(
      (tester.widget(find.byKey(playerRoundScoreP0R3Key)) as Text).data,
      '5',
    );

    expect(
      (tester.widget(find.byKey(playerRoundCellP1R3Key)) as PlayerRoundCell)
          .enabled,
      false,
    );
    expect(
      (tester.widget(find.byKey(playerRoundScoreP1R3Key)) as Text).data,
      '10',
    );

    // validate lock/unlock does not change the totals
    expect(
      (tester.widget(find.byKey(playerTotalScoreP0Key)) as Text).data,
      '65',
    );
    expect(
      (tester.widget(find.byKey(playerTotalScoreP1Key)) as Text).data,
      '10',
    );

    // Enable editing in player 1 round 3 and validate that the round_score for player 0 round 3 is enabled for editing
    // Click on the lock icon in round 3 to unlock the column (header row)
    final unlockIcon = find.byKey(lockRound3Key);
    expect(unlockIcon, findsOneWidget);
    await tester.tap(unlockIcon);
    await tester.pumpAndSettle();

    // Validate the round score field at player 0 round 3 is enabled and has the same values
    expect(
      (tester.widget(find.byKey(playerRoundCellP0R3Key)) as PlayerRoundCell)
          .enabled,
      true,
    );
    expect(
      (tester.widget(find.byKey(playerRoundScoreP0R3Key)) as Text).data,
      '5',
    );
    // Validate the round score field at player 1 round 3 is enabled and has the same values
    expect(
      (tester.widget(find.byKey(playerRoundCellP1R3Key)) as PlayerRoundCell)
          .enabled,
      true,
    );
    expect(
      (tester.widget(find.byKey(playerRoundScoreP1R3Key)) as Text).data,
      '10',
    );

    // validate lock/unlock does not change the totals
    expect(
      (tester.widget(find.byKey(playerTotalScoreP0Key)) as Text).data,
      '65',
    );
    expect(
      (tester.widget(find.byKey(playerTotalScoreP1Key)) as Text).data,
      '10',
    );
  });
}
