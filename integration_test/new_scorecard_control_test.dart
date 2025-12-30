import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/main.dart' as app;
import 'package:fs_score_card/presentation/new_score_card_control.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:fs_score_card/router/app_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Clear SharedPreferences for 'game_state' before each test
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_state');
    // Reset the app router to initial state before each test
    appRouter.goNamed('splash');
  });

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
    final dropdownListFinder2 = find.byType(ListView);
    final targetItemFinder2 = find.text('3');
    // have to drag to a larger number because we are lower than the target
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
}
