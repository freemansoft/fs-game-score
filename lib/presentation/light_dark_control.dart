import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/provider/theme_provider.dart';

class LightDarkControl extends ConsumerWidget {
  const LightDarkControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return Row(
      children: [
        const Icon(Icons.light_mode),
        Switch(
          value: isDark,
          onChanged: (val) =>
              ref.read(themeProvider.notifier).setTheme(isDark: val),
        ),
        const Icon(Icons.dark_mode),
      ],
    );
  }
}
