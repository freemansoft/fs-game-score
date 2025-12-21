import 'package:flutter/material.dart';

class PlayerGameCell extends StatelessWidget {
  const PlayerGameCell({
    super.key,
    required this.playerIdx,
    required this.name,
    required this.totalScore,
    required this.onTap,
  });
  static ValueKey<String> cellKey(int playerIdx) {
    return ValueKey('p${playerIdx}_game_cell');
  }

  static ValueKey<String> nameKey(int playerIdx) {
    return ValueKey('p${playerIdx}_name');
  }

  static ValueKey<String> totalScoreKey(int playerIdx) {
    return ValueKey('p${playerIdx}_total_score');
  }

  final int playerIdx;
  final String name;
  final int totalScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Player ${playerIdx + 1} name and total score',
      button: true,
      child: InkWell(
        key: cellKey(playerIdx),
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                key: nameKey(playerIdx),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                semanticsLabel: 'Player name ${playerIdx + 1}',
              ),
              Text(
                '$totalScore',
                key: totalScoreKey(playerIdx),
                textAlign: TextAlign.center,
                semanticsLabel: 'Player total score ${playerIdx + 1}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
