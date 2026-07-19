---
diataxis: explanation
---

# Game-mode roadmap: which games could this app score next

This document explains **which additional board and card games fs-game-score could support**, what new scoring capabilities each would require, and in what priority order they are worth building. It is a direction-setting explanation, not a how-to — for the rules of the modes that already ship, see **[Game-Modes.md](Game-Modes.md)**.

The app works best for **round-based games where a single person keeps score**. Every suggestion below stays inside that sweet spot: players enter (or the app calculates) a number per round, and totals accumulate.

## What the engine can already do

Today's scoring engine is a generic **per-round, per-player integer accumulator**:

- Fixed grid of **2–8 players × 1–20 rounds**, chosen up front on the splash screen.
- Four modes selected by one enum, `GameMode.standard | phase10 | frenchDriving | skyjo` (`lib/model/game.dart`). Mode behaviour is derived from getters on `GameConfiguration` (`numPhases`, `allowNegativeScores`, `enablePhases`) rather than per-mode classes.
- Three optional extension points bolted onto `Player`:
  - a per-round **extra attribute** — `Phases` (`lib/model/phases.dart`);
  - per-round **lock flags** — `RoundStates` (`lib/model/round_states.dart`);
  - a bespoke **calculated score** — `FrenchDrivingRoundAttributes.calculateScore()` (`lib/model/french_driving_round_attributes.dart`).
- Input validation via `lib/model/score_filters.dart` (`none`, `endsWith0or5`, `signedDigits`).
- One "reached the target" highlight: when `endGameScore > 0`, a player whose total crosses it is shown bold (`lib/presentation/player_game/player_game_cell.dart`).

**Not modeled today:** winner / low-score detection, teams or partnerships, bidding and tricks, dealer rotation, score multipliers, a dynamic (unbounded) round count, and any **board layout other than the sequential round grid** (for example fixed named categories that are each filled once, as in Yahtzee). These gaps are what the tiers below fill.

The two reusable precedents worth reusing when building new modes are the **calculated round editor** (`lib/presentation/player_round/french_driving_round_panel.dart`) and the **per-round dropdown attribute** (`round_phase_dropdown.dart`), both wired through the splash mode picker (`lib/presentation/splash_screen.dart`, `_buildGameModeField`).

## Priority tiers

### Phase 0 — generic rules abstraction (foundation)

**Status: ✅ delivered.** Implemented as `lib/model/game_rules.dart` (`GameRules` descriptor + `rulesFor(GameMode)`); see [Tier-0 rules abstraction plan](plans/2026-07-14-tier-0-rules-abstraction.md). The four existing modes behave identically (covered by the existing per-mode integration tests plus `test/game_rules_test.dart`).

Before this phase, per-mode behaviour was hard-coded as `switch` / `if` on the `GameMode` enum across the model, splash screen, and round editors. That had scaled fine to four modes, but the Tier 1–2 work multiplies the branches — bidding formulas, team grouping, and low-score-wins each fork mode behaviour in several files at once — so building those on top of the old structure would have entrenched the branching further.

Phase 0 replaced the per-mode `switch` with a **config-driven rules abstraction** so later tiers add data, not scattered conditionals. The behaviours formerly derived ad hoc on `GameConfiguration` (`numPhases`, `allowNegativeScores`, `enablePhases`) and per-mode UI selection now live in a single **rules descriptor** per mode that declares:

- the per-round **input shape** (`RoundInput.typedScore` / `calculatedFrenchDriving`) and its suggested validation filter;
- **aggregation** (`ScoreAggregation.sumPerPlayer` today; later per-team roll-up, subtractive) and **win direction** (`WinDirection.highestWins` today; `lowestWins` shipped in Tier 2 for Golf/Hearts) — kept as separate fields because they compose independently;
- the **end / win condition** (`EndCondition.reachTargetHighlight` today; loser-threshold and winner detection later);
- whether phases are collected and the suggested end-game target.

- **Unlocks:** nothing player-visible on its own — it is the substrate every tier below plugs into.
- **Touch points delivered:** new `lib/model/game_rules.dart`; `lib/model/game.dart` getters delegate to it; splash auto-config and the round editors (`lib/presentation/player_round/`) read from it. The `aggregation` / `endCondition` fields exist with a single value today as the seam Tier 1–2 extend.

Doing this first is a deliberate trade: it delays the first new game, but Tiers 1–4 then become "add a descriptor (plus any genuinely new primitive)" rather than "thread another `switch` case through the model, splash, editors, and tests."

### Tier 1 — build first

**Status: 🟡 1A delivered** — the bid/tricks calculated-score primitive ships as **Oh Hell** and **Wizard** (see [spec](specs/2026-07-18-tier-1-bidding-trick-taking.md)). Team/partnership totals (1B) remain, to unlock Spades/Euchre.

> **Known defect (D1):** a bid 0 / tricks 0 round is not recorded — the bid/tricks fields default to `0` and `TextField.onChanged` only fires on a value change, so entering `0`/`0` writes no score (the cell stays empty). A made 0-bid should score (Oh Hell 10, Wizard 20). Scheduled for [Tier 4](#tier-4--stretch-capabilities-and-deferred-fixes).

These two were chosen as the first game-facing priority because trick-taking card games are the largest untapped family of "round-based, one scorekeeper" games, and they need the same two new primitives. They are built as Phase 0 descriptors plus the new primitives each requires.

**A. Bidding / trick-taking mode.** Generalize the Phase-10 "extra attribute per round" into **bid + result → calculated round score**, reusing the French Driving calculated-score pattern. Add a new per-round attributes class (e.g. `TrickBidRoundAttributes`) plus a round editor modeled on `french_driving_round_panel.dart`, with a configurable made-vs-set / over-vs-under-bid formula per variant.

- **Unlocks:** Spades, Euchre, Wizard, Oh Hell / Up-and-Down-the-River, Pinochle, Bridge, Rook, Pitch.
- **Engine gaps:** a bid entry field; made-vs-set calculation; some variants also need bags / sandbag penalties.

**B. Team / partnership totals.** Group players into teams and total (and highlight) per team.

- **Unlocks (paired with A):** Spades, Euchre, Pinochle, Bridge, Canasta, Rook.
- **Engine gaps:** team assignment at setup (`splash_screen.dart`); team roll-up in the Total column (`player_game_cell.dart`, `lib/model/players.dart`); grouped CSV export. Live-sync payloads are structurally unaffected, but the spectator display changes.

### Tier 2 — high leverage, smaller

**Status: ✅ delivered** as `WinDirection` + `EndCondition.loserThreshold` with `Players.leaderIndices`; ships Golf and Hearts. See [spec](specs/2026-07-17-tier-2-low-score-wins.md).

**Low-score-wins + loser-threshold end condition.** Today `endGameScore` only bolds players who _reach_ it, identically in every mode. Add a per-mode flag for "lowest total wins" and for "the game ends when someone crosses the target."

- **Unlocks:** Hearts, Golf (card and sport), dominoes (Muggins / Mexican Train), Rummy scored to a penalty target.
- **Engine gaps:** winner detection / ranking (absent today); invert the highlight logic in `player_game_cell.dart`.

### Tier 3 — easy reskins (little new machinery)

**Status: ✅ partially delivered** — Rummy, Uno, Farkle, Rummikub (see [spec](specs/2026-07-18-tier-3-reskins.md)) and Golf (Tier 2) ship as descriptor presets. Boggle / Scrabble / trivia remain.

Standard / Skyjo / calculated variants that mostly need a new enum value, some labels, and a suggested target default:

- **Rummy / Gin / 500 Rummy** — Skyjo-like, target 500.
- **Uno** — target 500.
- **Farkle / 10,000** — target 10,000.
- **Golf (card game)** — Skyjo plus low-score-wins.
- **Rummikub** — negatives for tiles left in hand.
- **Boggle / Scrabble / trivia** — Standard, high-score-wins.

(Yahtzee was formerly listed here as a "French-Driving-style calculated grid." It is not a reskin — its board is a fixed set of named categories rather than sequential rounds, so it now lives in [Tier 5](#tier-5--alternative-board-layouts-a-second-axis).)

### Tier 4 — stretch capabilities and deferred fixes

New scoring shapes that go beyond the additive accumulator:

- **Subtractive / countdown** scoring — Darts 501.
- **Par / relative (±)** scoring per round — Golf (the sport), mini-golf.
- **Per-player handicap / starting offset.**
- **Dynamic (unbounded) round count** for race-to-N games — Cribbage (121), Scrabble.

Deferred defect fixes for shipped modes:

- **Defect D1 — bid/tricks 0 / 0 round not recorded** (Oh Hell, Wizard; Tier 1A). The round editor's bid and tricks fields default to `0`, and `TextField.onChanged` only fires on a value change, so entering `0`/`0` writes no score and the round cell stays empty (`---`) instead of scoring a made 0-bid (Oh Hell 10, Wizard 20). **Fix:** write the calculated round score whenever the editor confirms a calculated round, even when the inputs equal their defaults — with a decision on how an opened-but-untouched round should be treated. Found 2026-07-19 via the multi-round Oh Hell integration test.

### Tier 5 — alternative board layouts (a second axis)

Tiers 1–4 all vary the **scoring shape** on top of one fixed **board layout**: the sequential `rounds × players` grid. A distinct family of games keeps per-player columns but replaces sequential rounds with a **fixed set of named categories**, each filled **once**, where players must see at a glance which categories are still available and which are already used. That is a different _board_, not a different _formula_ — the largest new-machinery item on the roadmap, which is why it is called out as its own axis rather than a Tier-3 reskin. It is listed last for effort, not importance.

- **Unlocks:** Yahtzee (13 categories, upper-section +35 bonus, grand total) and Yahtzee-likes (_That's Pretty Clever_, _Roll Through the Ages_). Bowling (ten frames with strike/spare carry-forward) is a related fixed-row board with a custom running total; Wizard / Oh Hell's **bid-vs-made two-value cell** is a related primitive but stays on the round grid (built under [Tier 1](#tier-1--build-first)).
- **Engine gaps:** a **category-board layout** alongside the round grid — fixed named rows, per-cell **used / available** state, and calculated **section subtotals / bonuses**; a new board widget distinct from the score table (`lib/presentation/player_game/`); splash setup that picks a category set instead of a round count (`splash_screen.dart`). The seam is a **board-layout descriptor on `GameRules`**, mirroring how the `aggregation` / `endCondition` fields were reserved for Tiers 1–2.

## Architectural note

Before [Phase 0](#phase-0--generic-rules-abstraction-foundation), adding a mode meant a new `GameMode` enum value plus per-mode behaviour hard-coded as `switch` / `if` on the enum across `GameConfiguration` getters, the splash screen, and the round editors. That scaled fine to four modes but would have compounded with each new tier.

Phase 0 introduced the **generic rules abstraction** (`lib/model/game_rules.dart`) ahead of the game-facing tiers, so a mode's behaviour is now declared once in a `GameRules` descriptor. Adding a game still needs its genuinely new primitives — a bid attributes class, a round-editor panel, team grouping, l10n keys, and tests — but it plugs those into the descriptor rather than threading another `switch` case through the model, splash, editors, and tests. First-class team grouping and win/aggregation variants are the descriptor fields (`aggregation`, `endCondition`) that Tiers 1–2 fill in, and the [Tier-5](#tier-5--alternative-board-layouts-a-second-axis) category board is a further descriptor field — a **board layout** — rather than a fork of the score table.
