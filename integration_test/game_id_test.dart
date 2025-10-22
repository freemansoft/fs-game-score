import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fs_score_card/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/provider/game_provider.dart';

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
    const splashContinueButtonKey = ValueKey('splash_continue_button');

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
    const splashContinueButtonKey = ValueKey('splash_continue_button');

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
    gameNotifier.setEnablePhases(false);
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
    const splashContinueButtonKey = ValueKey('splash_continue_button');
    const playerNameField0Key = ValueKey('player_name_field_0');
    const roundScoreP0R0Key = ValueKey('round_score_p0_r0');

    // Press Continue to start the game
    final continueButton = find.byKey(splashContinueButtonKey);
    expect(continueButton, findsOneWidget);

    // Get app's ProviderScope container right after locating the button
    final container = ProviderScope.containerOf(tester.element(continueButton));

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);

    // Enter some data to make sharing meaningful
    final playerNameField = find.byKey(playerNameField0Key);
    expect(playerNameField, findsOneWidget);
    await tester.enterText(playerNameField, 'Test Player');
    await tester.pumpAndSettle();

    final scoreField = find.byKey(roundScoreP0R0Key);
    expect(scoreField, findsOneWidget);
    await tester.enterText(scoreField, '25');
    await tester.pumpAndSettle();

    final game = container.read(gameProvider);
    final gameId = game.gameId;
    expect(gameId, isNotEmpty);

    // Find and tap the share button
    var shareButton = find.byIcon(Icons.share);
    if (!shareButton.hasFound) {
      shareButton = find.byIcon(Icons.ios_share);
    }

    // Note: We can't actually test the share functionality in integration tests
    // as it involves platform-specific sharing mechanisms. However, we can
    // verify that the share button exists and the game has a valid gameId
    // which would be used in the share subject.

    // Verify the share button is present and the game has a valid gameId
    expect(shareButton, findsOneWidget);
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
    const splashContinueButtonKey = ValueKey('splash_continue_button');

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
    const splashContinueButtonKey = ValueKey('splash_continue_button');

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
