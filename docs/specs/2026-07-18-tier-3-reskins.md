# Tier-3 reskins (Rummy, Uno, Farkle, Rummikub) — design and decisions

Adds four named preset game modes on top of the existing round-grid engine — **Rummy**, **Uno**, **Farkle**, and **Rummikub**. This is Tier 3 of the [Game-Modes-Roadmap](../Game-Modes-Roadmap.md): the value is convenience and identity (a named splash entry with auto-filled target/filter/negatives), not new scoring capability. Each mode is a `GameRules` descriptor plus localized labels — no new engine primitives.

For the descriptor architecture, see [Game-Modes-Roadmap.md — Phase 0](../Game-Modes-Roadmap.md#phase-0--generic-rules-abstraction-foundation) and `lib/model/game_rules.dart`.

---

## Overview

| Aspect         | Selection                                                                                               |
| -------------- | ------------------------------------------------------------------------------------------------------- |
| Scope          | **Four new modes** — Rummy, Uno, Farkle, Rummikub — as `GameRules` descriptors                          |
| New capability | **None** — each is Standard-mode behavior with a preset target/filter/negatives and a named entry       |
| Round input    | **`RoundInput.typedScore`** for all four                                                                |
| Splash         | Append four `DropdownMenuItem`s; existing `onChanged` auto-applies target/filter/rounds from `rulesFor` |
| Wire format    | **Additive** — new `GameMode` values in the existing `gameMode` string; **not breaking**, no major bump |
| Out of scope   | Any new scoring primitive, per-mode custom editors, team/low-wins behavior, per-locale name translation |

---

## Selected decisions (summary)

| Decision           | Selected                                                              | Rationale                                                                                                 |
| ------------------ | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Modes to ship      | **Rummy, Uno, Farkle, Rummikub**                                      | Common games; Farkle adds a filter and Rummikub adds negatives, so not pure relabels.                     |
| Mode names         | **Untranslated across en/es/fr**                                      | Branded/proper-noun game names, consistent with existing `Skyjo` / `Phase 10` / `Mille Bornes`.           |
| Integration tests  | **Lean, one per mode** — assert only each mode's distinctive behavior | Full per-mode flows duplicate the Standard/Skyjo paths and add ~4× app-build CI time for little coverage. |
| Version impact     | **Minor** (stays in `2.1.0 - not yet released`); **no major bump**    | New enum values are additive to the live-share wire; not a shape change.                                  |
| Trademark handling | **Rely on the existing blanket disclaimer**                           | `Help-And-Disclaimers.md` already covers all product names; no per-game list to maintain.                 |

---

## Model changes (`lib/model/game_rules.dart`)

Four new `GameMode` values appended (never reorder — `toString()` is the persisted/wire key):

```dart
enum GameMode {
  standard, phase10, frenchDriving, skyjo, golf, hearts,
  rummy, uno, farkle, rummikub,
}
```

Descriptors (all: `RoundInput.typedScore`, `enablePhases: false`, `numPhases: 0`, `aggregation: sumPerPlayer`, `endCondition: reachTargetHighlight`, `winDirection: highestWins`, `roundOptions: _standardRoundOptions`, `suggestedMaxRounds: _standardSuggestedMaxRounds`):

| Mode         | allowNegativeScores | suggestedScoreFilter        | suggestedEndGameScore |
| ------------ | ------------------- | --------------------------- | --------------------- |
| **Rummy**    | false               | `ScoreFilters.none`         | 500                   |
| **Uno**      | false               | `ScoreFilters.none`         | 500                   |
| **Farkle**   | false               | `ScoreFilters.endsWith0or5` | 10000                 |
| **Rummikub** | **true**            | `ScoreFilters.none`         | 0 (no target)         |

Farkle's filter (scores are multiples of 50) and Rummikub's negatives (remaining tiles count against you) are the only descriptor fields that differ from a plain relabel.

---

## Splash (`lib/presentation/splash_screen.dart`)

No new logic. Append four `DropdownMenuItem`s to `_buildGameModeField`. The existing `onChanged` already reads `rulesFor(value)` and applies `suggestedScoreFilter`, `suggestedEndGameScore`, and the round snapping — so Farkle auto-fills 10000 + the 0/5 filter, Rummy/Uno auto-fill 500, and Rummikub clears the target and enables negative entry (via `allowNegativeScores` in the round editor, as Skyjo already does).

---

## Localization (`lib/l10n/app_*.arb`)

Four mode-name keys — `gameModeRummy`, `gameModeUno`, `gameModeFarkle`, `gameModeRummikub` — with the **same value in en/es/fr** (untranslated brand/game names, exactly as `gameModeSkyjo` is today). No other new strings; the round editor, target, and filter reuse existing localized UI.

---

## Wire compatibility (checked per the live-share rule)

The shared snapshot serializes `GameConfiguration.toJson()` (`gameMode` as a string) and `Player.toJson()`. These four modes add **values**, not keys/types — the snapshot shape is unchanged. A same-major spectator understands them; an unknown value falls back to `defaultGameMode` via `GameConfiguration.fromJson`. **Not a breaking change; no major version bump.** See the `fs-game-score-live-sync` skill (Wire compatibility and versioning).

---

## Documentation (per the game-change doc rule)

- **README.md** — four rows in the "Scoreboards and game types" table.
- **CHANGELOG.md** — one bullet under `## [2.1.0] - not yet released`.
- **docs/Game-Modes.md** — add to the "Supported modes" list and a short per-mode section each.

---

## Testing

| Layer                                          | Coverage                                                                                                                                                                                                                                                                |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `test/game_rules_test.dart`                    | The four descriptors expose the expected target/filter/negatives; existing modes unchanged.                                                                                                                                                                             |
| `test/splash_game_mode_test.dart`              | The picker offers Rummy, Uno, Farkle, Rummikub.                                                                                                                                                                                                                         |
| Integration (`integration_test/app_test.dart`) | **Lean, one per mode**, asserting only the distinctive behavior: **Rummy** and **Uno** — reaching 500 bolds the total (target highlight); **Farkle** — the round field rejects a non-0/5 value (filter); **Rummikub** — a negative round score yields a negative total. |

---

## Out of scope (YAGNI)

- **New scoring primitives** — these are presets over the existing round grid.
- **Per-mode custom round editors** — all four use typed scores.
- **Per-locale name translation** — deliberately untranslated.
- **Low-score-wins / team behavior** — Tier 1–2 concerns, not reskins.
- **Full per-mode integration flows** — the lean tests cover the distinctive behavior; the shared grid path is already covered by the Standard/Skyjo integration tests.
