// We have to use -1 for the None value because onSelected is only called if there is a value
// This ensures that selecting 'None' triggers the onSelected callback

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_game_score/provider/game_provider.dart';

class PhaseCheckboxDropdown extends ConsumerWidget {
  final int? selectedPhase;
  final ValueChanged<int?> onChanged;
  final int playerIdx;
  final int round;
  final List<int?> completedPhases;
  final Key? fieldKey;

  const PhaseCheckboxDropdown({
    this.fieldKey,
    required this.selectedPhase,
    required this.onChanged,
    required this.playerIdx,
    required this.round,
    required this.completedPhases,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    return PopupMenuButton<int?>(
      key: fieldKey,
      tooltip: 'Select completed phase(s)',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          selectedPhase != null ? 'Phase $selectedPhase' : 'None',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      itemBuilder:
          (context) => [
            // We have to use a -1 for the None value because onSelected is only called if there is a value
            const PopupMenuItem<int?>(value: -1, child: Text('None')),
            ...List.generate(game.numPhases, (i) {
              final phaseNum = i + 1;
              return CheckedPopupMenuItem<int?>(
                value: phaseNum,
                checked: completedPhases.contains(phaseNum),
                child: Text('Phase $phaseNum'),
              );
            }),
          ],
      onSelected: (val) {
        onChanged(val != null && val < 0 ? val : val);
      },
    );
  }
}
