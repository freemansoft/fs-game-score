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
        onTap: onTap,
        child: SizedBox(
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              Text(
                '$totalScore',
                style: const TextStyle(fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

