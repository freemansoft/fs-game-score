import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/main.dart' as app;
import 'package:fs_score_card/presentation/player_game_cell.dart';
import 'package:fs_score_card/presentation/player_round_cell.dart';
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
}
