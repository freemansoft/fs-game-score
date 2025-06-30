import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../new_game_panel.dart';

final themeProvider = StateProvider<bool>((ref) => false);

class Phase10AppBar extends ConsumerWidget implements PreferredSizeWidget {
  Phase10AppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return AppBar(
      title: const Text('Scorecard'),
      actions: [
        const NewGamePanel(),
        Row(
          children: [
            const Icon(Icons.light_mode),
            Switch(
              value: isDark,
              onChanged: (val) => ref.read(themeProvider.notifier).state = val,
            ),
            const Icon(Icons.dark_mode),
          ],
        ),
      ],
    );
  }
}
