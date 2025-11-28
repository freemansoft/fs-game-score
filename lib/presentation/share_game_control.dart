import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:fs_score_card/provider/game_provider.dart';

class ShareGameControl extends ConsumerWidget {
  const ShareGameControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      key: const ValueKey('share_button'),
      icon: Icon(
        Theme.of(context).platform == TargetPlatform.iOS ||
                Theme.of(context).platform == TargetPlatform.macOS
            ? Icons.ios_share
            : Icons.share,
      ),
      tooltip: 'Share Scores',
      onPressed: () => shareGame(context, ref),
    );
  }
}

// Extracted share logic to a top-level function for reuse and clarity.
void shareGame(BuildContext context, WidgetRef ref) {
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

    SharePlus.instance.share(
      ShareParams(text: '$subject\n$csvData', title: title, subject: subject),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No scores to share'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
