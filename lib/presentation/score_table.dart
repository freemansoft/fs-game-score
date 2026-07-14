import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/player.dart';
import 'package:fs_score_card/presentation/player_game/player_game_cell.dart';
import 'package:fs_score_card/presentation/player_game/player_game_modal.dart';
import 'package:fs_score_card/presentation/player_round/player_round_cell.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/provider/game_sync_spectator_provider.dart';
import 'package:fs_score_card/provider/players_provider.dart';

class ScoreTable extends ConsumerStatefulWidget {
  const ScoreTable({super.key, this.readOnly = false});

  /// Added to support sharing in read-only spectator mode.
  final bool readOnly;

  static ValueKey<String> lockRoundKey(int round) {
    return ValueKey('lock_r$round');
  }

  @override
  ConsumerState<ScoreTable> createState() => _ScoreTableState();
}

class _ScoreTableState extends ConsumerState<ScoreTable> {
  @override
  void dispose() {
    super.dispose();
  }

  Color? getRowColor(BuildContext context, int playerIdx) {
    final isEven = playerIdx.isEven;
    final colorScheme = Theme.of(context).colorScheme;
    return isEven
        ? colorScheme.primaryFixed.withAlpha(60)
        : colorScheme.primaryFixedDim.withAlpha(60);
  }

  @override
  Widget build(BuildContext context) {
    final spectator = ref.watch(gameSyncSpectatorProvider);
    final players = widget.readOnly
        ? spectator.players
        : ref.watch(playersNotifierProvider);
    final game = widget.readOnly
        ? spectator.game
        : ref.watch(gameNotifierProvider);
    if (players == null || game == null) {
      return const SizedBox.shrink();
    }
    final minWidth = 100 + game.configuration.maxRounds * 100;
    final readOnly = widget.readOnly;
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.scoreTableLabel,
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: minWidth.toDouble(),
        fixedLeftColumns: 1,
        // ignored for developer clarity
        // ignore: avoid_redundant_argument_values
        fixedTopRows: 1,
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: true,
        dataRowHeight: 74,
        border: TableBorder.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(100),
          // ignored for developer clarity
          // ignore: avoid_redundant_argument_values
          width: 1,
        ),

        columns: [
          DataColumn2(
            label: Text(
              l10n.playerTotal,
              semanticsLabel: l10n.playerTotalLabel,
            ),
            headingRowAlignment: MainAxisAlignment.center,
            size: ColumnSize.L,
            fixedWidth: 80,
          ),
          ...List.generate(game.configuration.maxRounds, (round) {
            // Check if all players have this round enabled
            final allEnabled = players.allPlayersEnabledForRound(round);
            return DataColumn2(
              label: Semantics(
                label: l10n.roundLabel(round + 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('  ${round + 1}'),
                    const SizedBox(width: 4),
                    if (!readOnly)
                      Semantics(
                        label: l10n.roundLockButtonLabel(round + 1),
                        child: IconButton(
                          key: ScoreTable.lockRoundKey(round),
                          visualDensity: VisualDensity.comfortable,
                          icon: Icon(
                            allEnabled ? Icons.lock_open : Icons.lock,
                            color: allEnabled ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          tooltip: allEnabled
                              ? AppLocalizations.of(context)!.lockColumn
                              : AppLocalizations.of(context)!.unlockColumn,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            ref
                                .read(playersNotifierProvider.notifier)
                                .toggleRoundEnabled(
                                  round: round,
                                  enabled: !allEnabled,
                                );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              size: ColumnSize.S,
              headingRowAlignment: MainAxisAlignment.center,
            );
          }),
        ],
        rows: List<DataRow2>.generate(players.length, (playerIdx) {
          final player = players[playerIdx];

          return DataRow2(
            color: WidgetStateProperty.resolveWith<Color?>(
              (states) => getRowColor(context, playerIdx),
            ),
            cells: [
              DataCell(
                PlayerGameCell(
                  playerIdx: playerIdx,
                  name: player.name,
                  totalScore: player.totalScore,
                  endGameScore: game.configuration.endGameScore,
                  readOnly: readOnly,
                  onTap: readOnly
                      ? null
                      : () => _openModal(playerIdx, player, game),
                ),
              ),
              ...List<DataCell>.generate(game.configuration.maxRounds, (round) {
                return DataCell(
                  PlayerRoundCell(
                    playerIdx: playerIdx,
                    round: round,
                    score: player.scores.getScore(round),
                    enabled: player.roundStates.isEnabled(round),
                    gameMode: game.configuration.gameMode,
                    selectedPhase: player.phases.getPhase(round),
                    completedPhases: player.phases.completedPhasesList(),
                    readOnly: readOnly,
                    onPhaseChanged: readOnly
                        ? (_) {}
                        : (val) {
                            ref
                                .read(playersNotifierProvider.notifier)
                                .updatePhase(playerIdx, round, val);
                          },
                    onScoreChanged: readOnly
                        ? (_) {}
                        : (parsed) {
                            ref
                                .read(playersNotifierProvider.notifier)
                                .updateScore(playerIdx, round, parsed);
                          },
                    onFrenchDrivingAttributesChanged: readOnly
                        ? (_) {}
                        : (attrs) {
                            ref
                                .read(playersNotifierProvider.notifier)
                                .updateFrenchDrivingAttributes(
                                  playerIdx,
                                  round,
                                  attrs,
                                );
                          },
                    scoreFilter: game.configuration.scoreFilter,
                  ),
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _openModal(int playerIdx, Player player, Game game) async {
    await PlayerGameModal.show(
      context,
      playerIdx: playerIdx,
      name: player.name,
      onNameChanged: (val) {
        ref
            .read(playersNotifierProvider.notifier)
            .updatePlayerName(playerIdx, val);
      },
      totalScore: player.totalScore,
      phases: player.phases,
      enablePhases: game.configuration.enablePhases,
      maxRounds: game.configuration.maxRounds,
    );
  }
}
