import 'package:flutter/material.dart';

class TotalScoreField extends StatelessWidget {
  final int totalScore;
  final List<int> completedPhases;
  final bool enablePhases;

  const TotalScoreField({
    required this.totalScore,
    required this.completedPhases,
    this.enablePhases = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sortedPhases = List<int>.from(completedPhases)..sort();
    final scoreText = SizedBox(
      width: double.infinity,
      child: Text(
        '$totalScore',
        style: const TextStyle(fontWeight: FontWeight.normal),
        textAlign: TextAlign.center,
      ),
    );
    if (!enablePhases) return scoreText;
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message:
          sortedPhases.isEmpty
              ? 'No completed phases'
              : 'Completed phases: ${sortedPhases.join(', ')}',
      child: scoreText,
    );
  }
}
