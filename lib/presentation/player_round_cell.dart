import 'package:flutter/material.dart';
import 'package:fs_score_card/presentation/player_round_modal.dart';

class PlayerRoundCell extends StatelessWidget {
  PlayerRoundCell({
    Key? key,
    required this.playerIdx,
    required this.round,
    required this.score,
    required this.enabled,
    required this.enablePhases,
    required this.selectedPhase,
    required this.completedPhases,
    required this.onPhaseChanged,
    required this.onScoreChanged,
    required this.scoreFilter,
  }) : super(key: key ?? cellKey(playerIdx, round));
  static ValueKey<String> cellKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_cell');
  }

  static ValueKey<String> roundCellKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_round_cell');
  }

  static ValueKey<String> scoreKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_score');
  }

  static ValueKey<String> phaseKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_phase');
  }

  final int playerIdx;
  final int round;
  final int? score;
  final bool enabled;
  final bool enablePhases;
  final int? selectedPhase;
  final List<int?> completedPhases;
  final ValueChanged<int?> onPhaseChanged;
  final ValueChanged<int?> onScoreChanged;
  final String scoreFilter;

  void _openModal(BuildContext context) {
    PlayerRoundModal.show(
      context,
      playerIdx: playerIdx,
      round: round,
      enabled: enabled,
      enablePhases: enablePhases,
      onPhaseChanged: onPhaseChanged,
      onScoreChanged: onScoreChanged,
      scoreFilter: scoreFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: roundCellKey(playerIdx, round),
      onTap: enabled ? () => _openModal(context) : null,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignored for developer clarity
          // ignore: avoid_redundant_argument_values
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              label: 'Player ${playerIdx + 1} round ${round + 1} score',
              button: enabled,
              child: Text(
                score?.toString() ?? '---',
                key: scoreKey(playerIdx, round),
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: enabled ? null : Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (enablePhases) ...[
              const SizedBox(height: 2),
              Semantics(
                label: 'Player ${playerIdx + 1} round ${round + 1} phase',
                button: enabled,
                key: phaseKey(playerIdx, round),
                child: Text(
                  selectedPhase != null && selectedPhase! > 0
                      ? 'Phase $selectedPhase'
                      : '---',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: enabled
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).disabledColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
