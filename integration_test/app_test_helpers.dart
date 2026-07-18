import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/data/players_repository.dart';
import 'package:fs_score_card/l10n/app_localizations_en.dart';
import 'package:fs_score_card/main.dart' as app;
import 'package:fs_score_card/presentation/new_score_card_control.dart';
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

/// Waits until splash entry prep finishes ([PlayersNotifier.prepareForSplashEntry]).
///
/// Splash schedules this in a post-frame callback; on slow Android CI emulators
/// it can still be in flight when the Continue button is visible. Call before
/// tapping Continue so clear/save/navigation do not race.
Future<void> waitForSplashReady(WidgetTester tester) async {
  final splashFinder = find.byType(SplashScreen);
  expect(splashFinder, findsOneWidget);
  final container = ProviderScope.containerOf(tester.element(splashFinder));
  await container
      .read(playersNotifierProvider.notifier)
      .prepareForSplashEntry();
  await tester.pumpAndSettle();
}

/// Waits until the score table is mounted after navigation from splash.
Future<void> waitForScoreTable(WidgetTester tester) async {
  await pumpUntilFound(tester, find.byType(DataTable2));
  await pumpUntilFound(tester, find.byKey(NewScoreCardControl.iconButtonKey));
}

/// Taps [NewScoreCardControl.iconButtonKey], opening the AppBar overflow menu when
/// the icon is clipped on narrow devices (e.g. Android CI `medium_phone`).
Future<void> tapNewScoreCardControlIconButton(WidgetTester tester) async {
  final iconButton = find.byKey(NewScoreCardControl.iconButtonKey);
  await pumpUntilFound(tester, iconButton);

  if (_isDirectlyTappable(tester, iconButton)) {
    await tester.tap(iconButton);
    await tester.pumpAndSettle();
    return;
  }

  final overflowMenu = find.byIcon(Icons.more_vert);
  if (!tester.any(overflowMenu)) {
    await tester.ensureVisible(iconButton);
    await tester.pumpAndSettle();
    await tester.tap(iconButton);
    await tester.pumpAndSettle();
    return;
  }

  await tester.tap(overflowMenu);
  await tester.pumpAndSettle();

  final tooltip = AppLocalizationsEn().newGameChangeScorecardType;
  final overflowItem = find.byTooltip(tooltip);
  if (tester.any(overflowItem)) {
    await tester.tap(overflowItem);
  } else {
    await tester.tap(find.text(tooltip));
  }
  await tester.pumpAndSettle();
}

bool _isDirectlyTappable(WidgetTester tester, Finder finder) {
  if (!tester.any(finder)) {
    return false;
  }
  final size = tester.getSize(finder);
  if (size.width < 8 || size.height < 8) {
    return false;
  }
  final center = tester.getCenter(finder);
  final viewWidth =
      tester.view.physicalSize.width / tester.view.devicePixelRatio;
  return center.dx >= 0 && center.dx <= viewWidth;
}

/// `launchApp`, splash Continue visibility, and [waitForSplashReady].
Future<void> launchAppOnSplash(WidgetTester tester) async {
  await launchApp(tester);
  await pumpUntilFound(tester, find.byKey(SplashScreen.continueButtonKey));
  await waitForSplashReady(tester);
}

/// Waits until splash entry has cleared persisted player state.
///
/// Awaits [PlayersNotifier.prepareForSplashEntry] and polls prefs because
/// clearing is async and coalesced saves from the score table can race.
Future<void> waitForSplashPlayersCleared(WidgetTester tester) async {
  final splashFinder = find.byType(SplashScreen);
  // Navigation back to splash (via "Change Scorecard") is async: on slow
  // Android CI emulators the route can still be mounting when the caller's
  // pumpAndSettle returns. Poll for the splash before reading its element —
  // same race class that 1e9f11a fixed for the Continue button.
  await pumpUntilFound(tester, splashFinder);
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
