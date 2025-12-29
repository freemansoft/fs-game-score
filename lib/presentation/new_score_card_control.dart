import 'package:flutter/material.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// A widget that displays a home icon button and
/// shows a confirmation dialog for a new scorecard
/// Takes user back to the SplashScreen if confirmed to pick a new game type
class NewScoreCardControl extends StatelessWidget {
  const NewScoreCardControl({super.key});

  static const ValueKey<String> iconButtonKey = ValueKey(
    'new_scorecard_icon_button',
  );
  static const ValueKey<String> cancelButtonKey = ValueKey(
    'new_scorecard_cancel_button',
  );
  static const ValueKey<String> changeScorecardButtonKey = ValueKey(
    'new_scorecard_change_button',
  );

  Future<void> _showDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeScorecardType),
        content: Text(l10n.changeScorecardTypeMessage),
        actions: [
          TextButton(
            key: cancelButtonKey,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            key: changeScorecardButtonKey,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.changeScorecard),
          ),
        ],
        semanticLabel: 'New Game - Change Scorecard Type',
      ),
    );
    if ((result ?? false) && context.mounted) {
      // Navigate to splash screen and clear navigation stack
      context.goNamed('splash');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: 'Request Change Scorecard Type',
      child: IconButton(
        key: iconButtonKey,
        icon: const Icon(Icons.home),
        tooltip: l10n.newGameChangeScorecardType,
        onPressed: () => _showDialog(context),
      ),
    );
  }
}
