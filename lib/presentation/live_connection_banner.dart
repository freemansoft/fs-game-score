import 'package:flutter/material.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/sync/game_sync_connection_label.dart';
import 'package:fs_score_card/sync/game_sync_transport.dart';

/// Connection status banner for the live spectator score table.
class LiveConnectionBanner extends StatelessWidget {
  const LiveConnectionBanner({
    required this.connectionState,
    this.gameId,
    this.hostDeviceName,
    this.connectedHostIp,
    super.key,
  });

  static const ValueKey<String> bannerKey = ValueKey('live_connection_banner');

  final GameSyncConnectionState connectionState;
  final String? gameId;
  final String? hostDeviceName;
  final String? connectedHostIp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = switch (connectionState) {
      GameSyncConnectionState.connecting => l10n.liveConnectionConnecting,
      GameSyncConnectionState.reconnecting => l10n.liveConnectionReconnecting,
      GameSyncConnectionState.connected => _connectedMessage(l10n),
      GameSyncConnectionState.wrongPin => l10n.liveConnectionWrongPin,
      GameSyncConnectionState.versionMismatch =>
        l10n.liveConnectionVersionMismatch,
      GameSyncConnectionState.cannotReachHost =>
        l10n.liveConnectionCannotReachHost,
      GameSyncConnectionState.hostClosed => l10n.liveConnectionHostClosed,
      GameSyncConnectionState.failed => l10n.liveConnectionFailed,
      GameSyncConnectionState.idle => '',
    };
    if (message.isEmpty) return const SizedBox.shrink();
    final color = switch (connectionState) {
      GameSyncConnectionState.connected => Colors.green.shade800,
      GameSyncConnectionState.wrongPin ||
      GameSyncConnectionState.versionMismatch ||
      GameSyncConnectionState.failed ||
      GameSyncConnectionState.cannotReachHost ||
      GameSyncConnectionState.hostClosed => Colors.red.shade800,
      _ => Colors.orange.shade800,
    };
    return Material(
      key: LiveConnectionBanner.bannerKey,
      color: color.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          semanticsLabel: message,
        ),
      ),
    );
  }

  String _connectedMessage(AppLocalizations l10n) {
    final target = resolveLiveConnectionBannerTarget(
      gameId: gameId,
      hostDeviceName: hostDeviceName,
      connectedHostIp: connectedHostIp,
    );
    if (target == null || target.isEmpty) {
      return l10n.liveConnectionConnectedOnly;
    }
    return l10n.liveConnectionConnected(target);
  }
}
