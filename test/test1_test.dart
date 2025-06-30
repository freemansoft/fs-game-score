import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_game_score/app.dart';

void main() {
  testWidgets('ScoreTable widget test for player name and score fields', (
    WidgetTester tester,
  ) async {
    // Build the app using the builder
    await tester.pumpWidget(const Phase10AppBuilder());
    await tester.pumpAndSettle();

    // Find the PlayerNameField for the first player
    final nameFieldKey = const ValueKey('player_name_field_0');
    final nameFieldFinder = find.byKey(nameFieldKey);
    expect(nameFieldFinder, findsOneWidget);

    // Find the TextFormField inside PlayerNameField and enter "joe"
    final nameTextFieldFinder = find.descendant(
      of: nameFieldFinder,
      matching: find.byType(TextFormField),
    );
    expect(nameTextFieldFinder, findsOneWidget);
    await tester.tap(nameTextFieldFinder);
    await tester.enterText(nameTextFieldFinder, 'joe');
    await tester.pumpAndSettle();

    // Verify the name in the text field is "joe"
    final nameTextFieldWidget = tester.widget<TextFormField>(
      nameTextFieldFinder,
    );
    expect(nameTextFieldWidget.controller?.text, 'joe');

    // Verify the first player's total score Text holds 0
    final totalScoreKey = const ValueKey('player_total_score_0');
    final totalScoreFinder = find.byKey(totalScoreKey);
    expect(totalScoreFinder, findsOneWidget);
    expect((tester.widget<Text>(totalScoreFinder)).data, '0');

    // Enter 10 in the first player's round 1 score field (round 0)
    final round1ScoreKey = const ValueKey('round_score_p0_r0');
    final round1ScoreFinder = find.byKey(round1ScoreKey);
    expect(round1ScoreFinder, findsOneWidget);
    final round1TextFieldFinder = find.descendant(
      of: round1ScoreFinder,
      matching: find.byType(TextFormField),
    );
    expect(round1TextFieldFinder, findsOneWidget);
    await tester.tap(round1TextFieldFinder);
    await tester.enterText(round1TextFieldFinder, '10');
    await tester.pumpAndSettle();

    // Enter 15 in the first player's round 2 score field (round 1)
    final round2ScoreKey = const ValueKey('round_score_p0_r1');
    final round2ScoreFinder = find.byKey(round2ScoreKey);
    expect(round2ScoreFinder, findsOneWidget);
    final round2TextFieldFinder = find.descendant(
      of: round2ScoreFinder,
      matching: find.byType(TextFormField),
    );
    expect(round2TextFieldFinder, findsOneWidget);
    await tester.tap(round2TextFieldFinder);
    await tester.enterText(round2TextFieldFinder, '15');
    await tester.pumpAndSettle();

    // Verify the first player's total score Text holds 25
    expect((tester.widget<Text>(totalScoreFinder)).data, '25');
  });
}
