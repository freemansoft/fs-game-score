import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  static const ValueKey<String> numPlayersDropdownKey = ValueKey(
    'splash_num_players_dropdown',
  );
  static const ValueKey<String> maxRoundsDropdownKey = ValueKey(
    'splash_max_rounds_dropdown',
  );
  static const ValueKey<String> sheetStyleDropdownKey = ValueKey(
    'splash_sheet_style_dropdown',
  );
  static const ValueKey<String> scoreFilterDropdownKey = ValueKey(
    'splash_score_filter_dropdown',
  );
  static const ValueKey<String> endGameScoreCheckboxKey = ValueKey(
    'splash_end_game_score_checkbox',
  );
  static const ValueKey<String> endGameScoreFieldKey = ValueKey(
    'splash_end_game_score_field',
  );
  static const ValueKey<String> continueButtonKey = ValueKey(
    'splash_continue_button',
  );

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const String _basicSheet = 'Basic Sheet';
  static const String _phasesSheet = 'Include Phases';

  static const String _gamePrefsKey = 'game_state';

  // retrieved from package info
  String? _appVersion;

  // We have a local variable for this rather than watching becausae we want to
  // avoid rebuilds of the whole splash screen when changing options
  Game thisGame = Game();
  // whether to enable or disable the game score ending score field
  bool _endGameScoreEnabled = false;
  late final TextEditingController _endGameScoreController;

  @override
  void initState() {
    super.initState();
    _endGameScoreController = TextEditingController();
    _loadVersion();
    _loadGameFromPrefs();
  }

  @override
  void dispose() {
    _endGameScoreController.dispose();
    super.dispose();
  }

  Future<void> _loadGameFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final gameJson = prefs.getString(_gamePrefsKey);
    if (gameJson != null && gameJson.isNotEmpty) {
      try {
        final gameFromPrefs = Game.fromJson(gameJson);
        ref
            .read(gameProvider.notifier)
            .newGame(
              maxRounds: gameFromPrefs.maxRounds,
              numPhases: gameFromPrefs.numPhases,
              numPlayers: gameFromPrefs.numPlayers,
              enablePhases: gameFromPrefs.enablePhases,
              scoreFilter: gameFromPrefs.scoreFilter,
              endGameScore: gameFromPrefs.endGameScore,
              version: _appVersion,
            );

        // version from prefs does not override version of game in app
        setState(() {
          thisGame = gameFromPrefs;
          _endGameScoreEnabled = thisGame.endGameScore > 0;
          _endGameScoreController.text = gameFromPrefs.endGameScore > 0
              ? gameFromPrefs.endGameScore.toString()
              : '';
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

  Widget _buildNumPlayersField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: l10n.numberOfPlayersTooltip,
          child: Text(
            l10n.numberOfPlayers,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<int>(
          key: SplashScreen.numPlayersDropdownKey,
          value: thisGame.numPlayers,
          items: [
            for (var i = 2; i <= 8; i++)
              DropdownMenuItem(value: i, child: Text(i.toString())),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                thisGame = thisGame.copyWith(numPlayers: value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildMaxRoundsField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: l10n.maximumRoundsTooltip,
          child: Text(
            l10n.maximumRounds,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<int>(
          key: SplashScreen.maxRoundsDropdownKey,
          value: thisGame.maxRounds,
          items: [
            for (var i = 1; i <= 20; i++)
              DropdownMenuItem(value: i, child: Text(i.toString())),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                thisGame = thisGame.copyWith(maxRounds: value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSheetStyleField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: l10n.sheetStyleTooltip,
          child: Text(
            l10n.sheetStyle,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          key: SplashScreen.sheetStyleDropdownKey,
          value: thisGame.enablePhases ? _phasesSheet : _basicSheet,
          items: [
            DropdownMenuItem(
              value: _basicSheet,
              child: Text(l10n.basicSheet),
            ),
            DropdownMenuItem(
              value: _phasesSheet,
              child: Text(l10n.includePhases),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                thisGame = thisGame.copyWith(
                  enablePhases: value == _phasesSheet,
                );
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildScoreFilterField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: l10n.scoreFilterTooltip,
          child: Text(
            l10n.scoreFilter,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          key: SplashScreen.scoreFilterDropdownKey,
          value: thisGame.scoreFilter,
          items: [
            DropdownMenuItem(value: '', child: Text(l10n.anyScore)),
            DropdownMenuItem(
              value: r'^[0-9]*[05]$',
              child: Text(l10n.mustEndIn0Or5),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                thisGame = thisGame.copyWith(scoreFilter: value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildEndGameScoreField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: l10n.endScoreTooltip,
          child: Text(
            l10n.endScore,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 12),
        Builder(
          builder: (context) {
            return Row(
              children: [
                Checkbox(
                  key: SplashScreen.endGameScoreCheckboxKey,
                  value: _endGameScoreEnabled,
                  onChanged: (value) {
                    setState(() {
                      _endGameScoreEnabled = value ?? false;
                      if (!_endGameScoreEnabled) {
                        thisGame = thisGame.copyWith(endGameScore: 0);
                        _endGameScoreController.clear();
                      }
                    });
                  },
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    key: SplashScreen.endGameScoreFieldKey,
                    enabled: _endGameScoreEnabled,
                    keyboardType: TextInputType.number,
                    controller: _endGameScoreController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      setState(() {
                        thisGame = thisGame.copyWith(endGameScore: parsed ?? 0);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: l10n.gameEndingScore,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 4,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFieldsLayout(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    // Fields layout: four columns in landscape (empty, content, content, empty), single column in portrait
    if (orientation == Orientation.landscape) {
      return Row(
        // left / right
        mainAxisAlignment: MainAxisAlignment.center,
        // up / down for a row
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Empty column at the beginning - expands to fill space
          const Expanded(child: SizedBox()),
          // First content column - sized to content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNumPlayersField(context),
              const SizedBox(height: 8),
              _buildSheetStyleField(context),
            ],
          ),
          const SizedBox(width: 16),
          // Second content column - sized to content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMaxRoundsField(context),
              const SizedBox(height: 6),
              _buildScoreFilterField(context),
              const SizedBox(height: 6),
              _buildEndGameScoreField(context),
            ],
          ),
          // Empty column at the end - expands to fill space
          const Expanded(child: SizedBox()),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNumPlayersField(context),
          const SizedBox(height: 6),
          _buildMaxRoundsField(context),
          const SizedBox(height: 6),
          _buildSheetStyleField(context),
          const SizedBox(height: 6),
          _buildScoreFilterField(context),
          const SizedBox(height: 6),
          _buildEndGameScoreField(context),
        ],
      );
    }
  }

  Widget _buildFooterLinks(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orientation = MediaQuery.of(context).orientation;
    final copyrightLink = InkWell(
      onTap: () async {
        const url = 'https://www.linkedin.com/in/1freeman/';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        }
      },
      child: Text(
        l10n.copyright,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        textAlign: TextAlign.center,
      ),
    );

    final versionLink = _appVersion != null
        ? InkWell(
            onTap: () async {
              const url = 'https://github.com/freemansoft/fs-game-score';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
            child: Text(
              l10n.version(_appVersion!),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          )
        : const SizedBox.shrink();

    if (orientation == Orientation.landscape) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          copyrightLink,
          const SizedBox(width: 16),
          versionLink,
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          copyrightLink,
          versionLink,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            _buildFooterLinks(context),
            const SizedBox(height: 8),
            _buildFieldsLayout(context),
            const SizedBox(height: 6),
            ElevatedButton(
              key: SplashScreen.continueButtonKey,
              onPressed: () async {
                // Create a new game with fresh gameId and selected configuration
                ref
                    .read(gameProvider.notifier)
                    .newGame(
                      maxRounds: thisGame.maxRounds,
                      numPlayers: thisGame.numPlayers,
                      enablePhases: thisGame.enablePhases,
                      scoreFilter: thisGame.scoreFilter,
                      endGameScore: thisGame.endGameScore,
                      version: _appVersion,
                    );

                // Save game state to shared preferences
                final prefs = await SharedPreferences.getInstance();
                final game = ref.read(gameProvider.notifier).stateValue();
                await prefs.setString(_gamePrefsKey, game.toJson());

                // Navigate to score table screen
                if (context.mounted) {
                  await Navigator.of(
                    context,
                  ).pushReplacementNamed('/score-table');
                }
              },
              child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ],
        ),
      ),
    );
  }
}
