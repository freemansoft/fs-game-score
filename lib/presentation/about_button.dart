import 'package:flutter/material.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/main.dart'; // For appVersion

class AboutButton extends StatelessWidget {
  const AboutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: const Icon(Icons.info_outline),
      tooltip: MaterialLocalizations.of(context).aboutListTileTitle(''),
      onPressed: () {
        showAboutDialog(
          context: context,
          applicationName: l10n.appTitle,
          applicationVersion: appVersion,
          applicationLegalese:
              '${l10n.copyright}\n\n${l10n.trademarkDisclaimer}',
        );
      },
    );
  }
}
