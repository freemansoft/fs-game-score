---
diataxis: reference
---

# State and persistence reference

Lookup facts for the domain model, repositories, and persistence keys. For how these fit together and why, see [State-Management.md](State-Management.md). For coding rules, see [How-To-Riverpod.md](How-To-Riverpod.md).

## Data Model

A game is represented by the `Game` class that contains a game `id` (automatically generated as a UUID) and a game `configuration` implemented by the `GameConfiguration` class. The `GameConfiguration` contains the number of players, the maximum number of rounds, the game mode (`Standard`, `Phase 10`, `French Driving`, `Skyjo`), the score filter, the end game score, and the version. The mode's scoring behavior — round-input style, negative scores, phases, and suggested score filter / end-game target — is declared in a `GameRules` descriptor (`lib/model/game_rules.dart`, via `rulesFor(gameMode)`); the `numPhases`, `allowNegativeScores`, and `enablePhases` getters delegate to it.

The players and their scores in a game are represented by the `Players` class, which wraps a list of `Player` objects.

Each player is represented by a `Player` object that contains:

- `name`: The player's display name.
- `scores`: A `Scores` object containing individual round scores.
- `phases`: A `Phases` object tracking phase completion status.
- `frenchDrivingAttributes`: A list of `FrenchDrivingRoundAttributes` (for the French Driving game mode).
- `roundStates`: A `RoundStates` object representing per-round information (such as round column locks that tell the UI to block editing for that round).

The `Game` / `Players` fields as exposed by each notifier are compared in [State-Management.md — Provider Architecture](State-Management.md#provider-architecture).

## Data Access Layer (Repositories)

Repository **classes** live under `lib/data/`. They are exposed to Riverpod through **`gameRepositoryProvider`** and **`playersRepositoryProvider`** (not used directly as singletons).

### GameRepository

**Location**: `lib/data/game_repository.dart`

- **Responsibility**: Persist `Game` configuration (not the full in-memory `gameId` lifecycle on every load — see `Game.fromJson` / `toJson` in the model).
- **Key Methods**: `loadGame()`, `saveGame()`, `clearGame()`
- **Prefs key**: `game_state`

### PlayersRepository

**Location**: `lib/data/players_repository.dart`

- **Responsibility**: Persist the `Players` roster and all per-player gameplay fields.
- **Key Methods**: `loadPlayers()`, `savePlayers()`, `clearPlayers()`
- **Prefs key**: `players_state`

## Prefs keys

| Key             | Repository          | Content                   |
| --------------- | ------------------- | ------------------------- |
| `game_state`    | `GameRepository`    | `Game` configuration JSON |
| `players_state` | `PlayersRepository` | Full player roster JSON   |

## Key Files

- `lib/provider/prefs_provider.dart` - SharedPreferences dependency injection
- `lib/model/game_rules.dart` - Per-mode `GameRules` descriptor and `rulesFor(GameMode)` lookup
- `lib/provider/game_provider.dart` - Game configuration state and UUID logic
- `lib/provider/players_provider.dart` - Player data state, validations, coalesced single-flight persist, `prepareForSplashEntry()`, `_persistGeneration`
- `test/players_notifier_persist_test.dart` - Coalesce burst, splash clear, in-flight + splash race
- `lib/data/game_repository.dart` - Game configuration persistence using SharedPreferences
- `lib/data/players_repository.dart` - Player state persistence using SharedPreferences
- `lib/main.dart` - `bootstrapApp()`, prefs pre-init, `UncontrolledProviderScope`
- `lib/router/app_router.dart` - App router with initial route resume logic
- `lib/presentation/splash_screen.dart` - Game configuration setting UI & new game initialization
- `lib/presentation/new_score_card_control.dart` - Awaits `prepareForSplashEntry()` before navigating to splash
- `integration_test/app_test_helpers.dart` - `waitForSplashPlayersCleared()` for splash-clear integration tests
- `docs/Game-Sync.md` - Live sync providers, protocol, handshake, labels, debug logging
- `lib/sync/game_sync_connection_label.dart` - Banner / snapshot host display labels
- `lib/sync/game_sync_log.dart` - Assert-wrapped debug logging for live sync
- `lib/sync/` - Live sync protocol, LAN transport, connection QR
- `lib/provider/game_sync_host_provider.dart` - Host live session state
- `lib/provider/game_sync_spectator_provider.dart` - Spectator live session state
