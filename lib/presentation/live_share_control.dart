import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/provider/game_sync_host_provider.dart';
import 'package:fs_score_card/sync/game_sync_platform.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// App bar control to start/stop LAN live score sharing (host).
class LiveShareControl extends ConsumerWidget {
  const LiveShareControl({super.key});

  static const ValueKey<String> liveShareButtonKey = ValueKey(
    'live_share_button',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (!canHostLiveSync) {
      return const SizedBox.shrink();
    }
    final hostState = ref.watch(gameSyncHostProvider);
    final theme = Theme.of(context);
    final appBarIconColor =
        theme.appBarTheme.iconTheme?.color ?? theme.iconTheme.color;
    // Active hosting must not use primary — it often matches the AppBar
    // background in FlexColorScheme, making the icon invisible.
    final hostingIconColor = theme.colorScheme.secondary;
    return Semantics(
      button: true,
      label: l10n.shareLive,
      child: IconButton(
        key: LiveShareControl.liveShareButtonKey,
        icon: Icon(
          hostState.isHosting ? Icons.sensors : Icons.sensors_outlined,
          color: hostState.isHosting ? hostingIconColor : appBarIconColor,
        ),
        tooltip: l10n.shareLive,
        onPressed: () => _onPressed(context, ref),
      ),
    );
  }

  Future<void> _onPressed(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(gameSyncHostProvider.notifier);
    final hostState = ref.read(gameSyncHostProvider);
    if (hostState.isHosting) {
      await _showHostDialog(context, ref);
      return;
    }
    await notifier.startHosting();
    if (!context.mounted) return;
    final updated = ref.read(gameSyncHostProvider);
    if (updated.isHosting) {
      await _showHostDialog(context, ref);
    } else if (updated.errorMessage != null) {
      final l10n = AppLocalizations.of(context)!;
      final message = updated.errorMessage == 'live_sync_app_version_unknown'
          ? l10n.liveSyncAppVersionUnknown
          : updated.errorMessage!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _showHostDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final hostState = ref.watch(gameSyncHostProvider);
            final session = hostState.session;
            return AlertDialog(
              key: const ValueKey('live_host_dialog'),
              scrollable: true,
              titlePadding: const EdgeInsets.only(
                left: 24,
                right: 8,
                top: 12,
              ),
              contentPadding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 8,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(l10n.liveSharingTitle),
                  CloseButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              content: session == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.liveSharingInstructions),
                        const SizedBox(height: 8),
                        Text(
                          l10n.connectionPin(hostState.pin ?? ''),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.serviceName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        // Fixed size required: QrImageView uses LayoutBuilder, which
                        // breaks inside scrollable AlertDialog intrinsic layout.
                        Align(
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: QrImageView(
                              data: session.wsUrl,
                              size: 200,
                              semanticsLabel: 'Live connection QR code',
                            ),
                          ),
                        ),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: session == null
                      ? null
                      : () async {
                          await Clipboard.setData(
                            ClipboardData(text: session.wsUrl),
                          );
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text(l10n.connectionUrlCopied)),
                            );
                          }
                        },
                  child: Text(l10n.copyConnectionUrl),
                ),
                TextButton(
                  onPressed: () async {
                    await ref.read(gameSyncHostProvider.notifier).stopHosting();
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text(l10n.stopLiveSharing),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
