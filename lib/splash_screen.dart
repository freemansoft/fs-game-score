import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fs_score_card/model/game.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback? onContinue;
  const SplashScreen({super.key, this.onContinue});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const String _gamePrefsKey = 'game_state';
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadGameFromPrefs();
  }

  Future<void> _loadGameFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final gameJson = prefs.getString(_gamePrefsKey);
    if (gameJson != null && gameJson.isNotEmpty) {
      try {
        final game = Game.fromJson(gameJson);
        ref.read(gameProvider.notifier).setNumPlayers(game.numPlayers);
        ref.read(gameProvider.notifier).setMaxRounds(game.maxRounds);
        ref.read(gameProvider.notifier).setEnablePhases(game.enablePhases);
        ref.read(gameProvider.notifier).setVersion(game.version);
        setState(() {
          _selectedPlayers = game.numPlayers;
          _selectedMaxRounds = game.maxRounds;
          _sheetStyle = game.enablePhases ? 'Include Phases' : 'Basic Sheet';
          _scoreFilter = game.scoreFilter;
        });
      } catch (_) {
        // Ignore errors and start fresh
      }
    }
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        if (packageInfo.buildNumber.isNotEmpty) {
          _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
        } else {
          _appVersion = packageInfo.version;
        }
      });
    } catch (_) {
      setState(() {
        _appVersion = null;
      });
    }
  }

  int _selectedPlayers = 2;
  int _selectedMaxRounds = 14;
  String _sheetStyle = 'Basic Sheet';
  String _scoreFilter = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FreemanS Score Card',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Copyright (C) 2025 Joe Freeman',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (_appVersion != null)
              Text(
                'Version: $_appVersion',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Tooltip(
                  message: 'Select the number of players for the game',
                  child: Text(
                    'Number of Players:',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  key: const ValueKey('splash_num_players_dropdown'),
                  value: _selectedPlayers,
                  items: [
                    for (var i = 2; i <= 8; i++)
                      DropdownMenuItem(value: i, child: Text(i.toString())),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPlayers = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Tooltip(
                  message: 'Set the maximum number of rounds for the game',
                  child: Text(
                    'Maximum Rounds:',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  key: const ValueKey('splash_max_rounds_dropdown'),
                  value: _selectedMaxRounds,
                  items: [
                    for (var i = 1; i <= 20; i++)
                      DropdownMenuItem(value: i, child: Text(i.toString())),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMaxRounds = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Tooltip(
                  message: 'Choose the score sheet style: basic or with phases',
                  child: Text('Sheet Style:', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  key: const ValueKey('splash_sheet_style_dropdown'),
                  value: _sheetStyle,
                  items: const [
                    DropdownMenuItem(
                      value: 'Basic Sheet',
                      child: Text('Basic Sheet'),
                    ),
                    DropdownMenuItem(
                      value: 'Include Phases',
                      child: Text('Include Phases'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sheetStyle = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Tooltip(
                  message:
                      'Limit score input values (e.g., any score or those ending in 5 or 0)',
                  child: Text('Score Filter:', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  key: const ValueKey('splash_score_filter_dropdown'),
                  value: _scoreFilter,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Any Score')),
                    DropdownMenuItem(
                      value: r'^[0-9]*[05]$',
                      child: Text('Scores ending in 5 or 0'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _scoreFilter = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              key: const ValueKey('splash_continue_button'),
              onPressed: () async {
                ref.read(gameProvider.notifier).setNumPlayers(_selectedPlayers);
                ref
                    .read(gameProvider.notifier)
                    .setMaxRounds(_selectedMaxRounds);
                ref
                    .read(gameProvider.notifier)
                    .setEnablePhases(_sheetStyle == 'Include Phases');
                ref.read(gameProvider.notifier).setScoreFilter(_scoreFilter);
                ref.read(gameProvider.notifier).setVersion(_appVersion);

                // Save game state to shared preferences
                final prefs = await SharedPreferences.getInstance();
                final game = ref.read(gameProvider.notifier).stateValue();
                await prefs.setString(_gamePrefsKey, game.toJson());

                if (widget.onContinue != null) widget.onContinue!();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
