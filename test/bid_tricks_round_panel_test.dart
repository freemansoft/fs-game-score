import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
import 'package:fs_score_card/presentation/player_round/bid_tricks_round_panel.dart';

void main() {
  Widget wrap(ValueChanged<BidTricksRoundAttributes> onChanged) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: BidTricksRoundPanel(
          attributes: BidTricksRoundAttributes(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  testWidgets('entering a bid emits updated attributes', (tester) async {
    BidTricksRoundAttributes? latest;
    await tester.pumpWidget(wrap((a) => latest = a));

    await tester.enterText(find.byKey(BidTricksRoundPanel.bidFieldKey), '3');
    await tester.pump();
    expect(latest?.bid, 3);

    await tester.enterText(find.byKey(BidTricksRoundPanel.tricksFieldKey), '2');
    await tester.pump();
    expect(latest?.tricksTaken, 2);
  });

  testWidgets('shows the known-limitation note about a 0 bid', (tester) async {
    await tester.pumpWidget(wrap((_) {}));
    expect(find.byKey(BidTricksRoundPanel.zeroBidNoteKey), findsOneWidget);
  });
}
