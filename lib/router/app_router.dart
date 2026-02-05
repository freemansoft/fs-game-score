import 'package:fs_score_card/data/game_repository.dart';
import 'package:fs_score_card/data/players_repository.dart';
import 'package:fs_score_card/presentation/score_table_screen.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:go_router/go_router.dart';

// Determine initial route based on loaded state
String _initialLocation() {
  final hasGame = GameRepository().loadedPrefsGame != null;
  final hasPlayers = PlayersRepository().loadedPrefsPlayers != null;

  // Resume game if both game and players state exist
  if (hasGame && hasPlayers) {
    return '/score-table';
  }

  // Otherwise show splash screen
  return '/';
}

// this is a singleton GoRouter instance used throughout the app
// integration tests may need to reset the router state between tests
final appRouter = GoRouter(
  initialLocation: _initialLocation(),
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
