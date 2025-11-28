import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/provider/players_provider.dart';

class NewGameControl extends ConsumerWidget {
  const NewGameControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool clearNames = false;
    return IconButton(
      icon: const Icon(Icons.replay),
      tooltip: 'New Game - Using same scorecard type',
      onPressed: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder:
                  (context, setState) => AlertDialog(
                    title: const Text('Start New Game?'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Are you sure you want to start a new game? The score card will be erased.',
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          value: clearNames,
                          onChanged: (val) {
                            setState(() {
                              clearNames = val ?? false;
                            });
                          },
                          title: const Text('Clear the player names'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('New Game'),
                      ),
                    ],
                  ),
            );
          },
        );
        if (result == true) {
          ref.read(playersProvider.notifier).resetGame(clearNames: clearNames);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Game reset!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
    );
  }
}
