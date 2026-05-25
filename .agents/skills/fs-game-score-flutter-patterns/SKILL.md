---
name: fs-game-score-flutter-patterns
description: >
  Riverpod 3, routing, persistence, and Flutter UI conventions for fs-game-score.
  Use for general feature work, providers, splash/score-table flows, and l10n.
---

# FS Score Card — Flutter patterns

Project-specific implementation patterns. Full architecture: [docs/State-Management.md](/docs/State-Management.md).

**Related skills:** `fs-game-score-widgets-holding-player-game-data` (keys/semantics/modals), `fs-game-score-live-sync` (LAN sharing), `fs-game-score-testing-workflow` (tests).

Always prefix Flutter/Dart commands with **`fvm`** per [AGENTS.md](/AGENTS.md).

---

## State management (Riverpod 3)

App state uses **`Notifier` / `NotifierProvider`** (`hooks_riverpod` ^3.1.0), not Bloc/GetX/Provider.

| Layer | Providers |
| --- | --- |
| DI | `sharedPreferencesProvider` — overridden in `bootstrapApp()` |
| Persistence | `gameRepositoryProvider`, `playersRepositoryProvider` — `load*` / `save*` / `clear*` only |
| Live state | `gameNotifierProvider`, `playersNotifierProvider` |
| Routing | `appRouterProvider` — resume via `initialLocation(prefs)` |

**UI rules:**

- Widgets **`ref.watch`** / **`ref.read`** notifier providers — not repositories (except documented splash/router flows).
- Mutations: update `state` on the notifier, then persist.
- Do **not** restore state via repository callbacks; load in `Notifier.build()` only.

### `GameNotifier`

- `build()` → `repository.loadGame() ?? Game()`.
- `newGame()` → new in-memory `Game` (fresh UUID `gameId`) + `saveGame(state)`.
- **`Game.fromJson()` always generates a new `gameId`** — persisted JSON does not preserve session id.

### `PlayersNotifier`

- `build()` watches `gameNotifierProvider`; restores from repo when `playersMatchConfiguration()`.
- Gameplay edits call **`_requestPersist()`** — coalesced single-flight loop (at most one write in flight; re-run if edits arrive during save).
- **`prepareForSplashEntry()`** — await in-flight persist, bump `_persistGeneration`, clear prefs, reset memory. Use on splash mount and before navigating to splash (see `NewScoreCardControl`). **Not** `clearPlayers()` alone.

### Local/ephemeral UI state

Use `StatefulWidget`, `ValueNotifier`, or hooks for field focus and modal form state — not app-wide providers.

---

## Startup and bootstrap

`bootstrapApp()` in `lib/main.dart`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. Await `SharedPreferences.getInstance()`
3. Create `ProviderContainer` with `sharedPreferencesProvider` override
4. `runApp(UncontrolledProviderScope(...))` — not a second auto-created container

Notifiers load when first watched/read in `build()`.

---

## Routing

All navigation uses **`go_router`** via `appRouterProvider` (`lib/router/app_router.dart`).

- Resume to `/score-table` when game + players deserialize and dimensions match.
- Otherwise `/` (splash).
- Live spectator: `/live-spectator`; join: `/join-live`.

See **`flutter-setup-declarative-routing`** for generic go_router patterns.

---

## Persistence keys

| Key | Repository | Content |
| --- | --- | --- |
| `game_state` | `GameRepository` | `Game.configuration` JSON |
| `players_state` | `PlayersRepository` | Full roster JSON |

Splash **Start new game** saves config via `newGame()` and baseline roster via `playersRepositoryProvider.savePlayers(...)`.

---

## Serialization

Models use **hand-written** `fromJson` / `toJson` in `lib/model/` — **not** `json_serializable`. See `lib/model/game.dart`, `lib/data/game_repository.dart`.

---

## Localization

- Strings in `lib/l10n/*.arb`; generated `AppLocalizations`.
- After editing `.arb`: `fvm flutter gen-l10n`.
- **Do not localize** `semanticLabel` / `Semantics.label` (screen readers only).

See **`flutter-setup-localization`** for generic l10n setup.

---

## UI conventions

- Prefer **`StatelessWidget`**, `const` constructors, small private widgets over helper methods returning widgets.
- **`ListView.builder`** for long lists.
- **`AlertDialog(scrollable: true)`** for modals — see widget skill for orientation layout when 2–3 fields.
- Lint: **`very_good_analysis`**; ~80 char lines; `fvm dart format .` before submit.

---

## Anti-patterns (do not reintroduce)

| Anti-pattern | Why |
| --- | --- |
| Singleton repositories | Breaks DI and tests |
| `repositoryDidLoadPrefs()` | Bypasses `build()` validation |
| Fire-and-forget `main()` in integration tests | Android startup race |
| `ref.watch` in event handlers | Does not subscribe the widget |
| Saves/timers in `Notifier.build()` | Belongs in mutators or explicit UI flows |

---

## Key files

- `lib/provider/game_provider.dart`, `lib/provider/players_provider.dart`
- `lib/provider/prefs_provider.dart`, `lib/data/*_repository.dart`
- `lib/main.dart`, `lib/router/app_router.dart`
- `lib/presentation/splash_screen.dart`, `lib/presentation/new_score_card_control.dart`
- `test/players_notifier_persist_test.dart` — coalesced persist and splash clear
