import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/app.dart';
import 'package:fs_score_card/main.dart' as app;
import 'package:fs_score_card/presentation/new_score_card_control.dart';
import 'package:fs_score_card/presentation/player_game_cell.dart';
import 'package:fs_score_card/presentation/player_game_modal.dart';
import 'package:fs_score_card/presentation/player_round_cell.dart';
import 'package:fs_score_card/presentation/player_round_modal.dart';
import 'package:fs_score_card/presentation/score_table.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/router/app_router.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Reset the app router to initial state before each test
    appRouter.goNamed('splash');
  });

  // ========== Game ID Tests ==========

  /// Tests that new game creation generates unique gameIds
  testWidgets('Start new game of the same type retains the gameIds', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Define ValueKeys used in the test
    const splashContinueButtonKey = SplashScreen.continueButtonKey;

    // Press Continue to start the game
    final continueButton = find.byKey(splashContinueButtonKey);
    expect(continueButton, findsOneWidget);

    // Get the app's ProviderScope container right after locating the button
    //final container = ProviderScope.containerOf(tester.element(continueButton));

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    final firstDataTable = find.byType(DataTable2);
    expect(firstDataTable, findsOneWidget);
    final firstContainer = ProviderScope.containerOf(
      tester.element(firstDataTable),
    );

    final firstGameProvider = firstContainer.read(gameProvider);
    final firstGameId = firstGameProvider.gameId;
    expect(firstGameId, isNotEmpty);

    // Find and tap the New Game button (replay icon)
    final newGameButton = find.byIcon(Icons.replay);
    expect(newGameButton, findsOneWidget);
    await tester.tap(newGameButton);
    await tester.pumpAndSettle();

    // Confirm the new game dialog
    final confirmNewGameButton = find.text('New Game');
    expect(confirmNewGameButton, findsOneWidget);
    await tester.tap(confirmNewGameButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    final secondDataTable = find.byType(DataTable2);
    expect(secondDataTable, findsOneWidget);
    final secondContainer = ProviderScope.containerOf(
      tester.element(firstDataTable),
    );
    // Get the second game instance
    final secondGame = secondContainer.read(gameProvider);
    final secondGameId = secondGame.gameId;

    // Verify the gameIds are different
    expect(secondGameId, isNotEmpty);
    expect(secondGameId, equals(firstGameId));

    // Using the app's ProviderScope container; do not dispose it here.
  });

  /// Tests that share functionality includes gameId in subject
  testWidgets('Share functionality includes gameId in subject', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Define ValueKeys used in the test
    const splashContinueButtonKey = SplashScreen.continueButtonKey;

    final playerGameCell0Key = PlayerGameCell.cellKey(0);
    final playerName0Key = PlayerGameCell.nameKey(0);
    final playerTotalScore0Key = PlayerGameCell.totalScoreKey(0);

    // part of the PlayerGameModal
    final playerNameField0Key = PlayerGameModal.nameFieldKey(0);

    // can be clicked on to open the PlayerRoundModal
    final playerRoundCellP0R0Key = PlayerRoundCell.scoreKey(0, 0);

    // part of the PlayerRoundModal
    final roundScoreFieldP0R0Key = PlayerRoundModal.scoreFieldKey(0, 0);

    // Press Continue to start the game
    final continueButton = find.byKey(splashContinueButtonKey);
    expect(continueButton, findsOneWidget);

    // Get app's ProviderScope container right after locating the button
    final container = ProviderScope.containerOf(tester.element(continueButton));

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);
    // verify the player game cell is displayed
    expect(find.byKey(playerGameCell0Key), findsOneWidget);
    expect(find.byKey(playerName0Key), findsOneWidget);
    expect(find.byKey(playerTotalScore0Key), findsOneWidget);

    // click on the player game cell to open the PlayerGameModal
    await tester.tap(find.byKey(playerGameCell0Key));
    await tester.pumpAndSettle();
    // verify the PlayerGameModal is displayed
    expect(find.byType(PlayerGameModal), findsOneWidget);

    // Enter some data to make sharing meaningful
    final playerNameField = find.byKey(playerNameField0Key);
    expect(playerNameField, findsOneWidget);
    await tester.enterText(playerNameField, 'Test Player');
    await tester.pumpAndSettle();

    // find an object outside the modal - AlertDialog and tap to close
    // don't use absolute top because we filter there for ios 26.1 for ipad
    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
    await tester.pumpAndSettle(); // Wait for the dialog to dismiss
    // validate it is goine to verify this approach
    expect(find.byType(PlayerGameModal), findsNothing);

    // click on the player round cell to open the PlayerRoundModal
    await tester.tap(find.byKey(playerRoundCellP0R0Key));
    await tester.pumpAndSettle();
    // verify the PlayerRoundModal is displayed
    expect(find.byType(PlayerRoundModal), findsOneWidget);

    final scoreField = find.byKey(roundScoreFieldP0R0Key);
    expect(scoreField, findsOneWidget);
    await tester.enterText(scoreField, '25');
    await tester.pumpAndSettle();

    // find an object outside the modal - AlertDialog and tap to close
    // offset is because we ignore 0,0 for ipad defect in ios 26.1
    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
    await tester.pumpAndSettle(); // Wait for the dialog to dismiss
    expect(find.byType(PlayerGameModal), findsNothing);

    final game = container.read(gameProvider);
    final gameId = game.gameId;
    expect(gameId, isNotEmpty);

    // Find and tap the share button
    final shareButton = find.byKey(const ValueKey('share_button'));

    // Note: We can't actually test the share functionality in integration tests
    // as it involves platform-specific sharing mechanisms. However, we can
    // verify that the share button exists and the game has a valid gameId
    // which would be used in the share subject.

    // Verify the share button is present and the game has a valid gameId
    expect(shareButton, findsOneWidget, reason: 'Did not find share button');
    // do we really need to verify the gameId format?
    expect(
      gameId,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ),
      ),
    );

    // Using the app's ProviderScope container; do not dispose it here.
  });

  /// Tests that multiple game resets produce different gameIds
  testWidgets('Multiple game resets produce different gameIds', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Define ValueKeys used in the test
    const splashContinueButtonKey = SplashScreen.continueButtonKey;

    // Press Continue to start the game
    final continueButton = find.byKey(splashContinueButtonKey);
    expect(continueButton, findsOneWidget);

    // Grab the app's ProviderScope container right after locating the button
    final container = ProviderScope.containerOf(tester.element(continueButton));

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);

    final gameNotifier = container.read(gameProvider.notifier);

    // Get the first gameId
    final firstGame = container.read(gameProvider);
    final firstGameId = firstGame.gameId;
    expect(firstGameId, isNotEmpty);

    // this is a hack - should have used the New Game button
    // Create a new game
    await gameNotifier.newGame();
    await tester.pumpAndSettle();

    // Get the second gameId
    final secondGame = container.read(gameProvider);
    final secondGameId = secondGame.gameId;
    expect(secondGameId, isNotEmpty);
    expect(secondGameId, isNot(equals(firstGameId)));

    // Create another new game
    await gameNotifier.newGame();
    await tester.pumpAndSettle();

    // Get the third gameId
    final thirdGame = container.read(gameProvider);
    final thirdGameId = thirdGame.gameId;
    expect(thirdGameId, isNotEmpty);
    expect(thirdGameId, isNot(equals(firstGameId)));
    expect(thirdGameId, isNot(equals(secondGameId)));

    // Using the app's ProviderScope container; do not dispose it here.
  });

  /// Tests that splash screen Continue button creates a new gameId
  testWidgets('Splash screen Continue button creates new gameId', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Get the initial gameId from the splash screen
    const splashContinueButtonKey = SplashScreen.continueButtonKey;

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(splashContinueButtonKey)),
    );
    final initialGame = container.read(gameProvider);
    final initialGameId = initialGame.gameId;
    expect(initialGameId, isNotEmpty);

    // Press Continue button on splash screen
    final continueButton = find.byKey(splashContinueButtonKey);
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);

    // Get the new gameId after Continue
    final newGame = container.read(gameProvider);
    final newGameId = newGame.gameId;

    // Verify the gameId has changed (new game was created)
    expect(newGameId, isNot(equals(initialGameId)));
    expect(newGameId, isNotEmpty);

    // Verify the gameId format is valid UUID
    expect(
      newGameId,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ),
      ),
    );

    // Using the app's ProviderScope container; do not dispose it here.
  });

  // ========== New Scorecard Control Tests ==========

  /// Tests that the NewScoreCardControl icon button navigates back to splash screen
  /// and preserves the selected number of players and rounds
  testWidgets(
    'NewScoreCardControl returns to splash screen and preserves settings',
    (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Set the number of players to 2
      final playersDropdown = find.byKey(
        SplashScreen.numPlayersDropdownKey,
      );
      expect(playersDropdown, findsOneWidget);
      await tester.tap(playersDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('2').last);
      await tester.pumpAndSettle();

      // Set the number of rounds to 3
      final roundsDropdown = find.byKey(
        SplashScreen.maxRoundsDropdownKey,
      );
      expect(roundsDropdown, findsOneWidget);
      await tester.tap(roundsDropdown);
      await tester.pumpAndSettle();
      final dropdownListFinder = find.byType(ListView);
      final targetItemFinder = find.text('3');
      // have to drag to a larger number because we are lower than the target
      await tester.dragUntilVisible(
        targetItemFinder,
        dropdownListFinder,
        const Offset(0, 100), // Scroll downwards
      );
      await tester.pumpAndSettle();
      await tester.tap(targetItemFinder);
      await tester.pumpAndSettle();

      // Press Continue to go to the score card
      final continueButton = find.byKey(SplashScreen.continueButtonKey);
      expect(continueButton, findsOneWidget);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verify we're on the score card (look for the app bar and new scorecard control)
      expect(find.byType(NewScoreCardControl), findsOneWidget);

      // Click the icon button to show the confirmation dialog
      final iconButton = find.byKey(NewScoreCardControl.iconButtonKey);
      expect(iconButton, findsOneWidget);
      await tester.tap(iconButton);
      await tester.pumpAndSettle();

      // Verify the dialog is displayed
      expect(find.byType(AlertDialog), findsOneWidget);

      // Click the "Change Scorecard" button
      final changeScorecardButton = find.byKey(
        NewScoreCardControl.changeScorecardButtonKey,
      );
      expect(changeScorecardButton, findsOneWidget);
      await tester.tap(changeScorecardButton);
      await tester.pumpAndSettle();

      // Verify we're back on the splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Verify that the number of players is still 2
      final playersDropdownAfter = find.byKey(
        SplashScreen.numPlayersDropdownKey,
      );
      expect(playersDropdownAfter, findsOneWidget);
      // Tap to open and check the selected value
      await tester.tap(playersDropdownAfter);
      await tester.pumpAndSettle();
      // The selected item should be highlighted/visible
      expect(find.text('2'), findsAtLeast(1));
      await tester.tap(find.text('2').last);
      await tester.pumpAndSettle();

      // Verify that the number of rounds is still 3
      final roundsDropdownAfter = find.byKey(
        SplashScreen.maxRoundsDropdownKey,
      );
      expect(roundsDropdownAfter, findsOneWidget);
      // Tap to open and check the selected value
      await tester.tap(roundsDropdownAfter);
      await tester.pumpAndSettle();
      // The selected item should be highlighted/visible
      expect(find.text('3').last, findsOneWidget);
      await tester.tap(find.text('3').last);
      await tester.pumpAndSettle();
    },
  );

  /// Tests that clicking the cancel button in the dialog does not navigate away
  testWidgets('NewScoreCardControl cancel button stays on score card', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Set players to 2 and rounds to 2, then continue
    final playersDropdown = find.byKey(
      SplashScreen.numPlayersDropdownKey,
    );
    await tester.tap(playersDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    final roundsDropdown = find.byKey(
      SplashScreen.maxRoundsDropdownKey,
    );
    await tester.tap(roundsDropdown);
    await tester.pumpAndSettle();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final dropdownListFinder2 = find.byType(ListView);
    final targetItemFinder2 = find.text('3');

    // have to drag to a larger number because we are lower than the target
    // targetItemFinder2.first is a hack that assumes the one we want is on top
    await tester.dragUntilVisible(
      targetItemFinder2,
      dropdownListFinder2,
      const Offset(0, 200), // Scroll downwards
    );
    await tester.pumpAndSettle();
    await tester.tap(targetItemFinder2);
    await tester.pumpAndSettle();

    final continueButton = find.byKey(SplashScreen.continueButtonKey);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Click the icon button to show the confirmation dialog
    final iconButton = find.byKey(NewScoreCardControl.iconButtonKey);
    await tester.tap(iconButton);
    await tester.pumpAndSettle();

    // Click the cancel button
    final cancelButton = find.byKey(NewScoreCardControl.cancelButtonKey);
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    // Verify we're still on the score card
    expect(find.byType(NewScoreCardControl), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  // ========== Score Table Tests ==========

  /// Navigates to the scoring table and verifies the table functionality
  /// including changing the player name, cell score and column locking
  /// NOTE: We use Round 2 (R2) instead of Round 3 (R3) for testing lock/unlock
  /// functionality to ensure tests pass on narrow devices in portrait mode.
  /// Round 3 (R3) and beyond may not be fully visible without scrolling.
  /// If testing beyond Round 2 is needed, horizontal scrolling would be required.
  testWidgets('Score table displays correct rows and widgets for 2 players', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Define all ValueKeys used in the test
    const splashContinueButtonKey = SplashScreen.continueButtonKey;
    final playerNameFieldP0Key = PlayerGameCell.nameKey(0);
    final playerNameFieldP1Key = PlayerGameCell.nameKey(1);

    // for lock/unlock tests
    final playerRoundCellP0R2Key = PlayerRoundCell.cellKey(0, 2);
    final playerRoundCellP1R2Key = PlayerRoundCell.cellKey(1, 2);

    // to tap and open the panel
    final playerRoundScoreP0R0Key = PlayerRoundCell.scoreKey(0, 0);
    final playerRoundScoreP0R1Key = PlayerRoundCell.scoreKey(0, 1);
    final playerRoundScoreP0R2Key = PlayerRoundCell.scoreKey(0, 2);
    final playerRoundScoreP1R2Key = PlayerRoundCell.scoreKey(1, 2);

    // actual fields in the modal
    final roundScoreFieldP0R0Key = PlayerRoundModal.scoreFieldKey(0, 0);
    final roundScoreFieldP0R1Key = PlayerRoundModal.scoreFieldKey(0, 1);
    final roundScoreFieldP0R2Key = PlayerRoundModal.scoreFieldKey(0, 2);
    final roundScoreFieldP1R2Key = PlayerRoundModal.scoreFieldKey(1, 2);

    final playerTotalScoreP0Key = PlayerGameCell.totalScoreKey(0);
    final playerTotalScoreP1Key = PlayerGameCell.totalScoreKey(1);
    final lockRound2Key = ScoreTable.lockRoundKey(2);

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
        final scoreKey = PlayerRoundCell.scoreKey(playerIdx, round);
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
    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
    await tester.pumpAndSettle(); // Wait for the dialog to dismiss
    // validate that the text in the table matches the input
    expect(
      (tester.widget(find.byKey(playerRoundScoreP0R0Key)) as Text).data,
      '20',
    );

    // tap on the roundScoreP0R1 to open the PlayerRoundCellModelPanel
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
    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
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

    // click to open the editing panel
    await tester.tap(find.byKey(playerRoundScoreP0R2Key));
    await tester.pumpAndSettle();
    // verify the PlayerRoundModal is displayed
    expect(find.byType(PlayerRoundModal), findsOneWidget);

    final round2ScoreFieldP0 = find.byKey(roundScoreFieldP0R2Key);
    expect(round2ScoreFieldP0, findsOneWidget);
    await tester.enterText(round2ScoreFieldP0, '5');
    await tester.pumpAndSettle();

    // close the PlayerRoundCellModelPanel
    // find an object outside the modal - AlertDialog and tap to close
    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
    await tester.pumpAndSettle(); // Wait for the dialog to dismiss

    // validate that the text in the table matches the input
    expect(
      (tester.widget(find.byKey(playerRoundScoreP0R2Key)) as Text).data,
      '5',
    );

    // validate the new total
    expect(
      (tester.widget(find.byKey(playerTotalScoreP0Key)) as Text).data,
      '65',
    );

    await tester.tap(find.byKey(playerRoundScoreP1R2Key));
    await tester.pumpAndSettle();
    // verify the PlayerRoundModal is displayed
    expect(find.byType(PlayerRoundModal), findsOneWidget);

    final round2ScoreFieldP1 = find.byKey(roundScoreFieldP1R2Key);
    expect(round2ScoreFieldP1, findsOneWidget);
    await tester.enterText(round2ScoreFieldP1, '10');
    await tester.pumpAndSettle();

    // close the PlayerRoundCellModelPanel
    // find an object outside the modal - AlertDialog and tap to close
    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
    await tester.pumpAndSettle(); // Wait for the dialog to dismiss

    // validate that the text in the table matches the input
    expect(
      (tester.widget(find.byKey(playerRoundScoreP1R2Key)) as Text).data,
      '10',
    );

    // validate the new total for this player
    expect(
      (tester.widget(find.byKey(playerTotalScoreP1Key)) as Text).data,
      '10',
    );

    // Click on the lock icon in round 2 to lock the column (header row)
    final lockIcon = find.byKey(lockRound2Key);
    expect(lockIcon, findsOneWidget);
    await tester.tap(lockIcon);
    await tester.pumpAndSettle();

    // Validate the round score field at player round 2 is disabled and has the same value
    expect(
      (tester.widget(find.byKey(playerRoundCellP0R2Key)) as PlayerRoundCell)
          .enabled,
      false,
    );
    expect(
      (tester.widget(find.byKey(playerRoundScoreP0R2Key)) as Text).data,
      '5',
    );

    expect(
      (tester.widget(find.byKey(playerRoundCellP1R2Key)) as PlayerRoundCell)
          .enabled,
      false,
    );
    expect(
      (tester.widget(find.byKey(playerRoundScoreP1R2Key)) as Text).data,
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
    // Enable editing in player 1 round 2 and validate that the round_score for player 0 round 2 is enabled for editing
    // Click on the lock icon in round 2 to unlock the column (header row)
    final unlockIcon = find.byKey(lockRound2Key);
    expect(unlockIcon, findsOneWidget);
    await tester.tap(unlockIcon);
    await tester.pumpAndSettle();

    // Validate the round score field at player 0 round 2 is enabled and has the same values
    expect(
      (tester.widget(find.byKey(playerRoundCellP0R2Key)) as PlayerRoundCell)
          .enabled,
      true,
    );
    expect(
      (tester.widget(find.byKey(playerRoundScoreP0R2Key)) as Text).data,
      '5',
    );
    // Validate the round score field at player 1 round 2 is enabled and has the same values
    expect(
      (tester.widget(find.byKey(playerRoundCellP1R2Key)) as PlayerRoundCell)
          .enabled,
      true,
    );
    expect(
      (tester.widget(find.byKey(playerRoundScoreP1R2Key)) as Text).data,
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

  testWidgets(
    'Player game cell shows bold text when endGameScore is set and total score >= endGameScore',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enable end game score checkbox
      final checkbox = find.byKey(SplashScreen.endGameScoreCheckboxKey);
      expect(checkbox, findsOneWidget);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Enter end game score of 100
      final endGameScoreField = find.byKey(SplashScreen.endGameScoreFieldKey);
      expect(endGameScoreField, findsOneWidget);
      await tester.enterText(endGameScoreField, '100');
      await tester.pumpAndSettle();

      // Press Continue to start the game
      final continueButton = find.byKey(SplashScreen.continueButtonKey);
      expect(continueButton, findsOneWidget);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verify score table is displayed
      expect(find.byType(DataTable2), findsOneWidget);

      // Get player 0's round 0 score field
      final playerRoundScoreP0R0Key = PlayerRoundCell.scoreKey(0, 0);
      final roundScoreFieldP0R0Key = PlayerRoundModal.scoreFieldKey(0, 0);
      final playerTotalScoreP0Key = PlayerGameCell.totalScoreKey(0);
      final playerNameP0Key = PlayerGameCell.nameKey(0);

      // Enter score of 100 for player 0 round 0
      await tester.tap(find.byKey(playerRoundScoreP0R0Key));
      await tester.pumpAndSettle();
      expect(find.byType(PlayerRoundModal), findsOneWidget);

      final scoreField = find.byKey(roundScoreFieldP0R0Key);
      expect(scoreField, findsOneWidget);
      await tester.enterText(scoreField, '100');
      await tester.pumpAndSettle();

      // Close the modal
      await tester.tapAt(
        tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PlayerGameModal), findsNothing);

      // Verify total score is 100
      expect(
        (tester.widget(find.byKey(playerTotalScoreP0Key)) as Text).data,
        '100',
      );

      // wait for state to update - not sure how to do this deterministically
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Verify player name and total score text are bold
      final nameText = tester.widget<Text>(find.byKey(playerNameP0Key));
      expect(nameText.style?.fontWeight, FontWeight.bold);

      final totalScoreText = tester.widget<Text>(
        find.byKey(playerTotalScoreP0Key),
      );
      expect(totalScoreText.style?.fontWeight, FontWeight.bold);
    },
  );

  // ========== Splash Screen Tests ==========

  /// Navigates to the scoring table and verifies the table functionality
  /// matches what was specified in th esplash screen
  testWidgets('Score table displays correct rows, columns, and widgets', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Select 4 players
    final playersDropdown = find.byKey(
      SplashScreen.numPlayersDropdownKey,
    );
    expect(playersDropdown, findsOneWidget);
    await tester.tap(playersDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('4').last);
    await tester.pumpAndSettle();

    // Select 5 rounds
    final roundsDropdown = find.byKey(
      SplashScreen.maxRoundsDropdownKey,
    );
    expect(roundsDropdown, findsOneWidget);
    await tester.tap(roundsDropdown);
    await tester.pumpAndSettle();

    // this is a hack to ensure the dropdown scrolls far enough
    // this should be finder and scrollUntilVisible based but I couldn't get AI to do that
    // Try to scroll the dropdown list up to make '1' visible
    final dropdownList = find.byType(Scrollable).last;
    await tester.drag(dropdownList, const Offset(0, 800));
    await tester.pumpAndSettle();
    final firstItem = find.text('1').last;
    await tester.ensureVisible(firstItem);
    await tester.pumpAndSettle();
    expect(firstItem, findsOneWidget);
    await tester.tap(find.text('5').last);
    await tester.pumpAndSettle();

    // Enable "Include Phases"
    final sheetDropdown = find.byKey(
      SplashScreen.sheetStyleDropdownKey,
    );
    expect(sheetDropdown, findsOneWidget);
    await tester.tap(sheetDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Include Phases').last);
    await tester.pumpAndSettle();

    // Press Continue
    final continueButton = find.byKey(SplashScreen.continueButtonKey);
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);

    // Verify 4 player rows (excluding header)
    for (int playerIdx = 0; playerIdx < 4; playerIdx++) {
      final playerNameFields = find.byKey(
        PlayerGameCell.totalScoreKey(playerIdx),
      );
      expect(
        playerNameFields,
        findsOneWidget,
        reason: 'Name field for player $playerIdx',
      );
      final playerScoreFields = find.byKey(
        PlayerGameCell.totalScoreKey(playerIdx),
      );
      expect(
        playerScoreFields,
        findsOneWidget,
        reason: 'Total score field for player $playerIdx',
      );
    }

    // Verify 5 round columns for each player (score and phase fields)
    for (int playerIdx = 0; playerIdx < 4; playerIdx++) {
      for (int round = 0; round < 5; round++) {
        final scoreKey = PlayerRoundCell.scoreKey(playerIdx, round);
        final phaseKey = PlayerRoundCell.phaseKey(playerIdx, round);
        expect(
          find.byKey(scoreKey),
          findsOneWidget,
          reason: 'Score field for player $playerIdx round $round',
        );
        expect(
          find.byKey(phaseKey),
          findsOneWidget,
          reason: 'Phase dropdown for player $playerIdx round $round',
        );
      }
    }
  });

  /// Tests that pressing Continue on splash screen creates a new gameId
  testWidgets('Continue button creates new gameId', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Get the initial gameId before any user interaction
    const splashContinueButtonKey = SplashScreen.continueButtonKey;

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(splashContinueButtonKey)),
    );

    final initialGame = container.read(gameProvider);
    final initialGameId = initialGame.gameId;
    expect(initialGameId, isNotEmpty);

    // Press Continue button to start a new game
    final continueButton = find.byKey(SplashScreen.continueButtonKey);
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);

    // Get the new gameId after Continue
    final newGame = container.read(gameProvider);
    final newGameId = newGame.gameId;

    // Verify the gameId has changed (new game was created)
    expect(newGameId, isNot(equals(initialGameId)));
    expect(newGameId, isNotEmpty);

    // Verify the gameId format is valid UUID
    expect(
      newGameId,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ),
      ),
    );

    // Using the app's ProviderScope container; do not dispose it here.
  });

  testWidgets('End game score checkbox enables and disables field', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Find the checkbox
    final checkbox = find.byKey(SplashScreen.endGameScoreCheckboxKey);
    expect(checkbox, findsOneWidget);

    // Find the text field
    final textField = find.byKey(SplashScreen.endGameScoreFieldKey);
    expect(textField, findsOneWidget);

    // Initially checkbox should be unchecked and field should be disabled
    final checkboxWidget = tester.widget<Checkbox>(checkbox);
    expect(checkboxWidget.value, isFalse);

    final textFieldWidget = tester.widget<TextField>(textField);
    expect(textFieldWidget.enabled, isFalse);

    // Tap the checkbox to enable it
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Checkbox should now be checked and field should be enabled
    final checkboxWidgetAfter = tester.widget<Checkbox>(checkbox);
    expect(checkboxWidgetAfter.value, isTrue);

    final textFieldWidgetAfter = tester.widget<TextField>(textField);
    expect(textFieldWidgetAfter.enabled, isTrue);

    // Enter a score
    await tester.enterText(textField, '100');
    await tester.pumpAndSettle();

    // Tap checkbox again to disable
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Checkbox should be unchecked and field should be disabled and cleared
    final checkboxWidgetFinal = tester.widget<Checkbox>(checkbox);
    expect(checkboxWidgetFinal.value, isFalse);

    final textFieldWidgetFinal = tester.widget<TextField>(textField);
    expect(textFieldWidgetFinal.enabled, isFalse);
    expect(textFieldWidgetFinal.controller?.text, isEmpty);
  });
}
