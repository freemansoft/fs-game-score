import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/presentation/round_score_field.dart';
import 'package:fs_score_card/presentation/round_phase_dropdown.dart';
import 'package:fs_score_card/provider/players_provider.dart';

class PlayerRoundModal extends ConsumerStatefulWidget {
  final int playerIdx;
  final int round;
  final bool enabled;
  final bool enablePhases;
  final ValueChanged<int?> onPhaseChanged;
  final ValueChanged<int?> onScoreChanged;
  final String scoreFilter;

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
      builder:
          (context) => PlayerRoundModal(
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
  Widget _buildScoreField(int? currentScore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Score:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        RoundScoreField(
          key: ValueKey('p${widget.playerIdx}_r${widget.round}_score_field'),
          score: currentScore,
          onChanged: widget.enabled ? widget.onScoreChanged : (parsed) {},
          enabled: widget.enabled,
          scoreFilter: widget.scoreFilter,
          autofocus: true,
        ),
      ],
    );
  }

  Widget _buildPhaseDropdown(int? selectedPhase, List<int?> completedPhases) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Phase:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        RoundPhaseDropdown(
          key: ValueKey('p${widget.playerIdx}_r${widget.round}_phase_dropdown'),
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
      key: ValueKey('p${widget.playerIdx}_r${widget.round}_round_modal'),
      title: Text('Player ${widget.playerIdx + 1} - Round ${widget.round + 1}'),
      scrollable: true,
      content:
          orientation == Orientation.landscape
              ? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildScoreField(currentScore)),
                  if (widget.enablePhases) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPhaseDropdown(
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
                  _buildScoreField(currentScore),
                  if (widget.enablePhases) ...[
                    const SizedBox(height: 16),
                    _buildPhaseDropdown(selectedPhase, completedPhases),
                  ],
                ],
              ),
    );
  }
}
