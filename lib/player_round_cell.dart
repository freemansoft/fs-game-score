import 'package:flutter/material.dart';
import 'package:fs_score_card/player_round_modal.dart';

class PlayerRoundCell extends StatelessWidget {
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
  }) : super(key: key ?? ValueKey('p${playerIdx}_r${round}_cell'));

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
      onTap: enabled ? () => _openModal(context) : null,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              label: 'Player ${playerIdx + 1} round ${round + 1} score',
              button: enabled,
              child: Text(
                score?.toString() ?? '---',
                key: ValueKey('p${playerIdx}_r${round}_score'),

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
                key: ValueKey('p${playerIdx}_r${round}_phase'),
                child: Text(
                  selectedPhase != null && selectedPhase! > 0
                      ? 'Phase $selectedPhase'
                      : '---',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color:
                        enabled
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
