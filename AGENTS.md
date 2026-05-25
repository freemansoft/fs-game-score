# Agent Instructions: fs-game-score (fs_score_card)

This file contains crucial instructions, guidelines, and context for AI agents and developer tools operating on the `fs-game-score` repository. If you are an agent modifying, building, or analyzing this codebase, you **must** read and adhere to these guidelines.

---

## ⚠️ Critical Rule: ALWAYS Use FVM (Flutter Version Management)

This project uses **FVM** (Flutter Version Management) to manage the Flutter SDK version and ensure consistency across development environments. The specific Flutter version for this project is managed by `.fvmrc`.

> [!IMPORTANT]
> **Every Flutter and Dart command MUST be prefixed with `fvm`.**
> Never run raw `flutter` or `dart` commands. Always use `fvm flutter` and `fvm dart`.

### Correct Command Usage Examples

| Task | Incorrect Command | Correct Command |
| :--- | :--- | :--- |
| **Install / pin SDK** | `flutter install` | `fvm install` / `fvm use` |
| **Clean Project** | `flutter clean` | `fvm flutter clean` |
| **Get Dependencies** | `flutter pub get` | `fvm flutter pub get` |
| **Generate l10n** | `flutter gen-l10n` | `fvm flutter gen-l10n` |
| **Run App** | `flutter run` | `fvm flutter run` |
| **Build** | `flutter build …` | `fvm flutter build <platform>` |
| **Build Web** | `flutter build web …` | `fvm flutter build web …` |
| **Run Analysis** | `flutter analyze` | `fvm flutter analyze` |
| **Run Tests** | `flutter test` | `fvm flutter test` |
| **Format Code** | `dart format .` | `fvm dart format .` |
| **Run Dart tool** | `dart run …` | `fvm dart run …` |

> [!WARNING]
> Running commands without the `fvm` prefix can cause compilation issues, version mismatch errors, or corrupt the local build cache due to using a different system-installed Flutter version than the one specified in `.fvmrc`.

---

## Repository layout

Flutter app (multi-platform) for a player/round score card. Key folders:

- `lib/presentation/` — UI widgets (score table, modals, screens)
- `lib/provider/` — Riverpod providers (`prefs_provider`, `game_provider`, `players_provider`, live sync)
- `lib/data/` — `GameRepository` / `PlayersRepository` (SharedPreferences persistence)
- `lib/model/` — plain Dart model classes (`Game`, `Players`, `Player`, `Scores`)
- `integration_test/` and `test/` — widget/unit and integration tests
- `.agents/skills/` — upstream Dart/Flutter skills and project skills (`fs-game-score-*`)
- `docs/` — architecture and feature docs (see [Quick file references](#quick-file-references))

---

## Codebase context & architecture

### State management (Riverpod 3)

- The application utilizes **Riverpod 3** (via `flutter_riverpod` and `hooks_riverpod` version `^3.1.0`) for compile-time safe, reactive state management.
- **Data flow**: `sharedPreferencesProvider` → repository providers → `gameNotifierProvider` / `playersNotifierProvider` → UI (`ConsumerWidget`). Full patterns: [docs/State-Management.md](docs/State-Management.md).
- **Provider layers**:
  - `sharedPreferencesProvider` ([prefs_provider.dart](lib/provider/prefs_provider.dart)): DI for `SharedPreferences`; overridden in `bootstrapApp()` before `runApp`.
  - `gameRepositoryProvider` / `playersRepositoryProvider`: Persistence only (`load*`, `save*`, `clear*`).
  - `gameNotifierProvider` ([game_provider.dart](lib/provider/game_provider.dart)): Live `Game` configuration and `gameId`.
  - `playersNotifierProvider` ([players_provider.dart](lib/provider/players_provider.dart)): Live roster, scores, phases, round locks. `PlayersNotifier.build()` watches `gameNotifierProvider` and restores from `playersRepositoryProvider` when dimensions match.
  - `gameSyncHostProvider` / `gameSyncSpectatorProvider`: LAN live view-only sync; see [docs/Game-Sync.md](docs/Game-Sync.md). Host reads game/players notifiers and broadcasts snapshots; spectator mirrors wire state only (no prefs). PIN + **app major version** validated on WebSocket `hello` / `welcome`. Spectator `connect()` returns `GameSyncConnectResult` and waits for the first snapshot. Transport via `gameSyncTransportFactoryProvider` (fresh instance per connect). Banner labels use game ID or LAN IP ([game_sync_connection_label.dart](lib/sync/game_sync_connection_label.dart)).
  - `appRouterProvider` ([app.dart](lib/app.dart)): `GoRouter` with resume logic from prefs.
- **Rules**: Widgets `ref.watch` / `ref.read` **notifier** providers; use **repository** providers only from notifiers, router startup, or documented splash flows. Do not restore state via repository callbacks into notifiers.
- **Startup**: `bootstrapApp()` in [main.dart](lib/main.dart) pre-inits prefs and mounts `UncontrolledProviderScope` with a pre-built `ProviderContainer`; notifiers load in `build()` when first read.
- **Persistence**: Repositories read/write `game_state` and `players_state` keys. Game config saved on `newGame()`; player progress uses coalesced single-flight persist during play; baseline roster saved on splash **Start new game**. Splash entry uses `prepareForSplashEntry()` (not `clearPlayers()` alone) to avoid persist races — see [docs/State-Management.md — Splash entry and coalesced persist race](docs/State-Management.md#splash-entry-and-coalesced-persist-race).
- **Live sync**: When editing host/join/spectator flows, read [docs/Game-Sync.md](docs/Game-Sync.md) and use the **`fs-game-score-live-sync`** skill.
- **Game ID behavior**: `Game.fromJson()` intentionally generates a new `gameId` on load — do not rely on persisted `gameId` being preserved.
- **Integration tests**: Use `integration_test/app_test_helpers.dart` — **`await bootstrapApp()`** via `launchApp` / `launchAppOnSplash`; never call `main()` without awaiting (Android race). Clear prefs in `setUp`/`tearDown` via `clearPersistedGameState()`.

### Localization

- Localization is configured in `l10n.yaml` and generated code is used.
- When adding or modifying user-facing text, ensure it utilizes the generated localization bindings.
- After editing `.arb` files, run `fvm flutter gen-l10n`.

### Project-specific conventions (must follow)

- **Widget keys**: Follow established `ValueKey` helpers — do not hardcode the same strings in tests:
  - `PlayerGameCell.nameKey(playerIdx)`, `PlayerGameCell.cellKey(playerIdx)` — [player_game_cell.dart](lib/presentation/player_game/player_game_cell.dart)
  - `PlayerRoundModal.scoreFieldKey(playerIdx, round)` — [player_round_modal.dart](lib/presentation/player_round/player_round_modal.dart)
  - `PlayerRoundCell.cellKey(playerIdx, round)` — [player_round_cell.dart](lib/presentation/player_round/player_round_cell.dart)
  - Tests should use these functions (see `integration_test/`). Modal/global panel fields need repeatable keys per player/round — use the **`fs-game-score-widgets-holding-player-game-data`** skill.
- **Semantics & modals**: Widgets showing player/game data must expose semantic labels or be wrapped in `Semantics`. Modal `AlertDialog` content should be scrollable and adapt layout by orientation when there are 2–3 fields — use the **`fs-game-score-widgets-holding-player-game-data`** skill.
- **State management**: Use Riverpod 3 `Notifier` patterns; UI watches `gameNotifierProvider` / `playersNotifierProvider`.

### Code quality and styling

- This codebase enforces high code quality standard guidelines defined in `analysis_options.yaml` and is configured with `very_good_analysis`.
- Style: line length ~80 chars, PascalCase for classes, camelCase for members, snake_case for filenames. Prefer immutable widget patterns, `const` constructors, and small private widgets instead of long `build()` methods.
- Before submitting code modifications:
  1. Format your changes: `fvm dart format .`
  2. Run static analysis: `fvm flutter analyze`
  3. Apply mechanical fixes where appropriate: `fvm dart fix --apply`
  4. Ensure no errors or warnings are introduced.

---

## Running tests & verification

Unit and widget tests:

```bash
fvm flutter test
```

Integration tests (mobile):

```bash
fvm flutter test integration_test/*_test.dart
```

- **Integration tests**: `await launchAppOnSplash(tester)` from [app_test_helpers.dart](integration_test/app_test_helpers.dart) (wraps `await bootstrapApp()`).
- **Widget/unit tests**: Mock prefs in [test/flutter_test_config.dart](test/flutter_test_config.dart); override `sharedPreferencesProvider` in `ProviderScope` when testing code that uses repositories.
- Tests use Arrange-Act-Assert. Prefer `find.byKey(...)` with the key helper functions and `tester.tap(...)` / `tester.enterText(...)` patterns used in existing tests.

---

## Project skills

Cursor and Antigravity auto-discover skills in [`.agents/skills/`](.agents/skills/) when frontmatter is valid. Copilot reads this file — open the skill file when the task matches.

| Skill | Use when |
| :--- | :--- |
| `fs-game-score-widgets-holding-player-game-data` | Player/round UI, widget keys, semantics, modals |
| `fs-game-score-flutter-patterns` | General Flutter/Riverpod UI work |
| `fs-game-score-testing-workflow` | Tests, widget keys in tests, accessibility |
| `fs-game-score-live-sync` | LAN live sharing (host/spectator, protocol, join UI) |
| `fs-game-score-release-engineer` | Version tagging, builds, CHANGELOG, store release notes |
| `release-flutter-upgrade-sdk` | Flutter/Dart SDK upgrades (FVM, CI, changelogs) |

Upstream Dart/Flutter skills in the same folder cover generic tasks (unit tests, widget tests, l10n, routing, etc.).

---

## When to ask for clarification

- If a requested change affects persistence, tests, or widget keys — ask before changing keys or test selectors.
- For release tagging or version bumps, use the **`fs-game-score-release-engineer`** skill. For Flutter version, build system, or CI changes, use **`release-flutter-upgrade-sdk`** and ask for confirmation before migrating.

---

## Quick file references

| Area | Paths |
| :--- | :--- |
| Widget key helpers | [player_round_modal.dart](lib/presentation/player_round/player_round_modal.dart), [player_game_cell.dart](lib/presentation/player_game/player_game_cell.dart), [player_round_cell.dart](lib/presentation/player_round/player_round_cell.dart) |
| Providers | [prefs_provider.dart](lib/provider/prefs_provider.dart), [game_provider.dart](lib/provider/game_provider.dart), [players_provider.dart](lib/provider/players_provider.dart) |
| Persistence & splash | [game_repository.dart](lib/data/game_repository.dart), [players_repository.dart](lib/data/players_repository.dart), [splash_screen.dart](lib/presentation/splash_screen.dart) |
| Docs | [State-Management.md](docs/State-Management.md), [Game-Sync.md](docs/Game-Sync.md), [Live-Score-Sharing-Design.md](docs/Live-Score-Sharing-Design.md) |
| Tests | `integration_test/*_test.dart`, [app_test_helpers.dart](integration_test/app_test_helpers.dart) |
| Project skills | `.agents/skills/fs-game-score-*/SKILL.md`, [release-flutter-upgrade-sdk](.agents/skills/release-flutter-upgrade-sdk/SKILL.md) |
| Release | [fs-game-score-release-engineer](.agents/skills/fs-game-score-release-engineer/SKILL.md), [tag-push.sh](tag-push.sh), [CHANGELOG.md](CHANGELOG.md) |

Thank you for building responsibly!
