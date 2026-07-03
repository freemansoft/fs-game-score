import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/provider/game_sync_spectator_provider.dart';
import 'package:fs_score_card/sync/game_sync_lan.dart';
import 'package:fs_score_card/sync/game_sync_log.dart';
import 'package:fs_score_card/sync/game_sync_platform.dart';
import 'package:fs_score_card/sync/game_sync_qr.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Browse LAN hosts, scan QR, or paste a connection URL to join as spectator.
class JoinLiveGameScreen extends ConsumerStatefulWidget {
  const JoinLiveGameScreen({super.key});

  static const ValueKey<String> screenKey = ValueKey('join_live_game_screen');
  static const ValueKey<String> manualUrlFieldKey = ValueKey(
    'join_live_manual_url',
  );
  static const ValueKey<String> connectButtonKey = ValueKey(
    'join_live_connect_button',
  );

  @override
  ConsumerState<JoinLiveGameScreen> createState() => _JoinLiveGameScreenState();
}

class _JoinLiveGameScreenState extends ConsumerState<JoinLiveGameScreen> {
  final _manualUrlController = TextEditingController();
  var _showManual = false;
  var _connecting = false;

  @override
  void initState() {
    super.initState();
    if (canJoinLiveSync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          ref.read(gameSyncSpectatorProvider.notifier).startDiscovery(),
        );
      });
    }
  }

  @override
  void dispose() {
    _manualUrlController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    unawaited(ref.read(gameSyncSpectatorProvider.notifier).stopDiscovery());
    super.deactivate();
  }

  void _showConnectMessage(
    GameSyncConnectResult result,
    AppLocalizations l10n,
    ScaffoldMessengerState messenger,
  ) {
    final message = switch (result) {
      GameSyncConnectResult.wrongPin => l10n.liveConnectionWrongPin,
      GameSyncConnectResult.versionMismatch =>
        l10n.liveConnectionVersionMismatch,
      GameSyncConnectResult.cannotReachHost =>
        l10n.liveConnectionCannotReachHost,
      GameSyncConnectResult.hostClosed => l10n.liveConnectionHostClosed,
      GameSyncConnectResult.timedOut ||
      GameSyncConnectResult.failed => l10n.liveConnectionFailed,
      GameSyncConnectResult.connected => null,
    };
    if (message != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _connectFromUrl(String raw) async {
    if (_connecting) return;
    gameSyncLog(
      'JoinLiveGameScreen connect from URL: $raw',
      name: 'JoinLiveGameScreen',
    );
    final info = decodeGameSyncConnectionUrl(raw);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    if (info == null) {
      gameSyncLog(
        'JoinLiveGameScreen URL decode failed',
        name: 'JoinLiveGameScreen',
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.liveConnectionFailed)),
      );
      return;
    }
    gameSyncLog(
      'JoinLiveGameScreen decoded wsUrl=${info.wsUrl} gameId=${info.gameId} '
      'host=${info.host} port=${info.port}',
      name: 'JoinLiveGameScreen',
    );
    setState(() => _connecting = true);
    try {
      final result = await ref
          .read(gameSyncSpectatorProvider.notifier)
          .connect(
            wsUrl: info.wsUrl,
            pin: info.pin,
          );
      if (!context.mounted) return;
      gameSyncLog(
        'JoinLiveGameScreen connect result: $result',
        name: 'JoinLiveGameScreen',
      );
      if (result == GameSyncConnectResult.connected) {
        router.goNamed('liveSpectator');
      } else {
        _showConnectMessage(result, l10n, messenger);
      }
    } finally {
      if (mounted) {
        setState(() => _connecting = false);
      }
    }
  }

  Future<void> _connectToDiscovered(DiscoveredGameSyncHost host) async {
    if (_connecting) return;
    gameSyncLog(
      'JoinLiveGameScreen connect to discovered host: ${host.name} '
      '${host.host}:${host.port} gameId=${host.gameId}',
      name: 'JoinLiveGameScreen',
    );
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _connecting = true);
    try {
      final result = await ref
          .read(gameSyncSpectatorProvider.notifier)
          .connectToDiscovered(host);
      if (!context.mounted) return;
      gameSyncLog(
        'JoinLiveGameScreen discovered-host connect result: $result',
        name: 'JoinLiveGameScreen',
      );
      if (result == GameSyncConnectResult.connected) {
        router.goNamed('liveSpectator');
      } else {
        _showConnectMessage(result, l10n, messenger);
      }
    } finally {
      if (mounted) {
        setState(() => _connecting = false);
      }
    }
  }

  Future<void> _scanQr() async {
    if (_connecting) return;
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _JoinLiveScanDialog(
        title: l10n.scanConnectionQr,
        cancelLabel: l10n.cancel,
      ),
    );
    if (result != null) {
      await _connectFromUrl(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!canJoinLiveSync) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.joinLiveGameTitle)),
        body: Center(child: Text(l10n.liveSharingUnavailable)),
      );
    }
    final spectatorState = ref.watch(gameSyncSpectatorProvider);
    return Scaffold(
      key: JoinLiveGameScreen.screenKey,
      appBar: AppBar(
        title: Text(l10n.joinLiveGameTitle),
        toolbarHeight: 40,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.discoveredHosts,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (spectatorState.discoveredHosts.isEmpty)
                Text(l10n.noHostsFound)
              else
                ...spectatorState.discoveredHosts.map((host) {
                  return Semantics(
                    button: true,
                    label: l10n.joinHostLabel(host.name),
                    child: ListTile(
                      key: ValueKey('discovered_host_${host.name}'),
                      title: Text(host.name),
                      subtitle: Text('${host.host}:${host.port}'),
                      onTap: _connecting
                          ? null
                          : () => unawaited(_connectToDiscovered(host)),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              Semantics(
                button: true,
                label: l10n.scanConnectionQr,
                child: ElevatedButton(
                  onPressed: _connecting ? null : _scanQr,
                  child: Text(l10n.scanConnectionQr),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _connecting
                    ? null
                    : () => setState(() => _showManual = !_showManual),
                child: Text(l10n.manualConnection),
              ),
              if (_showManual || kDebugMode) ...[
                TextField(
                  key: JoinLiveGameScreen.manualUrlFieldKey,
                  controller: _manualUrlController,
                  decoration: InputDecoration(hintText: l10n.connectionUrlHint),
                  maxLines: 3,
                  enabled: !_connecting,
                ),
                const SizedBox(height: 8),
                Semantics(
                  button: true,
                  label: l10n.connect,
                  child: ElevatedButton(
                    key: JoinLiveGameScreen.connectButtonKey,
                    onPressed: _connecting
                        ? null
                        : () => _connectFromUrl(_manualUrlController.text),
                    child: Text(l10n.connect),
                  ),
                ),
              ],
            ],
          ),
          if (_connecting)
            ColoredBox(
              color: Colors.black26,
              child: Center(
                child: Semantics(
                  label: l10n.liveConnectionConnecting,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(l10n.liveConnectionConnecting),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// QR scan dialog — [MobileScanner.onDetect] fires repeatedly; only pop once.
class _JoinLiveScanDialog extends StatefulWidget {
  const _JoinLiveScanDialog({
    required this.title,
    required this.cancelLabel,
  });

  final String title;
  final String cancelLabel;

  @override
  State<_JoinLiveScanDialog> createState() => _JoinLiveScanDialogState();
}

class _JoinLiveScanDialogState extends State<_JoinLiveScanDialog> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  var _handled = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _closeWithResult(String? value) {
    if (_handled || !mounted) return;
    _handled = true;
    unawaited(_controller.stop());
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(value);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.startsWith('ws')) {
        gameSyncLog(
          'JoinLiveGameScreen QR scanned: $value',
          name: 'JoinLiveGameScreen',
        );
        _closeWithResult(value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const ValueKey('join_live_scan_dialog'),
      scrollable: true,
      title: Text(widget.title),
      content: SizedBox(
        height: 280,
        width: 280,
        child: MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _closeWithResult(null),
          child: Text(widget.cancelLabel),
        ),
      ],
    );
  }
}
