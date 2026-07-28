---
name: fs-game-score-flutter-patterns
description: >
  Riverpod 3 Notifier patterns, go_router routing, SharedPreferences persistence,
  and Flutter UI conventions for fs-game-score. Use for any feature work or
  provider change, splash/score-table flows, adding or translating user-facing
  strings (.arb files, gen-l10n), localizing semantic labels, and Mille Bornes /
  game-mode terminology — even when the request doesn't mention architecture or
  l10n by name.
---

# FS Score Card — Flutter patterns

Project-specific implementation patterns. Full architecture: [docs/State-Management.md](../../../docs/State-Management.md).

**Related skills:** `fs-game-score-widgets-holding-player-game-data` (keys/semantics/modals), `fs-game-score-live-sync` (LAN sharing), `fs-game-score-testing-workflow` (tests).

Always prefix Flutter/Dart commands with **`fvm`** per [AGENTS.md](../../../AGENTS.md).

---

## State management (Riverpod 3)

App state uses **`Notifier` / `NotifierProvider`** (`hooks_riverpod` ^3.1.0), not Bloc/GetX/Provider.

| Layer       | Providers                                                                                 |
| ----------- | ----------------------------------------------------------------------------------------- |
| DI          | `sharedPreferencesProvider` — overridden in `bootstrapApp()`                              |
| Persistence | `gameRepositoryProvider`, `playersRepositoryProvider` — `load*` / `save*` / `clear*` only |
| Live state  | `gameNotifierProvider`, `playersNotifierProvider`                                         |
| Routing     | `appRouterProvider` — resume via `initialLocation(prefs)`                                 |

Per-provider responsibilities and the `ref.watch` / `ref.read` rules are canonical in [How-To-Riverpod.md — Provider layers](../../../docs/How-To-Riverpod.md#provider-layers-top-to-bottom); this table is the at-a-glance map.

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

Prefs keys and repository responsibilities are canonical in [State-Reference.md — Prefs keys](../../../docs/State-Reference.md#prefs-keys) (`game_state` → `GameRepository`, `players_state` → `PlayersRepository`).

Splash **Start new game** saves config via `newGame()` and baseline roster via `playersRepositoryProvider.savePlayers(...)`.

---

## Serialization

Models use **hand-written** `fromJson` / `toJson` in `lib/model/` — **not** `json_serializable`. See `lib/model/game.dart`, `lib/data/game_repository.dart`.

---

## Localization

Supported locales: **en** (template), **es**, **fr** — declared in `supportedLocales` in `lib/app.dart`. Strings live in `lib/l10n/app_<locale>.arb`; `fvm flutter gen-l10n` regenerates `AppLocalizations`.

### Adding / changing a string

1. Add the key to **`app_en.arb`** (the template) with an `@<key>` block: `description`, plus `placeholders` (with `type`) for any `{arg}`.
2. Mirror the **value** into **`app_es.arb`** and **`app_fr.arb`** — `@`-metadata lives only in the template. **Every key must exist in every `.arb`** (missing keys silently fall back to English). Verify parity before regenerating, e.g.:
   ```bash
   python3 -c "import json;k=lambda f:{x for x in json.load(open(f)) if x[0]!='@'};\
   b=k('lib/l10n/app_en.arb');[print(l,sorted(b-k(f'lib/l10n/app_{l}.arb'))) for l in('es','fr')]"
   ```
3. Run `fvm flutter gen-l10n`, then `fvm flutter analyze` and `fvm flutter test`.

Adding a new locale = new `app_<locale>.arb` (all keys) **plus** a `Locale('<code>')` in `lib/app.dart`.

### Localize every user-facing string — including accessibility labels

> **Canonical rule (single source of truth).** Other skills link here — keep the policy in this section only.

**`Semantics.label`, `semanticLabel`, and `Text(semanticsLabel:)` ARE user-facing** (screen readers) and **must be localized** — do not hardcode them. Use a `*Label` key suffix to mark semantics-only strings (e.g. `scoreTableLabel`, `playerRoundScoreLabel`, `numberOfSafetiesLabel`). Pass runtime values as placeholders: `l10n.playerRoundScoreLabel(playerIdx + 1, round + 1)`. When a file has no l10n yet, add `import 'package:fs_score_card/l10n/app_localizations.dart';` and read `AppLocalizations.of(context)!`.

A custom analyzer lint — **`localize_semantic_labels`** (package `tools/fs_score_lints`, enabled via `custom_lint` in `analysis_options.yaml`) — flags any `semanticLabel:` / `semanticsLabel:` / `Semantics(label:)` that is a hardcoded string literal instead of an `l10n` / `AppLocalizations` call. It surfaces in-editor and via `fvm dart run custom_lint`.

### Game terminology — use authentic Mille Bornes lingo per locale

The "French Driving" mode is the real card game **Mille Bornes** (name it `Mille Bornes` in every locale, untranslated). **Never machine-translate game terms literally** — each edition has its own canonical vocabulary. Use these:

| Concept (key)   | en (official Am. edition) | fr (authentic)      | es (authentic)   |
| --------------- | ------------------------- | ------------------- | ---------------- |
| `miles`         | Miles                     | Bornes              | Kilómetros       |
| `safeties`      | Safeties                  | Bottes              | Bottes           |
| `coupFourre`    | Coup Fourré               | Coup fourré         | Coup Fourré      |
| `delayedAction` | Delayed Action            | Couronnement        | Acción retardada |
| `safeTrip`      | Safe Trip                 | Voyage sans les 200 | Viaje seguro     |
| `shutOut`       | Shut-Out                  | Capot               | Capote           |

Principle: **en** = official Hasbro/Winning-Moves American terms; **fr** = authentic French (1000 Bornes) terms; **es** = authentic Spanish-edition terms. When adding a new locale or term, look up that edition's real wording rather than translating the English — verify against [fr.wikipedia 1000 Bornes](https://fr.wikipedia.org/wiki/1000_Bornes) / [es.wikipedia Mil hitos](https://es.wikipedia.org/wiki/Mil_hitos). Keep tooltip point values and unit words (miles/bornes/km) consistent within each locale.

See **`flutter-setup-localization`** for generic l10n setup.

---

## UI conventions

- Prefer **`StatelessWidget`**, `const` constructors, small private widgets over helper methods returning widgets.
- **`ListView.builder`** for long lists.
- **`AlertDialog(scrollable: true)`** for modals — see widget skill for orientation layout when 2–3 fields.
- Lint: **`very_good_analysis`**; ~80 char lines; `fvm dart format .` before submit.

---

## Anti-patterns (do not reintroduce)

Riverpod / persistence anti-patterns are canonical in [How-To-Riverpod.md — Anti-patterns](../../../docs/How-To-Riverpod.md#anti-patterns-do-not-reintroduce) — singleton repositories, `repositoryDidLoadPrefs()`, `ref.watch` in event handlers, saves/timers in `Notifier.build()`, and fire-and-forget `main()` in integration tests. Follow that list.

One project convention beyond those:

| Anti-pattern                                   | Why                                                                                                                    |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `switch (gameMode)` / `== GameMode.x` behavior | Put per-mode behavior in the `GameRules` descriptor (`lib/model/game_rules.dart`) — enforced convention, see AGENTS.md |

---

## Key files

- `lib/provider/game_provider.dart`, `lib/provider/players_provider.dart`
- `lib/model/game_rules.dart` — `GameRules` descriptor + `rulesFor(GameMode)`; add a mode here, don't branch on `GameMode`
- `lib/provider/prefs_provider.dart`, `lib/data/*_repository.dart`
- `lib/main.dart`, `lib/router/app_router.dart`
- `lib/presentation/splash_screen.dart`, `lib/presentation/new_score_card_control.dart`
- `test/players_notifier_persist_test.dart` — coalesced persist and splash clear
