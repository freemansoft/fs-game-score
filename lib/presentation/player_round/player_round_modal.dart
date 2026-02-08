import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/french_driving_round_attributes.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/presentation/player_round/french_driving_round_panel.dart';
import 'package:fs_score_card/presentation/player_round/round_phase_dropdown.dart';
import 'package:fs_score_card/presentation/player_round/round_score_field.dart';
import 'package:fs_score_card/provider/players_provider.dart';

class PlayerRoundModal extends ConsumerStatefulWidget {
  const PlayerRoundModal({
    super.key,
    required this.playerIdx,
    required this.round,
    required this.gameMode,
    required this.onPhaseChanged,
    required this.onScoreChanged,
    required this.onFrenchDrivingAttributesChanged,
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
  final GameMode gameMode;
  final ValueChanged<int?> onPhaseChanged;
  final ValueChanged<int?> onScoreChanged;
  final ValueChanged<FrenchDrivingRoundAttributes>
  onFrenchDrivingAttributesChanged;
  final String scoreFilter;

  static Future<void> show(
    BuildContext context, {
    required int playerIdx,
    required int round,
    required GameMode gameMode,
    required ValueChanged<int?> onPhaseChanged,
    required ValueChanged<int?> onScoreChanged,
    required ValueChanged<FrenchDrivingRoundAttributes>
    onFrenchDrivingAttributesChanged,
    required String scoreFilter,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PlayerRoundModal(
        playerIdx: playerIdx,
        round: round,
        gameMode: gameMode,
        onPhaseChanged: onPhaseChanged,
        onScoreChanged: onScoreChanged,
        onFrenchDrivingAttributesChanged: onFrenchDrivingAttributesChanged,
        scoreFilter: scoreFilter,
      ),
    );
  }

  @override
  ConsumerState<PlayerRoundModal> createState() => _PlayerRoundModalState();
}

class _PlayerRoundModalState extends ConsumerState<PlayerRoundModal> {
  bool _shouldCloseOnReturnKey() {
    return defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android;
  }

  void _closeModal() {
    Navigator.of(context).pop();
  }

  Widget _buildScoreField(BuildContext context, int? currentScore) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.score,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        RoundScoreField(
          key: PlayerRoundModal.scoreFieldKey(widget.playerIdx, widget.round),
          score: currentScore,
          onChanged: widget.onScoreChanged,
          scoreFilter: widget.scoreFilter,
          autofocus: widget.gameMode != GameMode.frenchDriving,
          enabled: widget.gameMode != GameMode.frenchDriving,
          onSubmitted: _shouldCloseOnReturnKey() ? _closeModal : null,
        ),
      ],
    );
  }

  Widget _buildPhaseDropdown(
    BuildContext context,
    int? selectedPhase,
    List<int?> completedPhases,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.phase,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        RoundPhaseDropdown(
          key: PlayerRoundModal.phaseDropdownKey(
            widget.playerIdx,
            widget.round,
          ),
          selectedPhase: selectedPhase,
          onChanged: widget.onPhaseChanged,
          playerIdx: widget.playerIdx,
          round: widget.round,
          completedPhases: completedPhases,
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

    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      key: PlayerRoundModal.modalKey(widget.playerIdx, widget.round),
      title: Text(
        l10n.playerRoundModalTitle(widget.playerIdx + 1, widget.round + 1),
      ),
      scrollable: true,
      content: orientation == Orientation.landscape
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildScoreField(context, currentScore),
                      if (widget.gameMode == GameMode.frenchDriving) ...[
                        const SizedBox(height: 16),
                        FrenchDrivingRoundPanel(
                          attributes:
                              player.frenchDrivingAttributes[widget.round],
                          onChanged: widget.onFrenchDrivingAttributesChanged,
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.gameMode == GameMode.phase10) ...[
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
                if (widget.gameMode == GameMode.phase10) ...[
                  const SizedBox(height: 16),
                  _buildPhaseDropdown(
                    context,
                    selectedPhase,
                    completedPhases,
                  ),
                ],
                if (widget.gameMode == GameMode.frenchDriving) ...[
                  const SizedBox(height: 16),
                  FrenchDrivingRoundPanel(
                    attributes: player.frenchDrivingAttributes[widget.round],
                    onChanged: widget.onFrenchDrivingAttributesChanged,
                  ),
                ],
              ],
            ),
    );
  }
}
