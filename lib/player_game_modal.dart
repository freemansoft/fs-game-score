import 'package:flutter/material.dart';
import 'package:fs_score_card/player_name_field.dart';
import 'package:fs_score_card/model/phases.dart';

class PlayerGameModal extends StatelessWidget {
  final int playerIdx;
  final String name;
  final void Function(String) onNameChanged;
  final int totalScore;
  final Phases phases;
  final bool enablePhases;
  final int maxRounds;

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
      builder:
          (context) => PlayerGameModal(
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //title: Text('Player ${playerIdx + 1}'),
      scrollable: true,
      content: SizedBox(
        width: 200,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              const Text(
                'Name:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              PlayerNameField(
                key: ValueKey('p${playerIdx}_name_field'),
                name: name,
                onChanged: onNameChanged,
                border: const OutlineInputBorder(),
                textAlign: TextAlign.left,
              ),
              // Phases display (if enabled)
              if (enablePhases) ...[
                const SizedBox(height: 12),
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
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: phaseEntries,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
