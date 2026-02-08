import 'package:flutter/material.dart';

/// A widget that displays a player's name and total score
///
/// Usually shown in the score table
class PlayerGameCell extends StatelessWidget {
  const PlayerGameCell({
    super.key,
    required this.playerIdx,
    required this.name,
    required this.totalScore,
    required this.onTap,
    this.endGameScore = 0,
  });

  /// The repeatable key for the clickable inkwell in this widget that lanches the player's game editor
  static ValueKey<String> cellKey(int playerIdx) {
    return ValueKey('p${playerIdx}_game_cell');
  }

  /// The repeatable key for the player's name in this widget
  static ValueKey<String> nameKey(int playerIdx) {
    return ValueKey('p${playerIdx}_name');
  }

  /// The repeatable key for the player's total score in this widget
  static ValueKey<String> totalScoreKey(int playerIdx) {
    return ValueKey('p${playerIdx}_total_score');
  }

  final int playerIdx;

  /// player.name
  final String name;

  /// player.totalScore
  final int totalScore;

  /// Callback function to be invoked when the cell is tapped - usually to open the player's game editor
  final VoidCallback onTap;

  /// The score at which the game ends for this player
  final int endGameScore;

  @override
  Widget build(BuildContext context) {
    final gameOverDueToScore = endGameScore > 0 && totalScore >= endGameScore;
    final textStyle = gameOverDueToScore
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          )
        : Theme.of(context).textTheme.bodyMedium;

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
                style: textStyle,
                semanticsLabel: 'Player name ${playerIdx + 1}',
              ),
              Text(
                '$totalScore',
                key: totalScoreKey(playerIdx),
                textAlign: TextAlign.center,
                style: textStyle,
                semanticsLabel: 'Player total score ${playerIdx + 1}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
