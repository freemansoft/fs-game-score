import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/main.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/score_filters.dart';
import 'package:fs_score_card/presentation/about_button.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:fs_score_card/sync/game_sync_platform.dart';
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
  static const ValueKey<String> joinLiveButtonKey = ValueKey(
    'splash_join_live_button',
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
    thisGame = ref.read(gameNotifierProvider);

    // Any entry to the splash screen clears persisted players and resets the
    // live roster (including coalesced persists from the score table).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(playersNotifierProvider.notifier).prepareForSplashEntry();
    });

    // Auto-set score filter based on the initially loaded game mode.
    final autoFilter = rulesFor(
      thisGame.configuration.gameMode,
    ).suggestedScoreFilter;
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
          label: l10n.numberOfPlayersLabel,
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
          label: l10n.maximumRoundsLabel,
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
          label: l10n.gameModeLabel,
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
              DropdownMenuItem(
                value: GameMode.golf,
                child: Text(l10n.gameModeGolf),
              ),
              DropdownMenuItem(
                value: GameMode.hearts,
                child: Text(l10n.gameModeHearts),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                // Score filter and suggested end-game score come from the
                // mode's rules descriptor (see game_rules.dart).
                final rules = rulesFor(value);
                final autoFilter = rules.suggestedScoreFilter;
                final autoEndGameScore = rules.suggestedEndGameScore;
                final autoEndGameEnabled = autoEndGameScore > 0;
                setState(() {
                  _endGameScoreEnabled = autoEndGameEnabled;
                  _endGameScoreController.text = autoEndGameScore > 0
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
          label: l10n.scoreFilterLabel,
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
                  label: l10n.enableEndGameScoreLabel,
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
                    label: l10n.endGameScoreLabel,
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
    ref.watch(gameNotifierProvider);
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
            if (canJoinLiveSync) ...[
              const SizedBox(height: 8),
              Tooltip(
                message: AppLocalizations.of(context)!.joinLiveGameTooltip,
                child: Semantics(
                  button: true,
                  label: AppLocalizations.of(context)!.joinLiveGame,
                  child: OutlinedButton(
                    key: SplashScreen.joinLiveButtonKey,
                    onPressed: () => context.pushNamed('joinLive'),
                    child: Text(AppLocalizations.of(context)!.joinLiveGame),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Semantics(
              button: true,
              label: AppLocalizations.of(context)!.continueButton,
              child: ElevatedButton(
                key: SplashScreen.continueButtonKey,
                onPressed: () async {
                  // Create a new game with fresh gameId and selected configuration
                  // Sets the version from the current app version
                  await ref
                      .read(gameNotifierProvider.notifier)
                      .newGame(
                        maxRounds: thisGame.configuration.maxRounds,
                        numPlayers: thisGame.configuration.numPlayers,
                        gameMode: thisGame.configuration.gameMode,
                        scoreFilter: thisGame.configuration.scoreFilter,
                        endGameScore: thisGame.configuration.endGameScore,
                        version: appVersion,
                      );

                  final players = ref.read(playersNotifierProvider);
                  await ref
                      .read(playersRepositoryProvider)
                      .savePlayers(players);

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
