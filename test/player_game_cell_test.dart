import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/presentation/player_game/player_game_cell.dart';

void main() {
  Widget wrap({required bool isLeader}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: PlayerGameCell(
          playerIdx: 0,
          name: 'Alice',
          totalScore: 3,
          isLeader: isLeader,
          onTap: () {},
        ),
      ),
    );
  }

  testWidgets('shows the leader marker when isLeader is true', (tester) async {
    await tester.pumpWidget(wrap(isLeader: true));
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('shows no leader marker when isLeader is false', (tester) async {
    await tester.pumpWidget(wrap(isLeader: false));
    expect(find.byIcon(Icons.emoji_events), findsNothing);
  });
}
