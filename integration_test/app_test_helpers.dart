import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/data/players_repository.dart';
import 'package:fs_score_card/main.dart' as app;
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clears persisted game and player state before each test.
///
/// Integration tests on devices use real [SharedPreferences], not mocks.
/// Required so `initialLocation` routes to splash (`/`) instead of resuming
/// a previous test's in-flight game.
Future<void> clearPersistedGameState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('game_state');
  await prefs.remove('players_state');
  await prefs.clear();
}

/// Waits until [finder] matches at least one widget or [timeout] elapses.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (tester.any(finder)) {
      return;
    }
  }
  expect(finder, findsOneWidget);
}

/// Launches the app and waits for async startup to finish.
///
/// Awaits `bootstrapApp`, which pre-inits SharedPreferences and mounts
/// `UncontrolledProviderScope` before `runApp`. Calling `main()` without
/// awaiting races the first `pumpAndSettle` on slower Android devices.
/// See `docs/State-Management.md` (Integration and widget testing).
Future<void> launchApp(WidgetTester tester) async {
  await app.bootstrapApp();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

/// `launchApp` then waits until the splash Continue button is visible.
Future<void> launchAppOnSplash(WidgetTester tester) async {
  await launchApp(tester);
  await pumpUntilFound(tester, find.byKey(SplashScreen.continueButtonKey));
}

/// Waits until splash entry has cleared persisted player state.
///
/// Awaits [PlayersNotifier.prepareForSplashEntry] and polls prefs because
/// clearing is async and coalesced saves from the score table can race.
Future<void> waitForSplashPlayersCleared(WidgetTester tester) async {
  final splashFinder = find.byType(SplashScreen);
  expect(splashFinder, findsOneWidget);
  final container = ProviderScope.containerOf(tester.element(splashFinder));
  await container
      .read(playersNotifierProvider.notifier)
      .prepareForSplashEntry();
  await tester.pumpAndSettle();

  final end = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(end)) {
    final prefs = await SharedPreferences.getInstance();
    if (PlayersRepository(prefs).loadPlayers() == null) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 50));
    await container
        .read(playersNotifierProvider.notifier)
        .prepareForSplashEntry();
  }
  fail('players_state was not cleared after returning to splash');
}
