import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareGameControl extends ConsumerWidget {
  const ShareGameControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      key: const ValueKey('share_button'),
      icon: Icon(
        Theme.of(context).platform == TargetPlatform.iOS ||
                Theme.of(context).platform == TargetPlatform.macOS
            ? Icons.ios_share
            : Icons.share,
      ),
      tooltip: l10n.shareScores,
      onPressed: () => shareGame(context, ref),
    );
  }
}

// Extracted share logic to a top-level function for reuse and clarity.
Future<void> shareGame(BuildContext context, WidgetRef ref) async {
  final players = ref.read(playersProvider);
  if (players.players.isNotEmpty) {
    final csvData = players.toCsv();
    final now = DateTime.now();
    final dateTime =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final game = ref.read(gameProvider);
    final gameId = game.gameId;
    final title = 'fs score card $gameId $dateTime';
    final subject = 'fs score card $gameId $dateTime';

    await SharePlus.instance.share(
      ShareParams(
        text: '$subject\n$csvData',
        title: title,
        subject: subject,
        // required for ipad and maybe after ios 26
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.noScoresToShare),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
