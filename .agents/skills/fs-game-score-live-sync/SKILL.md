---
name: fs-game-score-live-sync
description: >
  LAN host/spectator live sync, WebSocket protocol, and join/host UI for this app.
  Use when changing gameSyncHostProvider, gameSyncSpectatorProvider, or sync flows.
---

# FS Score Card — Live game sync

View-only LAN score sharing. **Host** owns real state in `gameNotifierProvider` / `playersNotifierProvider`. **Spectator** mirrors wire snapshots in `gameSyncSpectatorProvider` — **never** writes prefs or host notifiers.

Full reference: [docs/Game-Sync.md](../../../docs/Game-Sync.md). State overview: [State-Management.md — Live score sync](../../../docs/State-Management.md#live-score-sync-lan-v1).

Always use **`fvm flutter`** per [AGENTS.md](../../../AGENTS.md).

---

## Platform scope (v1)

`canHostLiveSync` / `canJoinLiveSync` in `lib/sync/game_sync_platform.dart` — **Android/iOS native only**. Web/desktop hide live host/join; CSV share unchanged. Real mDNS E2E needs two devices on the same Wi-Fi; emulators use manual `ws://` in **`kDebugMode`** on the join screen.

---

## Providers

### `gameSyncHostProvider` (`lib/provider/game_sync_host_provider.dart`)

- **Reads** game + players notifiers; does **not** own game state.
- **`startHosting()`** → `resolveLiveSyncAppVersion(game)` → `startGameSyncHost(initialSnapshot, pin, requiredAppVersion)`.
- Unknown version → `errorMessage: 'live_sync_app_version_unknown'`.
- Listens to game/players → **`broadcastCurrentState()`** (`revision++`, `broadcastGameSyncSnapshot`).
- Snapshot **`hostDeviceName`** = `liveSyncConnectionLabel(gameId:, hostIp:)` — short game ID or LAN IP, **never** `Platform.localHostname`.
- **`stopHosting()`** on dispose, new game, or leaving score table (`score_table_screen`, `new_game_control`).

### `gameSyncSpectatorProvider` (`lib/provider/game_sync_spectator_provider.dart`)

- **Owns** mirrored `Game` / `Players` for read-only UI only.
- **`gameSyncTransportFactoryProvider`** → `GameSyncTransport Function()`. **`connect()` creates a fresh transport each time** (never reuse disposed instances).
- **`connect(wsUrl, pin)`** → `Future<GameSyncConnectResult>` — completes on first **snapshot**, terminal error, or **15s timeout**. Sets `connectedHostIp` from parsed URL.
- **`isConnected`** requires `connected` + non-null game and players (first snapshot received).
- Clears mirrored state on `idle`, `wrongPin`, `versionMismatch`, `hostClosed`.

---

## Wire protocol

`lib/sync/game_sync_protocol.dart` — JSON over WebSocket.

Types: `hello`, `welcome`, `reject`, `snapshot`, `ping`, `pong`, `hostClosed`.

**URL / QR:** `ws://<host-ip>:8765?game=<gameId>&pin=<pin>` (`game_sync_qr.dart`). mDNS: **`_fsscore._tcp`**.

Mapper: `game_sync_mapper.dart` ↔ `Game` + `Players`.

---

## Handshake and validation

1. Spectator sends **`hello`**: `{ pin, appVersion, spectatorName }`.
2. Host validates **6-digit PIN** → else `reject` / `wrongPin` (`gameSyncRejectWrongPin`).
3. Host validates **`appVersion`** via `gameSyncAppVersionsMatch` (non-empty, same **major** semver, e.g. `1.12.0+236` matches `1.13.0+200`) → else `versionMismatch` (`gameSyncRejectVersionMismatch`).
4. Host sends **`welcome`** + initial **`snapshot`**; later snapshots on each broadcast.
5. Spectator re-checks host version on **`welcome`** (defense in depth).
6. **`JoinLiveGameScreen`** awaits **`GameSyncConnectResult.connected`** before `goNamed('live-spectator')`.

**App version:** global `appVersion` from `PackageInfo` in `bootstrapApp()`, else `GameConfiguration.version` via `resolveLiveSyncAppVersion()` (`game_sync_app_version.dart`).

---

## Connection banner (spectator)

`LiveConnectionBanner` + `resolveLiveConnectionBannerTarget()` (`game_sync_connection_label.dart`):

1. Short **game ID** (first 8 chars of `spectator.game?.gameId`)
2. Else **LAN IPv4** from `connectedHostIp` or snapshot `hostDeviceName`
3. Else **`liveConnectionConnectedOnly`** — never `localhost`

---

## UI touchpoints

| Component                   | Route / role                                                                                         |
| --------------------------- | ---------------------------------------------------------------------------------------------------- |
| `LiveShareControl`          | Host dialog; **`CloseButton`** dismisses dialog only — sharing continues until **Stop live sharing** |
| `JoinLiveGameScreen`        | `/join-live` — discovery, connect overlay, error snackbars                                           |
| `_JoinLiveScanDialog`       | One-shot QR scan (`DetectionSpeed.noDuplicates`) — multiple `Navigator.pop` breaks GoRouter          |
| `SpectatorScoreTableScreen` | `/live-spectator` — read-only `ScoreTable`                                                           |
| `LiveConnectionBanner`      | Spectator connection label                                                                           |

L10n: `liveConnectionConnected`, `liveConnectionConnectedOnly`, `liveConnectionWrongPin`, `liveConnectionVersionMismatch`, `liveSyncAppVersionUnknown`.

---

## Debug logging

`lib/sync/game_sync_log.dart` — `gameSyncLog()`, `gameSyncLogConnectionState()` inside **`assert()`** (debug builds only).

---

## Testing

| Area                                            | Files / approach                                                                |
| ----------------------------------------------- | ------------------------------------------------------------------------------- |
| Protocol, version, QR, mapper, labels, platform | `test/game_sync_*.dart`                                                         |
| Provider/widget                                 | Override **`gameSyncTransportFactoryProvider`** → `() => FakeGameSyncTransport` |
| Persist                                         | Spectator snapshots **must not** touch `SharedPreferences`                      |

See **`fs-game-score-testing-workflow`** for integration and fake transport patterns.

---

## Key files

- `lib/provider/game_sync_host_provider.dart`, `lib/provider/game_sync_spectator_provider.dart`
- `lib/sync/game_sync_lan_io.dart`, `game_sync_transport.dart`, `fake_game_sync_transport.dart`
- `lib/presentation/live_share_control.dart`, `join_live_game_screen.dart`, `live_connection_banner.dart`
