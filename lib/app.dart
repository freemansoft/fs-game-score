import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_game_score/app_bar.dart';
import 'package:fs_game_score/score_table.dart';
import 'package:fs_game_score/splash_screen.dart';

class Phase10App extends ConsumerStatefulWidget {
  const Phase10App({super.key});

  @override
  ConsumerState<Phase10App> createState() => _Phase10AppState();
}

class _Phase10AppState extends ConsumerState<Phase10App> {
  bool _showSplash = true;

  void _onSplashContinue() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Phase-10 Scoreboard',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white, // Set background to white
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home:
          _showSplash
              ? SplashScreen(onContinue: _onSplashContinue)
              : Scaffold(
                appBar: Phase10AppBar(),
                body: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: ScoreTable(),
                ),
              ),
    );
  }
}

// Wraps Phase10App with ProviderScope for use in tests and main
class Phase10AppBuilder extends StatelessWidget {
  const Phase10AppBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: Phase10App());
  }
}
