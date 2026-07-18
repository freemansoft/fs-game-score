# Tier-2 low-score-wins (Golf + Hearts) — design and decisions

Adds the **low-score-wins** scoring capability to fs-game-score and ships the two games it unlocks: **Golf** (card game — fixed rounds, lowest total wins) and **Hearts** (lowest total wins, game ends when a player crosses a loser threshold). This is Tier 2 of the [Game-Modes-Roadmap](../Game-Modes-Roadmap.md); it fills the reserved `EndCondition` seam and introduces the first cross-player ranking primitive.

For the descriptor architecture this plugs into, see [Game-Modes-Roadmap.md — Phase 0](../Game-Modes-Roadmap.md#phase-0--generic-rules-abstraction-foundation) and `lib/model/game_rules.dart`. For Riverpod/persistence patterns, see [State-Management.md](../State-Management.md).

---

## Overview

| Aspect | Selection |
| ------ | --------- |
| Scope | **Two new modes** — Golf and Hearts — plus the shared low-score-wins primitive |
| New capability | **Lowest total wins** (relative, cross-player) + **loser-threshold** end condition |
| Round input | **`RoundInput.typedScore`** — no custom editor; scorekeeper types the number |
| New UI | A **leader marker** inside the existing two-row player cell (accent color + inline icon) |
| Blast radius | Existing modes (standard, phase10, frenchDriving, skyjo) are **behaviorally unchanged** |
| Out of scope | Global game-over banner, full ranking beyond 1st place, auto-lock at threshold, per-mode default round counts, team roll-up |

---

## Selected decisions (summary)

| Decision | Selected | Rationale / change how |
| -------- | -------- | ---------------------- |
| Win direction modeling | **New `WinDirection` field** on `GameRules` | Orthogonal to aggregation; avoids a combinatorial enum. Composes with future team roll-up. **Deviates from the roadmap's** "put low-vs-high in `ScoreAggregation`" — roadmap note updated to match. |
| End condition | **Extend `EndCondition` with `loserThreshold`** | Reuses the seam the roadmap explicitly reserved. |
| Winner computation | **`Players.leaderIndices(WinDirection)`** | First cross-player primitive; where team roll-up will later hook in. |
| Leader marker scope | **Low-wins modes only** | High-wins crosser already *is* the winner; keeps existing modes' UX and tests stable. |
| Leader marker rendering | **Inside the existing two-row cell** (accent color + inline leading icon on the total row) | Cells display exactly two rows; the marker must not add a third. |
| Hearts "shoot the moon" | **Not modeled** — scorekeeper types the resulting number | Keeps `RoundInput.typedScore`; no engine support needed. |

---

## Model changes (`lib/model/game_rules.dart`)

Two **orthogonal** axes, added as descriptor data (no branching on `GameMode`):

```dart
enum WinDirection { highestWins, lowestWins }

enum EndCondition { reachTargetHighlight, loserThreshold } // + loserThreshold
```

- `GameRules` gains a `final WinDirection winDirection;` field (default `highestWins`).
- All four existing descriptors set `winDirection: WinDirection.highestWins` and keep `endCondition: EndCondition.reachTargetHighlight` explicitly — behavior identical to today.

### Why a dedicated `WinDirection` field (roadmap deviation)

The roadmap reserved `ScoreAggregation` to encode "low-vs-high." But win-direction (who wins) and aggregation (per-player vs. per-team totals) are independent axes; folding them together yields a combinatorial enum (`sumPerPlayerHigh`, `sumPerPlayerLow`, `teamHigh`, `teamLow`, …). A separate `WinDirection` field composes cleanly with the future team roll-up. **Action:** update the `aggregation` note in `Game-Modes-Roadmap.md` to point at `WinDirection`.

---

## Cross-player primitive (`lib/model/players.dart`)

```dart
/// Indices of the player(s) currently winning under [dir]:
/// the min (lowestWins) or max (highestWins) total. Ties return all.
/// Returns an empty list until at least one score has been entered,
/// so a fresh 0–0 board does not highlight everyone.
List<int> leaderIndices(WinDirection dir);
```

- Empty-board guard: if no player has any non-null round score entered, return `[]`.
- Ties: return every index sharing the extreme total.
- This is the genuinely new capability. Team roll-up (Tier 1) will extend the same method to compare team totals.

---

## UI changes

### Two highlights, both within the two-row cell

The player cell (`lib/presentation/player_game/player_game_cell.dart`) stays exactly two rows — **name row** and **total row**. Neither highlight adds a third.

| Treatment | Rendering (no new row) | Meaning |
| --------- | ---------------------- | ------- |
| **bold + italic** (existing, unchanged) | restyles the same name+total text | crossed the `endGameScore` line — *goal reached* (high-wins) or *limit hit that ends the game* (Hearts) |
| **leader marker** (new) | **accent color + a small inline leading icon on the total row** — e.g. `▲ 42` as a `Row[icon, total]`, still one visual row | current/final winner = `min` total (**low-wins modes only**) |

The two treatments are independent: a low-wins cell can show either, both, or neither. `PlayerGameCell` gains an `isLeader` bool (default `false`); a semantics label `playerLeaderLabel` is announced when set.

### Wiring (`lib/presentation/score_table.dart`)

- The score table already has the full `players` list and `game.configuration` in scope (`score_table.dart:133`).
- Compute `leaderIndices(config.rules.winDirection)` once per build; pass `isLeader: leaders.contains(playerIdx)` to each `PlayerGameCell`, but only when `config.rules.winDirection == WinDirection.lowestWins` (scope guard).
- `getRowColor` zebra striping is untouched (tinting the leader row would fight the stripe).

---

## Modes, descriptors & defaults (`game_rules.dart`)

Two new `GameMode` values (`golf`, `hearts`) — `toString()` keys must stay stable for persistence.

| Mode | input | negatives | winDirection | endCondition | suggested target | suggested filter |
| ---- | ----- | --------- | ------------ | ------------ | ---------------- | ---------------- |
| **Golf** | typed | false | lowestWins | reachTargetHighlight (unused) | 0 (none — ends at maxRounds) | none |
| **Hearts** | typed | false | lowestWins | loserThreshold | 100 | none |

`maxRounds` / `numPlayers` stay user-chosen on the splash screen (no per-mode round-count suggestion in this slice).

---

## Localization (`lib/l10n/app_*.arb`)

New keys in **en (template) + es + fr**, following the parity check and the semantics-label rule in the `fs-game-score-flutter-patterns` skill:

- Mode picker labels: `gameModeGolf`, `gameModeHearts` (the game names are proper nouns; the surrounding picker text/tooltips localize).
- Semantics: `playerLeaderLabel` (announced on the leading cell), with the player number as a placeholder.
- Any splash helper/tooltip copy the new modes introduce.

Regenerate with `fvm flutter gen-l10n`; verify key parity across the three `.arb` files before running analyze/test.

---

## Testing

| Layer | Coverage |
| ----- | -------- |
| `test/game_rules_test.dart` | Golf and Hearts descriptors expose the expected `winDirection` / `endCondition` / target; existing four modes still report `highestWins` + `reachTargetHighlight`. |
| `players` unit test | `leaderIndices`: min selection (lowWins), max selection (highWins), ties return all, empty board returns `[]`. |
| Widget test | Leader marker renders on the min-total cell in a low-wins mode; **absent** in a high-wins mode; `bold+italic` still applies on `endGameScore` crossing independently. |
| Integration/splash | The mode picker offers Golf and Hearts; selecting each applies the suggested target/filter. |

---

## Out of scope (YAGNI)

- **Global "game over" banner** — matches today (there is none); the threshold crossing is conveyed by the existing bold+italic cell style.
- **Ranking beyond 1st place** — only the leader(s) are marked, not 2nd/3rd.
- **Auto-lock rounds at threshold** — crossing the Hearts limit does not freeze input.
- **Per-mode default round counts** — a separate splash-configuration expansion.
- **Custom round editor for low-wins games** — not needed for typed-score Golf/Hearts; the `RoundInput` seam is ready if a future bid-based low-wins game needs one.
- **Team roll-up** — Tier 1; `leaderIndices` is written so it can be extended to team totals later.
