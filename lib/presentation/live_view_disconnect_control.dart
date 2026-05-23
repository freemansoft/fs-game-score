import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/provider/game_sync_spectator_provider.dart';
import 'package:go_router/go_router.dart';

/// App bar control that disconnects the spectator live view and returns to splash.
///
/// Usually shown in the spectator app bar.
class LiveViewDisconnectControl extends ConsumerWidget {
  const LiveViewDisconnectControl({super.key});

  static const ValueKey<String> iconButtonKey = ValueKey(
    'live_view_disconnect_icon_button',
  );

  Future<void> _onPressed(BuildContext context, WidgetRef ref) async {
    await ref.read(gameSyncSpectatorProvider.notifier).disconnect();
    if (context.mounted) {
      context.goNamed('splash');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: 'Leave live view',
      child: IconButton(
        key: iconButtonKey,
        icon: const Icon(Icons.exit_to_app),
        tooltip: l10n.leaveLiveView,
        onPressed: () => _onPressed(context, ref),
      ),
    );
  }
}
