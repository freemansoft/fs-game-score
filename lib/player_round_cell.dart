import 'package:flutter/material.dart';
import 'package:fs_score_card/round_score_field.dart';
import 'package:fs_score_card/phase_checkbox_dropdown.dart';

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

  const PlayerRoundCell({
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Player ${playerIdx + 1} round ${round + 1} score',
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (enablePhases) ...[
              const SizedBox(height: 4),
              PhaseCheckboxDropdown(
                key: ValueKey('phase_checkbox_dropdown_p${playerIdx}_r$round'),
                selectedPhase: selectedPhase,
                onChanged: enabled ? onPhaseChanged : (val) {},
                playerIdx: playerIdx,
                round: round,
                completedPhases: completedPhases,
                enabled: enabled,
              ),
              const SizedBox(height: 4),
            ],
            RoundScoreField(
              key: ValueKey('round_score_p${playerIdx}_r$round'),
              score: score,
              onChanged: enabled ? onScoreChanged : (parsed) {},
              enabled: enabled,
              scoreFilter: scoreFilter,
            ),
          ],
        ),
      ),
    );
  }
}
