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

**Not modeled today:** winner / low-score detection, teams or partnerships, bidding and tricks, dealer rotation, score multipliers, and a dynamic (unbounded) round count. These gaps are what the tiers below fill.

The two reusable precedents worth reusing when building new modes are the **calculated round editor** (`lib/presentation/player_round/french_driving_round_panel.dart`) and the **per-round dropdown attribute** (`round_phase_dropdown.dart`), both wired through the splash mode picker (`lib/presentation/splash_screen.dart`, `_buildGameModeField`).

## Priority tiers

### Phase 0 — generic rules abstraction (foundation, do first)

Everything below is currently implemented as hard-coded `switch` / `if` on the `GameMode` enum (see [Architectural note](#architectural-note)). That has scaled fine to four modes, but the Tier 1–2 work multiplies the branches — bidding formulas, team grouping, and low-score-wins each fork mode behaviour in several files at once. Building those on top of the current structure would entrench the branching further.

Phase 0 replaces the per-mode `switch` with a **config-driven rules abstraction** so later tiers add data, not scattered conditionals. Concretely, lift the behaviours today derived ad hoc on `GameConfiguration` (`numPhases`, `allowNegativeScores`, `enablePhases`) and per-mode UI selection into a single **rules descriptor** per mode that declares:

- the per-round **input shape** (typed score, calculated attributes, extra dropdown) and its validation filter;
- **aggregation** (sum, and later per-team roll-up, low-vs-high, subtractive);
- the **end / win condition** (reach-target highlight today; loser-threshold and winner detection later);
- which **round editor** to render.

- **Unlocks:** nothing player-visible on its own — it is the substrate every tier below plugs into. The four existing modes are re-expressed as descriptors with identical behaviour (regression-covered by the existing per-mode integration tests).
- **Engine gaps / touch points:** `lib/model/game.dart` (mode getters → descriptor), `lib/model/score_filters.dart`, the round-editor selection in `lib/presentation/player_round/`, and the total/highlight logic in `lib/presentation/player_game/player_game_cell.dart`.

Doing this first is a deliberate trade: it delays the first new game, but Tiers 1–4 then become "add a descriptor (plus any genuinely new primitive)" rather than "thread another `switch` case through the model, splash, editors, and tests."

### Tier 1 — build first

These two were chosen as the first game-facing priority because trick-taking card games are the largest untapped family of "round-based, one scorekeeper" games, and they need the same two new primitives. They are built as Phase 0 descriptors plus the new primitives each requires.

**A. Bidding / trick-taking mode.** Generalize the Phase-10 "extra attribute per round" into **bid + result → calculated round score**, reusing the French Driving calculated-score pattern. Add a new per-round attributes class (e.g. `TrickBidRoundAttributes`) plus a round editor modeled on `french_driving_round_panel.dart`, with a configurable made-vs-set / over-vs-under-bid formula per variant.

- **Unlocks:** Spades, Euchre, Wizard, Oh Hell / Up-and-Down-the-River, Pinochle, Bridge, Rook, Pitch.
- **Engine gaps:** a bid entry field; made-vs-set calculation; some variants also need bags / sandbag penalties.

**B. Team / partnership totals.** Group players into teams and total (and highlight) per team.

- **Unlocks (paired with A):** Spades, Euchre, Pinochle, Bridge, Canasta, Rook.
- **Engine gaps:** team assignment at setup (`splash_screen.dart`); team roll-up in the Total column (`player_game_cell.dart`, `lib/model/players.dart`); grouped CSV export. Live-sync payloads are structurally unaffected, but the spectator display changes.

### Tier 2 — high leverage, smaller

**Low-score-wins + loser-threshold end condition.** Today `endGameScore` only bolds players who *reach* it, identically in every mode. Add a per-mode flag for "lowest total wins" and for "the game ends when someone crosses the target."

- **Unlocks:** Hearts, Golf (card and sport), dominoes (Muggins / Mexican Train), Rummy scored to a penalty target.
- **Engine gaps:** winner detection / ranking (absent today); invert the highlight logic in `player_game_cell.dart`.

### Tier 3 — easy reskins (little new machinery)

Standard / Skyjo / calculated variants that mostly need a new enum value, some labels, and a suggested target default:

- **Rummy / Gin / 500 Rummy** — Skyjo-like, target 500.
- **Uno** — target 500.
- **Farkle / 10,000** — target 10,000.
- **Golf (card game)** — Skyjo plus low-score-wins.
- **Rummikub** — negatives for tiles left in hand.
- **Yahtzee** — fixed named categories with a section bonus, scored as a French-Driving-style calculated grid.
- **Boggle / Scrabble / trivia** — Standard, high-score-wins.

### Tier 4 — stretch capabilities

New scoring shapes that go beyond the additive accumulator:

- **Subtractive / countdown** scoring — Darts 501.
- **Par / relative (±)** scoring per round — Golf (the sport), mini-golf.
- **Per-player handicap / starting offset.**
- **Dynamic (unbounded) round count** for race-to-N games — Cribbage (121), Scrabble.

## Architectural note

Adding a mode today means: a new `GameMode` enum value, `GameConfiguration` getters, an optional per-round attributes class, a per-mode round-editor panel, splash-screen wiring, l10n keys, and integration tests — all hard-coded as `switch` / `if` on the enum. That has scaled fine to four modes.

The **generic rules abstraction** — a config-driven scoring formula and first-class team grouping — is what [Phase 0](#phase-0--generic-rules-abstraction-foundation-do-first) introduces, ahead of the game-facing tiers, so that later modes add a descriptor rather than another `switch` case. The trade-off is that it delays the first new game to pay down structure first; the payoff is that bidding-plus-teams (Tier 1) and every tier after it land as data on the abstraction instead of new branches across the model, splash, editors, and tests.
