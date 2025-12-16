import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/presentation/app_theme.dart';
import 'package:fs_score_card/presentation/new_score_card_control.dart';
import 'package:fs_score_card/presentation/score_table_screen.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:fs_score_card/provider/theme_provider.dart';

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
      title: 'FS Score Ccard',
      // left in for debugging purposes
      // ignore: avoid_redundant_argument_values
      showSemanticsDebugger: false, // shows outlines for the semantics tree
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: NotificationListener<NewScoreCardNotification>(
        onNotification: (notification) {
          setState(() {
            _showSplash = true;
          });
          return true;
        },
        child: _showSplash
            ? SplashScreen(onContinue: _onSplashContinue)
            : const ScoreTableScreen(),
      ),
      //debugShowCheckedModeBanner: false,
    );
  }
}

// Wraps Phase10App with ProviderScope for use in tests and main
class Phase10AppBuilder extends StatelessWidget {
  const Phase10AppBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: Phase10App());
  }
}
