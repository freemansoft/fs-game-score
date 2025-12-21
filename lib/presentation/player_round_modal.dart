import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/presentation/round_phase_dropdown.dart';
import 'package:fs_score_card/presentation/round_score_field.dart';
import 'package:fs_score_card/provider/players_provider.dart';

class PlayerRoundModal extends ConsumerStatefulWidget {
  const PlayerRoundModal({
    super.key,
    required this.playerIdx,
    required this.round,
    required this.enabled,
    required this.enablePhases,
    required this.onPhaseChanged,
    required this.onScoreChanged,
    required this.scoreFilter,
  });
  static ValueKey<String> modalKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_round_modal');
  }

  static ValueKey<String> scoreFieldKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_score_field');
  }

  static ValueKey<String> phaseDropdownKey(int playerIdx, int round) {
    return ValueKey('p${playerIdx}_r${round}_phase_dropdown');
  }

  final int playerIdx;
  final int round;
  final bool enabled;
  final bool enablePhases;
  final ValueChanged<int?> onPhaseChanged;
  final ValueChanged<int?> onScoreChanged;
  final String scoreFilter;

  static Future<void> show(
    BuildContext context, {
    required int playerIdx,
    required int round,
    required bool enabled,
    required bool enablePhases,
    required ValueChanged<int?> onPhaseChanged,
    required ValueChanged<int?> onScoreChanged,
    required String scoreFilter,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PlayerRoundModal(
        playerIdx: playerIdx,
        round: round,
        enabled: enabled,
        enablePhases: enablePhases,
        onPhaseChanged: onPhaseChanged,
        onScoreChanged: onScoreChanged,
        scoreFilter: scoreFilter,
      ),
    );
  }

  @override
  ConsumerState<PlayerRoundModal> createState() => _PlayerRoundModalState();
}

class _PlayerRoundModalState extends ConsumerState<PlayerRoundModal> {
  Widget _buildScoreField(BuildContext context, int? currentScore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Score:',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        RoundScoreField(
          key: PlayerRoundModal.scoreFieldKey(widget.playerIdx, widget.round),
          score: currentScore,
          onChanged: widget.enabled ? widget.onScoreChanged : (parsed) {},
          enabled: widget.enabled,
          scoreFilter: widget.scoreFilter,
          autofocus: true,
        ),
      ],
    );
  }

  Widget _buildPhaseDropdown(
    BuildContext context,
    int? selectedPhase,
    List<int?> completedPhases,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Phase:',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        RoundPhaseDropdown(
          key: PlayerRoundModal.phaseDropdownKey(
            widget.playerIdx,
            widget.round,
          ),
          selectedPhase: selectedPhase,
          onChanged: widget.enabled ? widget.onPhaseChanged : (val) {},
          playerIdx: widget.playerIdx,
          round: widget.round,
          completedPhases: completedPhases,
          enabled: widget.enabled,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the players provider to get the current phase and score values
    final players = ref.watch(playersProvider);
    final player = players[widget.playerIdx];
    final selectedPhase = player.phases.getPhase(widget.round);
    final completedPhases = player.phases.completedPhasesList();
    final currentScore = player.scores.getScore(widget.round);

    // Check orientation using MediaQuery
    final orientation = MediaQuery.of(context).orientation;

    return AlertDialog(
      key: PlayerRoundModal.modalKey(widget.playerIdx, widget.round),
      title: Text('Player ${widget.playerIdx + 1} - Round ${widget.round + 1}'),
      scrollable: true,
      content: orientation == Orientation.landscape
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildScoreField(context, currentScore)),
                if (widget.enablePhases) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPhaseDropdown(
                      context,
                      selectedPhase,
                      completedPhases,
                    ),
                  ),
                ],
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoreField(context, currentScore),
                if (widget.enablePhases) ...[
                  const SizedBox(height: 16),
                  _buildPhaseDropdown(context, selectedPhase, completedPhases),
                ],
              ],
            ),
    );
  }
}
