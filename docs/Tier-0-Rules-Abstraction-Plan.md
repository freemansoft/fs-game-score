# Tier 0 implementation plan: generic rules abstraction

Planning artifact for **Phase 0 / Tier 0** of the [Game-Modes-Roadmap](Game-Modes-Roadmap.md). Not Diátaxis prose — this is a design/plan record and is out of scope for the docs-diataxis skill.

## Goal

Replace the per-mode `switch` / `if`-on-`GameMode` branching that is scattered across the model and presentation layers with a single **`GameRules` descriptor per mode**. After this change, adding a mode (Tiers 1–4) means adding a descriptor plus any genuinely new primitive — not threading another `enum` case through the model, splash, editors, and tests.

## Non-goals (explicitly out of scope for Tier 0)

- **No new player-visible behavior.** The four existing modes (`standard`, `phase10`, `frenchDriving`, `skyjo`) must behave **identically** after the refactor.
- **No teams, no low-score-wins, no new games.** Those are Tiers 1–4. Tier 0 only reshapes *how* behavior is selected, and leaves **hooks** (descriptor fields) where those tiers will plug in.
- **No change to the persisted JSON shape or the live-sync wire format** (see Invariants).

## Current state — where mode behavior lives today

`GameMode` is one enum (`lib/model/game.dart:5`) with behavior derived ad hoc in these places:

| Concern | Site | Current logic |
| --- | --- | --- |
| Phase count | `game.dart` `numPhases` | `phase10 ? 10 : 0` |
| Negative scores | `game.dart` `allowNegativeScores` | `skyjo` only |
| Phases enabled | `game.dart` `enablePhases` | `phase10` only |
| Mode picker + auto-config | `splash_screen.dart` `_buildGameModeField` (169–235) | dropdown items; auto score filter for `phase10`/`frenchDriving`; auto end score `skyjo`→100, `frenchDriving`→5000 |
| Round editor layout | `player_round_modal.dart` (99–215) | `frenchDriving` disables typed field + shows `FrenchDrivingRoundPanel`; `phase10` shows phase dropdown; `skyjo` allows negative |
| Round cell display | `player_round_cell.dart` (95) | phase shown only for `phase10` |
| Total-cell / game modal | `player_game_modal.dart`, `score_table.dart:212` | `enablePhases` display toggle |
| End-game highlight | `player_game_cell.dart:52` | `endGameScore > 0 && totalScore >= endGameScore` (reach-target only) |
| Score filters | `score_filters.dart` | `none`, `endsWith0or5`, `signedDigits` |

`Player` (`lib/model/player.dart`) already carries **all** extension collections (`scores`, `phases`, `frenchDrivingAttributes`, `roundStates`) regardless of mode, and serializes them all. Tier 0 does **not** change this.

## Target design

Introduce `lib/model/game_rules.dart`:

- **`class GameRules`** — an immutable descriptor with fields covering every concern above, e.g.:
  - `scoreFilter` (String, from `ScoreFilters`)
  - `allowNegativeScores` (bool)
  - `enablePhases` (bool) and `numPhases` (int)
  - `roundInput` — enum `{ typedScore, calculatedFrenchDriving }` (drives whether the typed field is editable/autofocused and which panel renders)
  - `suggestedEndGameScore` (int?, e.g. 100 / 5000 / null)
  - **Hooks for later tiers** (declared now, single value for now, so Tier 1–2 add data not branches):
    - `aggregation` — enum `{ sumPerPlayer }` today; `sumPerTeam`, `lowScoreWins` later.
    - `endCondition` — enum `{ reachTargetHighlight }` today; `loserThreshold`, `winnerDetection` later.
- **`GameRules rulesFor(GameMode mode)`** — a `const`/lazy registry (map or `switch` in **one** place) returning the descriptor. This is the *only* remaining `switch` on `GameMode`.

Then migrate call sites to read from the descriptor:

1. `game.dart` getters (`numPhases`, `allowNegativeScores`, `enablePhases`) delegate to `rulesFor(gameMode)` (keep the getters as a thin facade so external callers/tests don't churn).
2. `splash_screen.dart` builds dropdown labels from the mode list and reads `scoreFilter` / `suggestedEndGameScore` from the descriptor instead of inline `if (value == ...)`.
3. `player_round_modal.dart` chooses field-enabled / autofocus / negative / which panel from `roundInput` + `allowNegativeScores`.
4. `player_round_cell.dart`, `player_game_modal.dart`, `score_table.dart` read `enablePhases` from the descriptor.
5. `player_game_cell.dart` reads `endCondition` (still only `reachTargetHighlight`) — leaving the seam where Tier 2 low-score-wins will branch.

### Invariants (must not break)

- **Persistence:** `GameConfiguration.toJson` still writes `'gameMode': gameMode.toString()` and the `'enablePhases'` back-compat field (`game.dart:73–74`). The descriptor is derived at runtime; it is **not** serialized. Existing saved `game_state` / `players_state` must load unchanged — covered by `test/game_serialization_test.dart`, `test/players_restore_test.dart`.
- **Live sync:** wire payloads are unchanged (they carry config + player data, not rules). No changes under `lib/sync/`.
- **Widget keys / semantics:** unchanged, so `docs/Semantics-Labels.md`, the testing skill, and `integration_test/app_test.dart` keys stay valid.

## Testing

- New `test/game_rules_test.dart`: assert every `GameMode` resolves to a descriptor; assert per-mode field values match today's behavior (filter, negatives, phases, suggested end score, roundInput).
- Assert the `game.dart` facade getters return the same values as before (guards the delegation).
- Re-run the existing per-mode **integration tests** (`integration_test/app_test.dart`) unchanged — they are the behavioral regression net that proves "identical behavior."
- `dart analyze` clean; run the coverage skill if a threshold is enforced.

## Docs to update (become out of date after this change)

| Doc | Why it goes stale | Update |
| --- | --- | --- |
| `docs/Game-Modes.md` | "internal model" sections + "System facts" describe per-mode getters; still reference the `switch` mental model | Add a short "Rules descriptor" note; point per-mode internal-model sections at the descriptor fields. Keep it **reference** voice. |
| `docs/State-Reference.md` | Lists `GameConfiguration` fields/getters (`numPhases`, `allowNegativeScores`, `enablePhases`) and key files | Note the getters now delegate to `GameRules`; add `lib/model/game_rules.dart` to the key-files list. |
| `docs/Game-Modes-Roadmap.md` | Phase 0 is "do first" and the Architectural note describes the `switch` as current state | Mark Phase 0 delivered; reword the Architectural note to past tense; confirm Tier 1 "built as descriptors" framing. |
| `.claude/skills/fs-game-score-flutter-patterns/SKILL.md` **and** `.agents/skills/fs-game-score-flutter-patterns/SKILL.md` | "how to add a game mode" guidance describes the old scattered-`switch` procedure | Rewrite the add-a-mode steps to "add a `GameRules` descriptor + register it"; keep both copies in sync (check `skills-lock.json`). |
| `README.md` | User-facing game-types table is fine; only the **Developer notes** section may mention the mode-dispatch approach | Update only if it describes internals; leave the user-facing table unchanged (no behavior change). |
| `docs/How-To-Edit-Scores.md`, `docs/Semantics-Labels.md` | User-facing steps / widget keys — unaffected by an internal refactor | Verify only; expect no change. |

Do the doc updates **in the same PR** as the code so the repo never describes a structure that no longer exists.

## Suggested sequencing

1. Add `game_rules.dart` + `rulesFor` + `game_rules_test.dart` (no call sites changed yet) — descriptors defined, tests green.
2. Delegate `game.dart` getters to the descriptor; run unit + integration tests.
3. Migrate presentation call sites one file at a time (splash → round modal/cell → game modal/cell/score table), running integration tests after each.
4. Remove now-dead inline conditionals; `dart analyze`.
5. Update the docs/skills in the table above.

## Verification

- `flutter test` (unit) and the integration suite (`integration_test/app_test.dart`) both green with **no test changes** to the mode behaviors — the proof of identical behavior.
- Manually exercise each of the four modes via the run skill (splash → enter/calculate a round → total/highlight) to confirm parity.
- `dart analyze` clean; confirm no new `switch (gameMode)` outside `game_rules.dart` (`grep -rn "GameMode\." lib` should only hit the enum, the registry, and the splash dropdown item list).
- Load a pre-change saved game (or the serialization tests) to confirm on-disk compatibility.
