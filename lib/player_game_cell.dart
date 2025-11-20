import 'package:flutter/material.dart';
import 'package:fs_score_card/player_name_field.dart';
import 'package:fs_score_card/total_score_field.dart';

class PlayerGameCell extends StatelessWidget {
  final int playerIdx;
  final String name;
  final void Function(String) onNameChanged;
  final int totalScore;
  final List<int> completedPhases;
  final bool enablePhases;

  const PlayerGameCell({
    super.key,
    required this.playerIdx,
    required this.name,
    required this.onNameChanged,
    required this.totalScore,
    required this.completedPhases,
    required this.enablePhases,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Player ${playerIdx + 1} name and total score',
      child: SizedBox(
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayerNameField(
              key: ValueKey('player_name_field_$playerIdx'),
              name: name,
              onChanged: onNameChanged,
            ),
            TotalScoreField(
              key: ValueKey('player_total_score_$playerIdx'),
              totalScore: totalScore,
              completedPhases: completedPhases,
              enablePhases: enablePhases,
            ),
          ],
        ),
      ),
    );
  }
}

