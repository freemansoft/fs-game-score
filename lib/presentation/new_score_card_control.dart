import 'package:flutter/material.dart';

/// A widget that displays a home icon button and
/// shows a confirmation dialog for a new scorecard
/// Takes user back to the SplashScreen if confirmed to pick a new game type
class NewScoreCardControl extends StatelessWidget {
  const NewScoreCardControl({super.key});

  Future<void> _showDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Scorecard Type'),
        content: const Text(
          'Are you sure you want to change the scorecard type? The scorecard will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Change Scorecard'),
          ),
        ],
        semanticLabel: 'New Game - Change Scorecard Type',
      ),
    );
    if ((result ?? false) && context.mounted) {
      NewScoreCardNotification().dispatch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Request Change Scorecard Type',
      child: IconButton(
        icon: const Icon(Icons.home),
        tooltip: 'New Game - Change Scorecard Type',
        onPressed: () => _showDialog(context),
      ),
    );
  }
}

/// Notification to request showing the splash screen (home)
class NewScoreCardNotification extends Notification {}
