import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/presentation/live_view_disconnect_control.dart';

class SpectatorViewAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  const SpectatorViewAppBar({super.key});

  static const double _toolbarHeight = 40;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.liveSpectatorTitle),
      toolbarHeight: _toolbarHeight,
      actions: const [
        LiveViewDisconnectControl(),
      ],
    );
  }
}
