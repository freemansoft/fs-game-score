import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/app.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Reuse the project's race-safe splash/score-table wait helpers. Splash entry
// prep and score-table navigation have documented ordering hazards (see
// integration_test/app_test_helpers.dart and docs/State-Management.md).
import 'app_test_helpers.dart';

/// End-to-end smoke drive of the real app for the `run-fs-game-score` skill.
///
/// Drives the actual Flutter app on whatever `-d <device>` you pass to
/// `flutter drive` and captures PNGs to build/driver-screenshots/ via
/// [.claude/skills/run-fs-game-score/drive_screenshots.dart].
///
/// This mounts the same `UncontrolledProviderScope(container, Phase10App())`
/// widget tree that `main.bootstrapApp()` mounts, but pumps it directly instead
/// of calling `bootstrapApp()`. That deliberately skips one line that
/// `bootstrapApp` runs on web only:
///   `SemanticsBinding.instance.ensureSemantics();`
/// which returns a `SemanticsHandle` that main never disposes. On web that
/// leaked handle trips flutter_test's end-of-test "SemanticsHandle was active"
/// verification and fails the drive after the screenshots are already written.
/// Pumping the tree ourselves keeps full UI fidelity with a clean teardown.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('run skill smoke: splash then score table', (tester) async {
    // Start from a clean slate so the router lands on splash, not a resumed
    // in-progress game.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Same wiring as main.bootstrapApp(): prefs are ready before the tree
    // mounts so repository providers can load synchronously in build().
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const Phase10App(),
      ),
    );
    await tester.pumpAndSettle();

    // Wait for splash to be interactive, then capture it.
    await pumpUntilFound(tester, find.byKey(SplashScreen.continueButtonKey));
    await waitForSplashReady(tester);
    await binding.takeScreenshot('01-splash');

    // Start a new game with the default configuration.
    await tester.tap(find.byKey(SplashScreen.continueButtonKey));
    await tester.pumpAndSettle();

    // Confirm we reached the real score table, then capture it.
    await waitForScoreTable(tester);
    expect(find.byType(DataTable2), findsOneWidget);
    await binding.takeScreenshot('02-score-table');
  });
}
