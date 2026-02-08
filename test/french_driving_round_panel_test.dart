import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/french_driving_round_attributes.dart';
import 'package:fs_score_card/presentation/player_round/french_driving_round_panel.dart';

void main() {
  Widget buildTestableWidget(
    FrenchDrivingRoundAttributes attributes, {
    Size size = const Size(800, 600),
  }) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: FrenchDrivingRoundPanel(
            attributes: attributes,
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets(
    'FrenchDrivingRoundPanel displays safeties horizontally in landscape',
    (WidgetTester tester) async {
      final attributes = FrenchDrivingRoundAttributes();

      // Set landscape size
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        // I like being explicit in case the default changes
        // ignore: avoid_redundant_argument_values
        buildTestableWidget(attributes, size: const Size(800, 600)),
      );
      await tester.pumpAndSettle();

      // Find the safeties dropdown and coup fourre dropdown
      final safetiesDropdown = find.byKey(
        FrenchDrivingRoundPanel.safetiesDropdownKey,
      );
      final coupFourreDropdown = find.byKey(
        FrenchDrivingRoundPanel.coupFourreDropdownKey,
      );

      expect(safetiesDropdown, findsOneWidget);
      expect(coupFourreDropdown, findsOneWidget);

      // Get positions
      final safetiesPos = tester.getCenter(safetiesDropdown);
      final coupFourrePos = tester.getCenter(coupFourreDropdown);

      // In landscape, they should be on the same horizontal line (roughly)
      // and safeties should be to the left of coup fourre
      expect(safetiesPos.dy, closeTo(coupFourrePos.dy, 1.0));
      expect(safetiesPos.dx, lessThan(coupFourrePos.dx));

      addTearDown(tester.view.resetPhysicalSize);
    },
  );

  testWidgets(
    'FrenchDrivingRoundPanel displays safeties vertically in portrait',
    (WidgetTester tester) async {
      final attributes = FrenchDrivingRoundAttributes();

      // Set portrait size
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestableWidget(attributes, size: const Size(300, 600)),
      );
      await tester.pumpAndSettle();

      // Find the safeties dropdown and coup fourre dropdown
      final safetiesDropdown = find.byKey(
        FrenchDrivingRoundPanel.safetiesDropdownKey,
      );
      final coupFourreDropdown = find.byKey(
        FrenchDrivingRoundPanel.coupFourreDropdownKey,
      );

      expect(safetiesDropdown, findsOneWidget);
      expect(coupFourreDropdown, findsOneWidget);

      // Get positions
      final safetiesPos = tester.getCenter(safetiesDropdown);
      final coupFourrePos = tester.getCenter(coupFourreDropdown);

      // In portrait, safeties should be above coup fourre
      expect(safetiesPos.dy, lessThan(coupFourrePos.dy));

      addTearDown(tester.view.resetPhysicalSize);
    },
  );
}
