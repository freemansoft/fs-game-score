import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/presentation/app_theme.dart';
import 'package:fs_score_card/router/app_router.dart';

class Phase10App extends ConsumerWidget {
  const Phase10App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FS Score Card',
      // left in for debugging purposes
      // ignore: avoid_redundant_argument_values
      showSemanticsDebugger: false, // shows outlines for the semantics tree
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      routerConfig: appRouter,
      //debugShowCheckedModeBanner: false,
    );
  }
}
