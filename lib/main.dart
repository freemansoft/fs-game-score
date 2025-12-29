import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/app.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// https://github.com/flutter/flutter/issues/175606#issuecomment-3453392532
// Error introduced with iPad IOS 26.1 due to iPad window handling

// Top level global
bool _zeroOffsetPointerGuardInstalled = false;
// retrieved from package info
String? appVersion;
// Loaded from shared preferences
Game? loadedPrefsGame;

const String _gamePrefsKey = 'game_state';

void _installZeroOffsetPointerGuard() {
  if (_zeroOffsetPointerGuardInstalled) return;
  GestureBinding.instance.pointerRouter.addGlobalRoute(
    _absorbZeroOffsetPointerEvent,
  );
  _zeroOffsetPointerGuardInstalled = true;
}

void _absorbZeroOffsetPointerEvent(PointerEvent event) {
  if (event.position == Offset.zero) {
    GestureBinding.instance.cancelPointer(event.pointer);
  }
}

Future<void> _loadVersion() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.buildNumber.isNotEmpty) {
      appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } else {
      appVersion = packageInfo.version;
    }
  } catch (_) {
    appVersion = null;
  }
}

// this hack should probably be replaced with AsyncNotifier
Future<void> _loadGameFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final gameJson = prefs.getString(_gamePrefsKey);
  if (gameJson != null && gameJson.isNotEmpty) {
    try {
      final gameFromPrefs = Game.fromJson(gameJson);
      loadedPrefsGame = Game(
        enablePhases: gameFromPrefs.enablePhases,
        endGameScore: gameFromPrefs.endGameScore,
        maxRounds: gameFromPrefs.maxRounds,
        numPhases: gameFromPrefs.numPhases,
        numPlayers: gameFromPrefs.numPlayers,
        scoreFilter: gameFromPrefs.scoreFilter,
        version: gameFromPrefs.version,
      );
    } catch (_) {
      // If deserialization fails, fall back to a new game
      loadedPrefsGame = Game();
    }
  } else {
    loadedPrefsGame = Game();
  }
}

// Not used by main and sitting here so that all the prefs code is in one place
// ignore: unreachable_from_main
Future<void> saveGameToPrefs(Game aGame) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_gamePrefsKey, aGame.toJson());
  // save the load cycle
  loadedPrefsGame = aGame;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installZeroOffsetPointerGuard();
  await _loadVersion();
  await _loadGameFromPrefs();

  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  runApp(
    const ProviderScope(child: Phase10App()),
  );
}
