import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_game_score/provider/game_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback? onContinue;
  const SplashScreen({super.key, this.onContinue});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      // package_info_plus is already in pubspec.yaml
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FreemanS Game Scorecard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Number of Players:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Maximum Rounds:', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                DropdownButton<int>(
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sheet Style:', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                DropdownButton<String>(
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(gameProvider.notifier).setNumPlayers(_selectedPlayers);
                ref
                    .read(gameProvider.notifier)
                    .setMaxRounds(_selectedMaxRounds);
                ref
                    .read(gameProvider.notifier)
                    .setEnablePhases(_sheetStyle == 'Include Phases');
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
