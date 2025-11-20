import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/player_game_cell.dart';
import 'package:fs_score_card/player_round_cell.dart';

class ScoreTable extends ConsumerStatefulWidget {
  const ScoreTable({super.key});

  @override
  ConsumerState<ScoreTable> createState() => _ScoreTableState();
}

class _ScoreTableState extends ConsumerState<ScoreTable> {
  @override
  void dispose() {
    super.dispose();
  }

  Color? getRowColor(BuildContext context, int playerIdx) {
    final isEven = playerIdx % 2 == 0;
    final colorScheme = Theme.of(context).colorScheme;
    return isEven
        ? colorScheme.primaryFixed.withAlpha(60)
        : colorScheme.primaryFixedDim.withAlpha(60);
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);
    final game = ref.watch(gameProvider);
    final minWidth = 100 + game.maxRounds * 100;

    return Semantics(
      label: 'Score Table',
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: minWidth.toDouble(),
        fixedLeftColumns: 1,
        fixedTopRows: 1,
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: true,
        dataRowHeight: 74,
        fixedCornerColor: Theme.of(
          context,
        ).colorScheme.secondaryFixed.withAlpha(60),
        fixedColumnsColor: Theme.of(
          context,
        ).colorScheme.secondaryFixed.withAlpha(60),
        border: TableBorder.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(100),
          width: 1,
        ),
        columns: [
          DataColumn2(
            label: Semantics(
              label: 'Player and Total',
              child: Text('Player\nTotal'),
            ),
            headingRowAlignment: MainAxisAlignment.center,
            size: ColumnSize.L,
            fixedWidth: 80,
          ),
          ...List.generate(game.maxRounds, (round) {
            // Check if all players have this round enabled
            final allEnabled = players.allPlayersEnabledForRound(round);
            return DataColumn2(
              label: Semantics(
                label: 'Round ${round + 1}',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('  ${round + 1}'),
                    const SizedBox(width: 4),
                    IconButton(
                      key: ValueKey('lock_round_$round'),
                      visualDensity: VisualDensity.comfortable,
                      icon: Icon(
                        allEnabled ? Icons.lock_open : Icons.lock,
                        color: allEnabled ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      tooltip: allEnabled ? 'Lock column' : 'Unlock column',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        // Toggle enabled state for all players for this round
                        ref
                            .read(playersProvider.notifier)
                            .toggleRoundEnabled(round, !allEnabled);
                      },
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
              (Set<WidgetState> states) => getRowColor(context, playerIdx),
            ),
            cells: [
              DataCell(
                PlayerGameCell(
                  playerIdx: playerIdx,
                  name: player.name,
                  onNameChanged: (val) {
                    ref
                        .read(playersProvider.notifier)
                        .updatePlayerName(playerIdx, val);
                  },
                  totalScore: player.totalScore,
                  completedPhases: player.phases.completedPhasesList(),
                  enablePhases: game.enablePhases,
                ),
              ),
              ...List<DataCell>.generate(game.maxRounds, (round) {
                return DataCell(
                  PlayerRoundCell(
                    playerIdx: playerIdx,
                    round: round,
                    score: player.scores.getScore(round),
                    enabled: player.roundStates.isEnabled(round),
                    enablePhases: game.enablePhases,
                    selectedPhase: player.phases.getPhase(round),
                    completedPhases: player.phases.completedPhasesList(),
                    onPhaseChanged: (val) {
                      ref
                          .read(playersProvider.notifier)
                          .updatePhase(playerIdx, round, val);
                    },
                    onScoreChanged: (parsed) {
                      ref
                          .read(playersProvider.notifier)
                          .updateScore(playerIdx, round, parsed);
                    },
                    scoreFilter: game.scoreFilter,
                  ),
                );
              }),
            ],
          );
        }),
      ),
    );
  }
}
