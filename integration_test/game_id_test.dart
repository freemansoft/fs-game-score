import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/app.dart';
import 'package:fs_score_card/main.dart' as app;
import 'package:fs_score_card/presentation/player_game_cell.dart';
import 'package:fs_score_card/presentation/player_game_modal.dart';
import 'package:fs_score_card/presentation/player_round_cell.dart';
import 'package:fs_score_card/presentation/player_round_modal.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Clear SharedPreferences for 'game_state' before each test
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_state');
  });

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

  /// Tests that gameId persists during configuration changes (copyWith operations)
  testWidgets('GameId persists during game configuration changes', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Define ValueKeys used in the test
    const splashContinueButtonKey = SplashScreen.continueButtonKey;

    // Press Continue to start the game
    final continueButton = find.byKey(splashContinueButtonKey);
    expect(continueButton, findsOneWidget);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);
    // Grab the ProviderScope container immediately after locating the button
    final container = ProviderScope.containerOf(
      tester.element(find.byType(DataTable2)),
    );

    // Verify the inital game id
    final gameNotifier = container.read(gameProvider.notifier);
    final initialGame = container.read(gameProvider);
    final initialGameId = initialGame.gameId;
    expect(initialGameId, isNotEmpty);

    // Change some game configuration using copyWith operations
    gameNotifier.setMaxRounds(20);
    await tester.pumpAndSettle();

    final gameAfterMaxRoundsChange = container.read(gameProvider);
    expect(gameAfterMaxRoundsChange.gameId, equals(initialGameId));
    expect(gameAfterMaxRoundsChange.maxRounds, equals(20));

    // Change another configuration
    gameNotifier.setNumPlayers(6);
    await tester.pumpAndSettle();

    final gameAfterNumPlayersChange = container.read(gameProvider);
    expect(gameAfterNumPlayersChange.gameId, equals(initialGameId));
    expect(gameAfterNumPlayersChange.numPlayers, equals(6));

    // Change enablePhases
    gameNotifier.setEnablePhases(enablePhases: false);
    await tester.pumpAndSettle();

    final gameAfterPhasesChange = container.read(gameProvider);
    expect(gameAfterPhasesChange.gameId, equals(initialGameId));
    expect(gameAfterPhasesChange.enablePhases, equals(false));

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
    gameNotifier.newGame();
    await tester.pumpAndSettle();

    // Get the second gameId
    final secondGame = container.read(gameProvider);
    final secondGameId = secondGame.gameId;
    expect(secondGameId, isNotEmpty);
    expect(secondGameId, isNot(equals(firstGameId)));

    // Create another new game
    gameNotifier.newGame();
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
}
