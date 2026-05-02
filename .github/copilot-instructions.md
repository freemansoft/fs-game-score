# Copilot / AI Instructions — fs_score_card

Purpose: Short, actionable guidance to help an AI coding agent be productive in this repo.

## Big picture
- Flutter app (multi-platform) for a player/round score card. Key folders:
  - `lib/presentation/` — UI widgets (score table, modals, screens)
  - `lib/provider/` — Riverpod `Notifier` providers (`game_provider`, `players_provider`)
  - `lib/model/` — plain Dart model classes (Game, Players, Player, Scores)
  - `integration_test/` and `test/` — tests and integration tests
- Data flow: `game_provider` holds global config; `players_provider.build()` watches `game_provider` and creates player state to match game dimensions (numPlayers, maxRounds).
- Persistence: Game configuration saved to `SharedPreferences` in `lib/splash_screen.dart` (use `Game.toJson()` / `Game.fromJson()` patterns).

## Quick commands (use `fvm` when present)
- Install/use Flutter version via fvm: `fvm install <version>` / `fvm use <version>`
- Get packages: `fvm flutter pub get` (or `flutter pub get` if not using fvm)
- Localized strings: `fvm flutter gen-l10n` after editing `.arb` files
- Run unit/widget tests: `fvm flutter test` (or `flutter test`)
- Run integration tests (mobile only): `fvm flutter test integration_test/*_test.dart`
- Build: `fvm flutter build <platform>` (e.g., `apk`, `web`, `macos`, `windows`)
- Release tagging: use `tag-push.sh --version <x.y.z> --build-id <n>` to create a release tag

## Project-specific conventions (must follow)
- Widget keys: follow the established ValueKey helpers (see examples):
  - `PlayerGameCell.nameKey(playerIdx)`, `PlayerRoundModal.scoreFieldKey(playerIdx, round)`, `PlayerRoundCell.cellKey(playerIdx, round)`
  - Tests should use these functions (tests in `integration_test/` show usage). Do NOT hardcode the same strings in tests.
- Modal & semantics rules: `.cursor/rules/*` enforce semantics and key naming. Examples:
  - Widgets that show player data must expose semantic labels or be wrapped in Semantics
  - Modal/alert dialogs should be scrollable and layout by orientation when 2–3 fields exist
- State management: use Riverpod `Notifier` patterns. `PlayersNotifier.build()` should watch `gameProvider` and rebuild players when configuration changes.
- Game ID behavior: `Game.fromJson()` intentionally generates a new `gameId` on load — do not rely on persisted `gameId` being preserved.

## Tests & integration tests
- Integration tests check widget keys and flows. Re-run specific integration tests as shown in README (e.g. `flutter test integration_test/splash_screen_test.dart`).
- Tests use Arrange-Act-Assert. Prefer `find.byKey(...)` with the key helper functions and `tester.tap(...)` / `tester.enterText(...)` patterns used in existing tests.

## Linting & style
- `very_good_analysis` is used (see `analysis_options.yaml`). Follow the repo's style choices:
  - Line length ~80 chars, PascalCase for classes, camelCase for members, snake_case for filenames
  - Use `dart format` and `dart fix` where appropriate
  - Prefer immutable widget patterns, `const` constructors, and small private widgets instead of long `build()` methods

## When to ask clarification or open PRs
- If a requested change affects persistence, tests, or widget keys — ask before changing keys or test selectors
- For changes to project configuration (Flutter version, build system, or CI), ask for confirmation and explain the migration steps and compatibility risks

## Quick file references (examples to inspect)
- Key helpers: `lib/presentation/player_round_modal.dart`, `lib/presentation/player_game_modal.dart`, `lib/presentation/player_round_cell.dart`
- Provider patterns: `lib/provider/game_provider.dart`, `lib/provider/players_provider.dart`
- Persistence: `lib/splash_screen.dart`
- Integration tests: `integration_test/*_test.dart`
- Cursor rules: `.cursor/rules/*.md` (key naming, semantics, modal layouts)

If anything is unclear or you want the doc expanded with more examples (e.g., common refactor patterns, PR checklist), tell me which area to expand and I'll update this file accordingly.