import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fs_game_score/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Navigates to the scoring table and verifies the table functionality
  /// matches what was specified in th esplash screen
  testWidgets('Score table displays correct rows, columns, and widgets', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Select 4 players
    final playersDropdown = find.byKey(
      const ValueKey('splash_num_players_dropdown'),
    );
    expect(playersDropdown, findsOneWidget);
    await tester.tap(playersDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('4').last);
    await tester.pumpAndSettle();

    // Select 5 rounds
    final roundsDropdown = find.byKey(
      const ValueKey('splash_max_rounds_dropdown'),
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
      const ValueKey('splash_sheet_style_dropdown'),
    );
    expect(sheetDropdown, findsOneWidget);
    await tester.tap(sheetDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Include Phases').last);
    await tester.pumpAndSettle();

    // Press Continue
    final continueButton = find.byKey(const ValueKey('splash_continue_button'));
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify score table is displayed
    expect(find.byType(DataTable2), findsOneWidget);

    // Verify 4 player rows (excluding header)
    final playerNameFields = find.byKey(const ValueKey('player_name_field_0'));
    expect(playerNameFields, findsOneWidget);
    expect(find.byKey(const ValueKey('player_name_field_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('player_name_field_2')), findsOneWidget);
    expect(find.byKey(const ValueKey('player_name_field_3')), findsOneWidget);

    // Verify 5 round columns for each player (score and phase fields)
    for (int playerIdx = 0; playerIdx < 4; playerIdx++) {
      for (int round = 0; round < 5; round++) {
        final scoreKey = ValueKey('round_score_p${playerIdx}_r$round');
        final phaseKey = ValueKey(
          'phase_checkbox_dropdown_p${playerIdx}_r$round',
        );
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
}
