import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/provider/players_provider.dart';

/// A button that, when pressed, will reset the game to its initial state.
/// Does not change the scorecard type.
///
/// Usually shown in the app bar
class NewGameControl extends ConsumerWidget {
  const NewGameControl({super.key});

  static const ValueKey<String> clearNamesCheckboxKey = ValueKey<String>(
    'new_game_clear_names_checkbox',
  );

  static ValueKey<String> cancelButtonKey = const ValueKey<String>(
    'new_game_cancel_button',
  );

  static ValueKey<String> okButtonKey = const ValueKey<String>(
    'new_game_ok_button',
  );

  static ValueKey<String> newGameButtonKey = const ValueKey<String>(
    'new_game_new_game_button',
  );

  Future<void> _showDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    bool clearNames = false;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.startNewGame),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.startNewGameMessage),
                const SizedBox(height: 16),
                CheckboxListTile(
                  key: NewGameControl.clearNamesCheckboxKey,
                  value: clearNames,
                  onChanged: (val) {
                    setState(() {
                      clearNames = val ?? false;
                    });
                  },
                  title: Text(l10n.clearPlayerNames),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
            actions: [
              TextButton(
                key: NewGameControl.cancelButtonKey,
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                key: NewGameControl.okButtonKey,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.newGame),
              ),
            ],
          ),
        );
      },
    );
    if (result ?? false) {
      ref.read(playersProvider.notifier).resetGame(clearNames: clearNames);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.gameReset),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: 'Request New Game Same Type',
      child: IconButton(
        key: NewGameControl.newGameButtonKey,
        icon: const Icon(Icons.replay),
        tooltip: l10n.newGameSameTypeTooltip,
        onPressed: () => _showDialog(context, ref),
      ),
    );
  }
}
