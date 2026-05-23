---
name: fs-game-score-live-sync
description: >
  LAN host/spectator live sync, WebSocket protocol, and join/host UI for this app.
  Use when changing gameSyncHostProvider, gameSyncSpectatorProvider, or sync flows.
---

# FS Score Card — Live game sync

Use this skill when changing LAN live sharing, `gameSyncHostProvider`, `gameSyncSpectatorProvider`, sync protocol, or join/host UI.

Full reference: [docs/Game-Sync.md](../../../docs/Game-Sync.md).

---

## Providers (Riverpod 3)

### Host — `gameSyncHostProvider`

- **Reads** `gameNotifierProvider` + `playersNotifierProvider`; does **not** own game state.
- `startHosting()` → `resolveLiveSyncAppVersion(game)` → `startGameSyncHost(initialSnapshot, pin, requiredAppVersion)`.
- Snapshot `hostDeviceName` = `liveSyncConnectionLabel(gameId, hostIp)` — **short game ID or LAN IP**, never `Platform.localHostname`.
- Listens to game/players changes → `broadcastCurrentState()` → `broadcastGameSyncSnapshot` (revision++).
- `stopHosting()` on dispose, new game, or leaving score table.

### Spectator — `gameSyncSpectatorProvider`

- **Owns** mirrored `Game` / `Players` for view-only UI only; **never** saves to repositories.
- **`gameSyncTransportFactoryProvider`**: returns `GameSyncTransport Function()`. **`connect()` creates a fresh transport each time** (do not cache/dispose-reuse).
- **`connect(wsUrl, pin)`** → `Future<GameSyncConnectResult>` — waits for first **snapshot**, terminal error, or 15s timeout. Stores `connectedHostIp` from parsed `wsUrl`.
- Clears mirrored game on `wrongPin`, `versionMismatch`, `hostClosed`, `idle`.

---

## Communication flow

1. Host starts Shelf WebSocket + Bonsoir (`_fsscore._tcp`) with PIN in service attributes.
2. Spectator opens `ws://host:port?game=&pin=` (QR, mDNS, or debug manual URL).
3. Spectator sends **`hello`**: `{ pin, appVersion, spectatorName }`.
4. Host validates **PIN** then **app version** (`gameSyncAppVersionsMatch`).
5. Host sends **`welcome`** `{ appVersion }` + initial **`snapshot`**; later **`snapshot`** on each host broadcast.
6. Spectator re-validates host `appVersion` on `welcome`; maps snapshots into notifier state.
7. **`JoinLiveGameScreen`** awaits `GameSyncConnectResult.connected` before `goNamed('liveSpectator')`.

Message types and snapshot shape: `lib/sync/game_sync_protocol.dart`.

---

## Validation rules

| Check | Where | Failure |
| --- | --- | --- |
| 6-digit PIN match | Host on `hello` | `reject` / `wrongPin` |
| `appVersion` match (non-empty, trimmed equal) | Host on `hello`; spectator on `welcome` | `reject` / `versionMismatch` |
| App version known before host start | `GameSyncHostNotifier.startHosting` | `live_sync_app_version_unknown` |

Version string: global `appVersion` from `PackageInfo` in `bootstrapApp()`, else `game.configuration.version` via `resolveLiveSyncAppVersion()`.

Constants: `gameSyncRejectWrongPin`, `gameSyncRejectVersionMismatch`, `GameSyncConnectionState.versionMismatch`.

---

## Connection banner (spectator)

`LiveConnectionBanner` uses `resolveLiveConnectionBannerTarget()`:

1. Short **game ID** from `spectator.game?.gameId`
2. Else **IPv4** from `connectedHostIp` or snapshot `hostDeviceName`
3. Else **`liveConnectionConnectedOnly`** — never show `localhost`

Helpers: `lib/sync/game_sync_connection_label.dart`.

---

## UI touchpoints

- Host: `LiveShareControl` → `gameSyncHostProvider`; host dialog has **`CloseButton`** (dismiss only, does not stop sharing)
- Join: `JoinLiveGameScreen` → discovery + `connect`; “Connecting…” overlay; snackbars on failure; QR scan uses one-shot `_JoinLiveScanDialog`
- Spectator table: `SpectatorScoreTableScreen`, `LiveConnectionBanner`, read-only `ScoreTable`

L10n: `liveConnectionConnected`, `liveConnectionConnectedOnly`, `liveConnectionWrongPin`, `liveConnectionVersionMismatch`, `liveSyncAppVersionUnknown`.

---

## Debug logging

`lib/sync/game_sync_log.dart` — `gameSyncLog()`, `gameSyncLogConnectionState()` inside `assert()` (debug only). Used by join screen, spectator notifier, and transports.

---

## Testing checklist

- Unit: `test/game_sync_protocol_test.dart`, `game_sync_connection_label_test.dart`, mapper, QR.
- Widget/provider: override **`gameSyncTransportFactoryProvider`** with `(ref) => () => fakeTransport`; toggle `pinAccepted`, `appVersionAccepted`, `expectedHostAppVersion` on `FakeGameSyncTransport`.
- Real LAN: two physical devices, same Wi-Fi; not emulators unless manual `ws://` in debug.

Always use **`fvm flutter`** per `AGENTS.md`.
