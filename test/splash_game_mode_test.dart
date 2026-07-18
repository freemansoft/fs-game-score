import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('game-mode dropdown offers Golf and Hearts', (tester) async {
    // The splash lays its config controls out in a wide row; give the test a
    // surface big enough to avoid the pre-existing narrow-viewport overflow.
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: Scaffold(body: SplashScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open the dropdown.
    await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
    await tester.pumpAndSettle();

    expect(find.text('Golf'), findsWidgets);
    expect(find.text('Hearts'), findsWidgets);
  });

  testWidgets('selecting Golf offers 9/18 rounds and defaults to 18', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: Scaffold(body: SplashScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Select Golf.
    await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Golf').last);
    await tester.pumpAndSettle();

    // The rounds dropdown snaps to Golf's default of 18.
    final roundsDropdown = tester.widget<DropdownButton<int>>(
      find.byKey(SplashScreen.maxRoundsDropdownKey),
    );
    expect(roundsDropdown.value, 18);

    // Opening it offers only 9 and 18 — not the standard 14.
    await tester.tap(find.byKey(SplashScreen.maxRoundsDropdownKey));
    await tester.pumpAndSettle();
    expect(find.text('9'), findsWidgets);
    expect(find.text('18'), findsWidgets);
    expect(find.text('14'), findsNothing);
  });
}
