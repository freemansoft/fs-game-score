import 'package:flutter/material.dart';

class PlayerGameCell extends StatelessWidget {
  final int playerIdx;
  final String name;
  final int totalScore;
  final VoidCallback onTap;

  const PlayerGameCell({
    super.key,
    required this.playerIdx,
    required this.name,
    required this.totalScore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Player ${playerIdx + 1} name and total score',
      button: true,
      child: InkWell(
        key: ValueKey('p${playerIdx}_game_cell'),
        onTap: onTap,
        child: SizedBox(
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                label: 'Player name ${playerIdx + 1}',
                child: Text(
                  name,
                  key: ValueKey('p${playerIdx}_name'),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
              Semantics(
                label: 'Player total score ${playerIdx + 1}',
                button: true,
                child: Text(
                  '$totalScore',
                  key: ValueKey('p${playerIdx}_total_score'),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
