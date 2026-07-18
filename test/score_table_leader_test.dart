import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/presentation/score_table.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> seed(GameMode mode, int endGameScore) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    await container
        .read(gameNotifierProvider.notifier)
        .newGame(
          gameMode: mode,
          numPlayers: 3,
          maxRounds: 1,
          endGameScore: endGameScore,
        );
    container.read(playersNotifierProvider.notifier)
      ..updateScore(0, 0, 10)
      ..updateScore(1, 0, 3) // lowest total
      ..updateScore(2, 0, 7);
    return container;
  }

  Widget wrap(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: Scaffold(
          body: SizedBox(width: 900, height: 600, child: ScoreTable()),
        ),
      ),
    );
  }

  testWidgets('low-wins (Golf) marks the lowest total as leader', (
    tester,
  ) async {
    final container = await seed(GameMode.golf, 0);
    await tester.pumpWidget(wrap(container));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
  });

  testWidgets('high-wins (Standard) shows no leader marker', (tester) async {
    final container = await seed(GameMode.standard, 0);
    await tester.pumpWidget(wrap(container));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.emoji_events), findsNothing);
  });
}
