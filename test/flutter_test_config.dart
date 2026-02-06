import 'dart:async';

import 'package:fs_score_card/data/game_repository.dart';
import 'package:fs_score_card/data/players_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Not convinced this is executed if you execute a single test directly in the ide
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  SharedPreferences.setMockInitialValues({});

  await GameRepository().clearGameFromPrefs();
  await PlayersRepository().clearPlayersFromPrefs();

  await testMain();
}
