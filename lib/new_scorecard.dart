import 'package:flutter/material.dart';

/// A widget that displays a home icon button and shows a confirmation dialog for a new scorecard.
class NewScoreCardPanel extends StatelessWidget {
  const NewScoreCardPanel({super.key});

  Future<void> _showDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
          ),
    );
    if (result == true) {
      NewScoreCardNotification().dispatch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home),
      tooltip: 'Change Scorecard Type',
      onPressed: () => _showDialog(context),
    );
  }
}

/// Notification to request showing the splash screen (home)
class NewScoreCardNotification extends Notification {}
