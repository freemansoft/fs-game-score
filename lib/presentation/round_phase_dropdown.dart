// We have to use -1 for the None value because onSelected is only called if there is a value
// This ensures that selecting 'No Phase' triggers the onSelected callback

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/provider/game_provider.dart';

class RoundPhaseDropdown extends ConsumerStatefulWidget {
  final int? selectedPhase;
  final ValueChanged<int?> onChanged;
  final int playerIdx;
  final int round;
  final List<int?> completedPhases;
  final bool enabled;

  const RoundPhaseDropdown({
    required this.selectedPhase,
    required this.onChanged,
    required this.playerIdx,
    required this.round,
    required this.completedPhases,
    this.enabled = true,
    super.key,
  });

  @override
  ConsumerState<RoundPhaseDropdown> createState() => _RoundPhaseDropdownState();
}

class _RoundPhaseDropdownState extends ConsumerState<RoundPhaseDropdown> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      // Trigger rebuild when focus changes to update border color
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final hasFocus = _focusNode.hasFocus;

    final Color backgroundColor =
        !widget.enabled
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
        !widget.enabled
            ? theme.disabledColor
            : theme.textTheme.bodyMedium?.color ?? Colors.black;

    final Color borderColor =
        hasFocus && widget.enabled
            ? theme.colorScheme.primary
            : theme.colorScheme.outline;

    return Focus(
      focusNode: _focusNode,
      child: PopupMenuButton<int?>(
        tooltip: 'Select completed phase(s)',
        enabled: widget.enabled,
        onOpened: () {
          // Request focus when popup opens
          _focusNode.requestFocus();
        },
        onCanceled: () {
          // Remove focus when popup is canceled (clicked outside)
          _focusNode.unfocus();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: hasFocus && widget.enabled ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.selectedPhase != null
                ? 'Phase ${widget.selectedPhase}'
                : 'No Phase',
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
                  enabled: widget.enabled,
                  checked: widget.completedPhases.contains(phaseNum),
                  child: Text('Phase $phaseNum'),
                );
              }),
            ],
        onSelected: (val) {
          widget.onChanged(val != null && val < 0 ? val : val);
          // Remove focus when an item is selected
          _focusNode.unfocus();
        },
      ),
    );
  }
}
