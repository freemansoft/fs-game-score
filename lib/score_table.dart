import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fs_game_score/player_name_field.dart';
import 'package:fs_game_score/round_score_field.dart';
import 'package:fs_game_score/provider/players_provider.dart';
import 'package:fs_game_score/phase_checkbox_dropdown.dart';
import 'package:fs_game_score/provider/game_provider.dart';
import 'package:fs_game_score/total_score_field.dart';

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

    return DataTable2(
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
        const DataColumn2(
          label: Text('Player\nTotal'),
          headingRowAlignment: MainAxisAlignment.center,
          size: ColumnSize.L,
          fixedWidth: 80,
        ),
        ...List.generate(game.maxRounds, (round) {
          // Check if all players have this round enabled
          final allEnabled = players.every(
            (p) => p.scores.isEnabled(round) && p.phases.isEnabled(round),
          );
          return DataColumn2(
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Round ${round + 1}'),
                const SizedBox(width: 4),
                IconButton(
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
              SizedBox(
                width: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlayerNameField(
                      key: ValueKey('player_name_field_$playerIdx'),
                      name: player.name,
                      onChanged: (val) {
                        ref
                            .read(playersProvider.notifier)
                            .updatePlayerName(playerIdx, val);
                      },
                    ),
                    TotalScoreField(
                      totalScore: player.totalScore,
                      completedPhases: player.phases.completedPhasesList(),
                      fieldKey: ValueKey('player_total_score_$playerIdx'),
                      enablePhases: game.enablePhases,
                    ),
                  ],
                ),
              ),
            ),
            ...List<DataCell>.generate(game.maxRounds, (round) {
              final score = player.scores.getScore(round);
              final enabled =
                  player.scores.isEnabled(round) &&
                  player.phases.isEnabled(round);
              return DataCell(
                SizedBox(
                  width: 90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (game.enablePhases) ...[
                        const SizedBox(height: 4),
                        PhaseCheckboxDropdown(
                          fieldKey: ValueKey(
                            'phase_checkbox_dropdown_p${playerIdx}_r$round',
                          ),
                          selectedPhase: player.phases.getPhase(round),
                          onChanged:
                              enabled
                                  ? (val) {
                                    ref
                                        .read(playersProvider.notifier)
                                        .updatePhase(playerIdx, round, val);
                                  }
                                  : (val) {},
                          playerIdx: playerIdx,
                          round: round,
                          completedPhases: player.phases.completedPhasesList(),
                          enabled: enabled,
                        ),
                        const SizedBox(height: 4),
                      ],
                      RoundScoreField(
                        key: ValueKey('round_score_p${playerIdx}_r$round'),
                        score: score,
                        onChanged:
                            enabled
                                ? (parsed) {
                                  ref
                                      .read(playersProvider.notifier)
                                      .updateScore(playerIdx, round, parsed);
                                }
                                : (parsed) {},
                        enabled: enabled,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
