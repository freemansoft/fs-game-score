import 'package:flutter/material.dart';
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

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Name:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        PlayerNameField(
          key: nameFieldKey(playerIdx),
          name: name,
          onChanged: onNameChanged,
          border: const OutlineInputBorder(),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildPhasesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Phases by Round:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                    child: Text('Round ${round + 1}: Phase $phase'),
                  ),
                );
              }
            }
            if (phaseEntries.isEmpty) {
              return const Text(
                'No phases completed',
                style: TextStyle(fontStyle: FontStyle.italic),
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
                  Expanded(child: _buildNameSection()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPhasesSection()),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameSection(),
                  if (enablePhases) ...[
                    const SizedBox(height: 12),
                    _buildPhasesSection(),
                  ],
                ],
              ),
      ),
    );
  }
}
