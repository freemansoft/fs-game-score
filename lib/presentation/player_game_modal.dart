import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/phases.dart';
import 'package:fs_score_card/presentation/player_name_field.dart';

class PlayerGameModal extends StatelessWidget {
  const PlayerGameModal({
    super.key,
    required this.playerIdx,
    required this.name,
    required this.onNameChanged,
    required this.totalScore,
    required this.phases,
    required this.enablePhases,
    required this.maxRounds,
  });
  static ValueKey<String> modalKey(int playerIdx) {
    return ValueKey('p${playerIdx}_game_modal');
  }

  static ValueKey<String> nameFieldKey(int playerIdx) {
    return ValueKey('p${playerIdx}_name_field');
  }

  final int playerIdx;
  final String name;
  final void Function(String) onNameChanged;
  final int totalScore;
  final Phases phases;
  final bool enablePhases;
  final int maxRounds;

  static Future<void> show(
    BuildContext context, {
    required int playerIdx,
    required String name,
    required void Function(String) onNameChanged,
    required int totalScore,
    required Phases phases,
    required bool enablePhases,
    required int maxRounds,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PlayerGameModal(
        playerIdx: playerIdx,
        name: name,
        onNameChanged: onNameChanged,
        totalScore: totalScore,
        phases: phases,
        enablePhases: enablePhases,
        maxRounds: maxRounds,
      ),
    );
  }

  bool _shouldCloseOnReturnKey() {
    return defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android;
  }

  void _closeModal(BuildContext context) {
    Navigator.of(context).pop();
  }

  Widget _buildNameSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.name,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        PlayerNameField(
          key: nameFieldKey(playerIdx),
          name: name,
          onChanged: onNameChanged,
          border: const OutlineInputBorder(),
          textAlign: TextAlign.left,
          onSubmitted: _shouldCloseOnReturnKey()
              ? () => _closeModal(context)
              : null,
        ),
      ],
    );
  }

  Widget _buildPhasesSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.phasesByRound,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Builder(
          builder: (context) {
            final phaseEntries = <Widget>[];
            for (int round = 0; round < maxRounds; round++) {
              final phase = phases.getPhase(round);
              if (phase != null && phase > 0) {
                phaseEntries.add(
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(l10n.roundPhase(round + 1, phase)),
                  ),
                );
              }
            }
            if (phaseEntries.isEmpty) {
              return Text(
                l10n.noPhasesCompleted,
                style: const TextStyle(fontStyle: FontStyle.italic),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: phaseEntries,
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check orientation using MediaQuery
    final orientation = MediaQuery.of(context).orientation;

    return AlertDialog(
      //title: Text('Player ${playerIdx + 1}'),
      key: modalKey(playerIdx),
      scrollable: true,
      content: SingleChildScrollView(
        child: orientation == Orientation.landscape && enablePhases
            ? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildNameSection(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPhasesSection(context)),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameSection(context),
                  if (enablePhases) ...[
                    const SizedBox(height: 12),
                    _buildPhasesSection(context),
                  ],
                ],
              ),
      ),
    );
  }
}
