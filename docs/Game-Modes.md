---
diataxis: reference
---

# Game modes and special scoring rules

Reference for the scoring rules and internal data model of each game mode. For the step-by-step of editing names and scores in the app, see **[How-To-Edit-Scores.md](How-To-Edit-Scores.md)**.

The game mode is selected on the splash screen; the scoring filter is set automatically from the mode. A game can be ended and restarted in a different mode via the **New Game** icon in the app bar. The score sheet and editing panels change based on the active mode.

## Supported modes

- General (Standard) Scoring
- Phase 10 Scoring
- French Driving Scoring
- Skyjo

The game sheet displays each player's per-round score in the round cell and a calculated **Total** column (sum of round scores). Player names appear in the Total column.

## Standard Mode

Round-based scoring with per-round player totals. An optional **end-game condition** (a point value) highlights any player that reaches the end-game score.

### Standard Mode internal model

Each `Player` has:

- A `Scores` object — the _round score_ for each round.
- A `RoundStates` object — per-round lock flags that block editing of a round's scores (prevents accidental changes).

## Skyjo Mode

Identical to Standard Mode plus:

- Negative round scores are allowed.
- Selecting Skyjo on the splash screen auto-selects the end-score checkbox and sets the end score to **100**.

## Phase 10 Mode

Round-based scoring plus collection of completed **phases**. Each round cell shows the round score and any phase completed that round. Round scores all end in **0 or 5**; a splash-screen filter can restrict entry to values ending in 0 or 5. Tapping a player in the Total column shows which phases they have completed.

### Phase 10 internal model

Each `Player` has:

- A `Scores` object — the _round score_ for each round.
- A `Phases` object — the _phases_ completed by that player in specific rounds.
- A `RoundStates` object — per-round lock flags (as Standard Mode).

## French Driving Mode

Special scoring rules for French Driving. Selecting the mode on the splash screen auto-selects the end-score checkbox and sets the end score to **5000**. The round score is **calculated** from the round's attributes and shown in the round cell; the composite category scores are visible by opening the cell.

### French Driving Scoring

The score is totaled at the end of each hand, whether or not a 1000-mile trip was completed:

| Event                                   | Notes                                                                               | Points         |
| --------------------------------------- | ----------------------------------------------------------------------------------- | -------------- |
| Miles Traveled                          | Each team scores as many points as the total number of miles that it has traveled.  | Miles Traveled |
| Each Safety Card played                 | -                                                                                   | 100            |
| Additional Safety Card bonus            | If all four Safety Cards are played by the same team.                               | 300            |
| Each Coup Fourré                        | Note: this score is in addition to the 100 points scored for playing a Safety Card. | 300            |
| Bonus for completing trip of 1000 miles |                                                                                     | 400            |
| Delayed Action bonus                    | If trip is completed after all cards have been played from the draw pile            | 300            |
| Safe Trip bonus                         | If trip is completed without playing any 200 Mile Cards                             | 300            |
| Shut Out bonus                          | Completing trip of 1000 miles before opponents have played any Distance Cards       | 500            |

### French Driving internal model

Each `Player` has:

- A `Scores` object — the _round score_ for each round.
- A `FrenchDrivingRoundAttributes` list — the 8 per-round attributes used to calculate the score.
- A `RoundStates` object — per-round lock flags (as Standard Mode).

## System facts for developers

- **Internationalization:** All user-displayed text and labels are internationalized under `lib/l10n`. The app follows the device language and falls back to English when the selected language is unsupported. See the `fs-game-score-flutter-patterns` skill for the l10n workflow.
- **Automated tests:** Each game mode has full integration test coverage; data models and business logic have unit tests. See the `fs-game-score-testing-workflow` skill.
- **Input validation:** Fields validate input and show an error via `errorText` or a SnackBar. Editing procedures are in [How-To-Edit-Scores.md](How-To-Edit-Scores.md).
