import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/new_game_control.dart';
import 'presentation/share_game_control.dart';
import 'presentation/light_dark_control.dart';
import 'package:fs_score_card/presentation/new_score_card_control.dart';

class Phase10AppBar extends ConsumerWidget implements PreferredSizeWidget {
  const Phase10AppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Scores'),
      actionsPadding: EdgeInsets.only(right: 12.0),
      actions: [
        const NewScoreCardControl(),
        const NewGameControl(),
        const ShareGameControl(),
        if (kDebugMode) const LightDarkControl(),
      ],
    );
  }
}
