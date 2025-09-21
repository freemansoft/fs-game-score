import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../new_game_panel.dart';
import 'package:fs_score_card/new_scorecard.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fs_score_card/provider/players_provider.dart';

final themeProvider = NotifierProvider<ThemeNotifier, bool>(
  () => ThemeNotifier(),
);

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }

  void setTheme(bool isDark) {
    state = isDark;
  }
}

class Phase10AppBar extends ConsumerWidget implements PreferredSizeWidget {
  const Phase10AppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return AppBar(
      title: const Text('Scorecard'),
      actions: [
        const NewScoreCardPanel(),
        const NewGamePanel(),
        Consumer(
          builder: (context, ref, child) {
            return IconButton(
              icon: Icon(
                Theme.of(context).platform == TargetPlatform.iOS ||
                        Theme.of(context).platform == TargetPlatform.macOS
                    ? Icons.ios_share
                    : Icons.share,
              ),
              tooltip: 'Share Scores',
              onPressed: () {
                final players = ref.read(playersProvider);
                if (players.players.isNotEmpty) {
                  final csvData = players.toCsv();
                  final now = DateTime.now();
                  final dateTime =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                  final title = 'fs score card $dateTime';

                  SharePlus.instance.share(
                    ShareParams(text: csvData, title: title, subject: title),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No scores to share'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          },
        ),
        Row(
          children: [
            const Icon(Icons.light_mode),
            Switch(
              value: isDark,
              onChanged:
                  (val) => ref.read(themeProvider.notifier).setTheme(val),
            ),
            const Icon(Icons.dark_mode),
          ],
        ),
      ],
    );
  }
}
