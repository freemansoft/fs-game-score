// We have to use -1 for the None value because onSelected is only called if there is a value
// This ensures that selecting 'No Phase' triggers the onSelected callback

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/provider/game_provider.dart';

class PhaseCheckboxDropdown extends ConsumerWidget {
  final int? selectedPhase;
  final ValueChanged<int?> onChanged;
  final int playerIdx;
  final int round;
  final List<int?> completedPhases;
  final bool enabled;

  const PhaseCheckboxDropdown({
    required this.selectedPhase,
    required this.onChanged,
    required this.playerIdx,
    required this.round,
    required this.completedPhases,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final Color backgroundColor =
        !enabled
            ? (theme.brightness == Brightness.dark
                ? Color.alphaBlend(
                  theme.disabledColor.withAlpha(51),
                  theme.colorScheme.surface,
                )
                : Color.alphaBlend(
                  theme.disabledColor.withAlpha(26),
                  theme.colorScheme.surface,
                ))
            : theme.colorScheme.surface;
    final Color textColor =
        !enabled
            ? theme.disabledColor
            : theme.textTheme.bodyMedium?.color ?? Colors.black;

    return PopupMenuButton<int?>(
      tooltip: 'Select completed phase(s)',
      enabled: enabled,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          selectedPhase != null ? 'Phase $selectedPhase' : 'No Phase',
          style: TextStyle(color: textColor),
        ),
      ),
      itemBuilder:
          (context) => [
            // We have to use a -1 for the None value because onSelected is only called if there is a value
            const PopupMenuItem<int?>(value: -1, child: Text('No Phase')),
            ...List.generate(game.numPhases, (i) {
              final phaseNum = i + 1;
              return CheckedPopupMenuItem<int?>(
                value: phaseNum,
                enabled: enabled,
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
