import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/data/players_repository.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/main.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/score_filters.dart';
import 'package:fs_score_card/presentation/about_button.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  static const ValueKey<String> numPlayersDropdownKey = ValueKey(
    'splash_num_players_dropdown',
  );
  static const ValueKey<String> maxRoundsDropdownKey = ValueKey(
    'splash_max_rounds_dropdown',
  );
  static const ValueKey<String> gameModeDropdownKey = ValueKey(
    'splash_game_mode_dropdown',
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
    thisGame = ref.read(gameProvider);

    // Auto-set score filter based on initially loaded game mode
    final autoFilter =
        (thisGame.configuration.gameMode == GameMode.phase10 ||
            thisGame.configuration.gameMode == GameMode.frenchDriving)
        ? r'^[0-9]*[05]$'
        : '';
    thisGame = thisGame.copyWith(
      configuration: thisGame.configuration.copyWith(
        scoreFilter: autoFilter,
      ),
    );

    _endGameScoreEnabled = thisGame.configuration.endGameScore > 0;
    _endGameScoreController.text = thisGame.configuration.endGameScore > 0
        ? thisGame.configuration.endGameScore.toString()
        : '';
  }

  @override
  void dispose() {
    _endGameScoreController.dispose();
    super.dispose();
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
        Semantics(
          button: true,
          label: 'Number of Players',
          child: DropdownButton<int>(
            key: SplashScreen.numPlayersDropdownKey,
            value: thisGame.configuration.numPlayers,
            items: [
              for (var i = 2; i <= 8; i++)
                DropdownMenuItem(value: i, child: Text(i.toString())),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  thisGame = thisGame.copyWith(
                    configuration: thisGame.configuration.copyWith(
                      numPlayers: value,
                    ),
                  );
                });
              }
            },
          ),
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
        Semantics(
          button: true,
          label: 'Maximum Rounds',
          child: DropdownButton<int>(
            key: SplashScreen.maxRoundsDropdownKey,
            value: thisGame.configuration.maxRounds,
            items: [
              for (var i = 1; i <= 20; i++)
                DropdownMenuItem(value: i, child: Text(i.toString())),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  thisGame = thisGame.copyWith(
                    configuration: thisGame.configuration.copyWith(
                      maxRounds: value,
                    ),
                  );
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameModeField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: l10n.sheetStyleTooltip,
          child: Text(
            l10n.gameMode,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: 'Game Mode',
          child: DropdownButton<GameMode>(
            key: SplashScreen.gameModeDropdownKey,
            value: thisGame.configuration.gameMode,
            items: [
              DropdownMenuItem(
                value: GameMode.standard,
                child: Text(l10n.gameModeStandard),
              ),
              DropdownMenuItem(
                value: GameMode.phase10,
                child: Text(l10n.gameModePhase10),
              ),
              DropdownMenuItem(
                value: GameMode.frenchDriving,
                child: Text(l10n.gameModeFrenchDriving),
              ),
              DropdownMenuItem(
                value: GameMode.skyjo,
                child: Text(l10n.gameModeSkyjo),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                // Auto-set score filter based on game mode:
                // Phase 10 and French Driving scores always end in 0 or 5
                final autoFilter =
                    (value == GameMode.phase10 ||
                        value == GameMode.frenchDriving)
                    ? ScoreFilters.endsWith0or5
                    : ScoreFilters.none;
                // Auto-enable end game score: Skyjo=100, French Driving=5000
                final autoEndGameScore =
                    value == GameMode.skyjo ? 100
                    : value == GameMode.frenchDriving ? 5000
                    : 0;
                final autoEndGameEnabled = autoEndGameScore > 0;
                setState(() {
                  _endGameScoreEnabled = autoEndGameEnabled;
                  _endGameScoreController.text =
                      autoEndGameScore > 0
                          ? autoEndGameScore.toString()
                          : '';
                  thisGame = thisGame.copyWith(
                    configuration: thisGame.configuration.copyWith(
                      gameMode: value,
                      scoreFilter: autoFilter,
                      endGameScore: autoEndGameScore,
                    ),
                  );
                });
              }
            },
          ),
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
        Semantics(
          button: true,
          label: 'Score Filter',
          child: DropdownButton<String>(
            key: SplashScreen.scoreFilterDropdownKey,
            value: thisGame.configuration.scoreFilter,
            items: [
              DropdownMenuItem(
                value: ScoreFilters.none,
                child: Text(l10n.anyScore),
              ),
              DropdownMenuItem(
                value: ScoreFilters.endsWith0or5,
                child: Text(l10n.mustEndIn0Or5),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  thisGame = thisGame.copyWith(
                    configuration: thisGame.configuration.copyWith(
                      scoreFilter: value,
                    ),
                  );
                });
              }
            },
          ),
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
                Semantics(
                  label: 'Enable End Game Score',
                  checked: _endGameScoreEnabled,
                  child: Checkbox(
                    key: SplashScreen.endGameScoreCheckboxKey,
                    value: _endGameScoreEnabled,
                    onChanged: (value) {
                      setState(() {
                        _endGameScoreEnabled = value ?? false;
                        if (!_endGameScoreEnabled) {
                          thisGame = thisGame.copyWith(
                            configuration: thisGame.configuration.copyWith(
                              endGameScore: 0,
                            ),
                          );
                          _endGameScoreController.clear();
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: Semantics(
                    label: 'End Game Score',
                    child: TextField(
                      key: SplashScreen.endGameScoreFieldKey,
                      enabled: _endGameScoreEnabled,
                      keyboardType: TextInputType.number,
                      controller: _endGameScoreController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        setState(() {
                          thisGame = thisGame.copyWith(
                            configuration: thisGame.configuration.copyWith(
                              endGameScore: parsed ?? 0,
                            ),
                          );
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
              _buildGameModeField(context),
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
          _buildGameModeField(context),
          const SizedBox(height: 6),
          _buildScoreFilterField(context),
          const SizedBox(height: 6),
          _buildEndGameScoreField(context),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appTitle,
          // style: Theme.of(context).textTheme.titleLarge?.copyWith(
          //   color: Colors.deepPurple,
          // ),
        ),
        toolbarHeight: 40,
        centerTitle: true,
        //backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          AboutButton(),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFieldsLayout(context),
            const SizedBox(height: 6),
            Semantics(
              button: true,
              label: 'Continue to Score Table',
              child: ElevatedButton(
                key: SplashScreen.continueButtonKey,
                onPressed: () async {
                  // new games from the splash screen clear previous game players
                  await PlayersRepository().clearPrefsPlayers();
                  // Create a new game with fresh gameId and selected configuration
                  await ref
                      .read(gameProvider.notifier)
                      .newGame(
                        maxRounds: thisGame.configuration.maxRounds,
                        numPlayers: thisGame.configuration.numPlayers,
                        gameMode: thisGame.configuration.gameMode,
                        scoreFilter: thisGame.configuration.scoreFilter,
                        endGameScore: thisGame.configuration.endGameScore,
                        version: appVersion,
                      );

                  // Navigate to score table screen
                  if (context.mounted) {
                    context.goNamed('scoreTable');
                  }
                },
                child: Text(AppLocalizations.of(context)!.continueButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
