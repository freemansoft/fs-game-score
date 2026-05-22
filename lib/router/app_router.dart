import 'package:fs_score_card/data/game_repository.dart';
import 'package:fs_score_card/data/players_repository.dart';
import 'package:fs_score_card/presentation/score_table_screen.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Determine initial route based on restorable persisted state.
///
/// Loads game and players from [prefs] and resumes only when both deserialize
/// successfully and player dimensions match the saved game configuration.
String initialLocation(SharedPreferences prefs) {
  final game = GameRepository(prefs).loadGame();
  final players = PlayersRepository(prefs).loadPlayers();
  if (game != null &&
      players != null &&
      playersMatchConfiguration(players, game.configuration)) {
    return '/score-table';
  }

  return '/';
}

/// Creates the app router with the initial location determined by
/// the current [SharedPreferences] state.
///
/// Integration tests may need to create a new router between tests to
/// reset routing state.
GoRouter createAppRouter(SharedPreferences prefs) {
  return GoRouter(
    initialLocation: initialLocation(prefs),
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/score-table',
        name: 'scoreTable',
        builder: (context, state) => const ScoreTableScreen(),
      ),
    ],
  );
}
