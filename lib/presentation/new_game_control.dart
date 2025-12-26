import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/provider/players_provider.dart';

/// A button that, when pressed, will reset the game to its initial state.
/// Does not change the scorecard type.
class NewGameControl extends ConsumerWidget {
  const NewGameControl({super.key});

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
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
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
        icon: const Icon(Icons.replay),
        tooltip: l10n.newGameSameTypeTooltip,
        onPressed: () => _showDialog(context, ref),
      ),
    );
  }
}
