import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/presentation/app_theme.dart';
import 'package:fs_score_card/presentation/score_table_screen.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:fs_score_card/provider/theme_provider.dart';

class Phase10App extends ConsumerWidget {
  const Phase10App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return MaterialApp(
      title: 'FS Score Ccard',
      // left in for debugging purposes
      // ignore: avoid_redundant_argument_values
      showSemanticsDebugger: false, // shows outlines for the semantics tree
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/score-table': (context) => const ScoreTableScreen(),
      },
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
