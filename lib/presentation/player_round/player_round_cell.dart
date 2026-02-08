import 'package:flutter/material.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/french_driving_round_attributes.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/presentation/player_round/player_round_modal.dart';

class PlayerRoundCell extends StatelessWidget {
  PlayerRoundCell({
    Key? key,
    required this.playerIdx,
    required this.round,
    required this.score,
    required this.enabled,
    required this.gameMode,
    required this.selectedPhase,
    required this.completedPhases,
    required this.onPhaseChanged,
    required this.onScoreChanged,
    required this.onFrenchDrivingAttributesChanged,
    required this.scoreFilter,
  }) : super(key: key ?? cellKey(playerIdx, round));

  /// The repeatable key for this widget
  static ValueKey<String> cellKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_cell');
  }

  /// The repeatable key for the clickable inkwell that lanches the round editor
  static ValueKey<String> roundCellKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_round_cell');
  }

  /// The repeatable key for the score field in the cell
  static ValueKey<String> scoreKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_score');
  }

  /// The repeatable key for the phase field in the cell
  static ValueKey<String> phaseKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_phase');
  }

  final int playerIdx;
  final int round;
  final int? score;
  final bool enabled;
  final GameMode gameMode;
  final int? selectedPhase;
  final List<int?> completedPhases;
  final ValueChanged<int?> onPhaseChanged;
  final ValueChanged<int?> onScoreChanged;
  final ValueChanged<FrenchDrivingRoundAttributes>
  onFrenchDrivingAttributesChanged;
  final String scoreFilter;

  /// Show the round editing modal
  Future<void> _openModal(BuildContext context) async {
    await PlayerRoundModal.show(
      context,
      playerIdx: playerIdx,
      round: round,
      gameMode: gameMode,
      onPhaseChanged: onPhaseChanged,
      onScoreChanged: onScoreChanged,
      onFrenchDrivingAttributesChanged: onFrenchDrivingAttributesChanged,
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
            Text(
              score?.toString() ?? '---',
              key: scoreKey(playerIdx, round),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: enabled ? null : Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
              semanticsLabel:
                  'Player ${playerIdx + 1} round ${round + 1} score',
            ),
            if (gameMode == GameMode.phase10) ...[
              const SizedBox(height: 2),
              Text(
                selectedPhase != null && selectedPhase! > 0
                    ? AppLocalizations.of(context)!.phaseNumber(selectedPhase!)
                    : '---',
                key: phaseKey(playerIdx, round),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: enabled
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
                semanticsLabel:
                    'Player ${playerIdx + 1} round ${round + 1} phase',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
