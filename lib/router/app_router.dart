import 'package:fs_score_card/presentation/score_table_screen.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:go_router/go_router.dart';

// this is a singleton GoRouter instance used throughout the app
// integration tests may need to reset the router state between tests
final appRouter = GoRouter(
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
