import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/presentation/live_connection_banner.dart';
import 'package:fs_score_card/presentation/score_table.dart';
import 'package:fs_score_card/provider/game_sync_spectator_provider.dart';
import 'package:fs_score_card/sync/game_sync_transport.dart';
import 'package:go_router/go_router.dart';

/// Read-only score table fed by [gameSyncSpectatorProvider].
class SpectatorScoreTableScreen extends ConsumerWidget {
  const SpectatorScoreTableScreen({super.key});

  static const ValueKey<String> screenKey = ValueKey(
    'spectator_score_table_screen',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final spectator = ref.watch(gameSyncSpectatorProvider);
    return Scaffold(
      key: SpectatorScoreTableScreen.screenKey,
      appBar: AppBar(
        title: Text(l10n.liveSpectatorTitle),
        toolbarHeight: 40,
        actions: [
          Semantics(
            button: true,
            label: l10n.leaveLiveView,
            child: TextButton(
              key: const ValueKey('leave_live_view_button'),
              onPressed: () async {
                await ref.read(gameSyncSpectatorProvider.notifier).disconnect();
                if (context.mounted) {
                  context.goNamed('splash');
                }
              },
              child: Text(l10n.leaveLiveView),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LiveConnectionBanner(
            connectionState: spectator.connectionState,
            gameId: spectator.game?.gameId,
            hostDeviceName: spectator.hostDeviceName,
            connectedHostIp: spectator.connectedHostIp,
          ),
          Expanded(
            child: spectator.isConnected
                ? const Padding(
                    padding: EdgeInsets.all(4),
                    child: ScoreTable(readOnly: true),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _waitingMessage(l10n, spectator.connectionState),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _waitingMessage(
    AppLocalizations l10n,
    GameSyncConnectionState connectionState,
  ) {
    return switch (connectionState) {
      GameSyncConnectionState.wrongPin => l10n.liveConnectionWrongPin,
      GameSyncConnectionState.versionMismatch =>
        l10n.liveConnectionVersionMismatch,
      GameSyncConnectionState.cannotReachHost =>
        l10n.liveConnectionCannotReachHost,
      GameSyncConnectionState.hostClosed => l10n.liveConnectionHostClosed,
      GameSyncConnectionState.failed => l10n.liveConnectionFailed,
      _ => l10n.liveConnectionConnecting,
    };
  }
}
