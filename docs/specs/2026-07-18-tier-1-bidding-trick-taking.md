# Tier-1 A — bidding/trick-taking (Oh Hell + Wizard) — design and decisions

Adds the **bid + tricks → calculated round score** primitive (Tier 1A of the [Game-Modes-Roadmap](../Game-Modes-Roadmap.md)) and ships two per-player trick-taking games: **Oh Hell** and **Wizard**. No teams/partnerships — that is Tier 1B, a separate slice.

The primitive reuses the French Driving calculated-score pattern: a per-round attributes object stores the inputs, a formula derives the round score, and the derived score is written into the regular `Scores` so the Total column works unchanged. For that pattern see `lib/model/french_driving_round_attributes.dart`, `lib/provider/players_provider.dart` (`updateFrenchDrivingAttributes`), and `lib/presentation/player_round/french_driving_round_panel.dart`.

---

## Overview

| Aspect         | Selection                                                                                                   |
| -------------- | ----------------------------------------------------------------------------------------------------------- |
| Scope          | **Two per-player modes** — Oh Hell and Wizard — plus the shared bid/tricks calculated-score primitive       |
| New capability | **Bid + tricks taken → calculated round score** (a new round-editor panel and formula)                      |
| Teams          | **Out of scope** — Tier 1B; these two games need no partnerships                                            |
| Formula seam   | **Two new `RoundInput` values** (`calculatedOhHell`, `calculatedWizard`) select the panel and the formula   |
| Wire format    | **Additive** — a new optional `bidTricksAttributes` key on `Player.toJson`; **not breaking**, no major bump |
| Out of scope   | Teams, bags/sandbag penalties, nil bids, per-mode default round counts beyond the standard range            |

---

## Selected decisions (summary)

| Decision          | Selected                                                          | Rationale                                                                                                                           |
| ----------------- | ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Formula placement | **Two new `RoundInput` values**, not a new descriptor field       | French Driving already treats `RoundInput.calculatedFrenchDriving` as editor+formula; reuse that seam. No touching all descriptors. |
| Score storage     | **Derived score written into `Scores`** (as French Driving does)  | The Total column and persistence stay unchanged; attributes are kept only for re-editing.                                           |
| Oh Hell formula   | exact bid → `10 + bid`; miss (over or under) → `0`                | Common Oh Hell scoring.                                                                                                             |
| Wizard formula    | exact → `20 + 10 × bid`; miss → `-10 × abs(bid - tricksTaken)`    | Standard Wizard scoring; negatives allowed.                                                                                         |
| Wire change       | **Additive optional key**, `Player.fromJson` defaults it to empty | Non-breaking per the live-share rule; no major bump.                                                                                |
| Version impact    | **Minor** (stays in `2.1.0 - not yet released`)                   | New modes + additive wire key.                                                                                                      |

---

## Model changes

### `lib/model/bid_tricks_round_attributes.dart` (new)

```dart
class BidTricksRoundAttributes {
  BidTricksRoundAttributes({this.bid = 0, this.tricksTaken = 0});
  factory BidTricksRoundAttributes.fromJson(Map<String, dynamic> json) => ...;
  final int bid;
  final int tricksTaken;
  Map<String, dynamic> toJson() => {'bid': bid, 'tricksTaken': tricksTaken};
  BidTricksRoundAttributes copyWith({int? bid, int? tricksTaken}) => ...;
}

/// Pure formula, keyed by the descriptor's [RoundInput]. Unit-testable.
int bidTricksScore(RoundInput input, {required int bid, required int tricksTaken}) {
  final exact = bid == tricksTaken;
  return switch (input) {
    RoundInput.calculatedOhHell => exact ? 10 + bid : 0,
    RoundInput.calculatedWizard => exact ? 20 + 10 * bid : -10 * (bid - tricksTaken).abs(),
    _ => 0,
  };
}
```

### `lib/model/game_rules.dart`

- `RoundInput` gains `calculatedOhHell` and `calculatedWizard`.
- Two new `GameMode` values appended: `ohHell`, `wizard` (never reorder — `toString()` is the persisted/wire key).
- Descriptors (typed fields as usual, `roundOptions: _standardRoundOptions`, `suggestedMaxRounds: _standardSuggestedMaxRounds`, `winDirection: highestWins`, `endCondition: reachTargetHighlight`, `aggregation: sumPerPlayer`, `suggestedEndGameScore: 0`, `enablePhases: false`, `numPhases: 0`):

| Mode       | roundInput         | allowNegativeScores | suggestedScoreFilter |
| ---------- | ------------------ | ------------------- | -------------------- |
| **ohHell** | `calculatedOhHell` | false               | `ScoreFilters.none`  |
| **wizard** | `calculatedWizard` | true                | `ScoreFilters.none`  |

### `lib/model/player.dart`

- Add a serialized `List<BidTricksRoundAttributes> bidTricksAttributes` (one per round), mirroring `frenchDrivingAttributes`: constructed as `List.generate(maxRounds, ...)`, round-tripped in `toJson`/`fromJson`/`copyWith`.
- **`fromJson` defaults it to empty/generated when the key is absent** — this is what makes the added wire key non-breaking.

### `lib/provider/players_provider.dart`

- `updateBidTricksAttributes(int playerIdx, int round, BidTricksRoundAttributes attributes)` — mirrors `updateFrenchDrivingAttributes`: set `player.bidTricksAttributes[round] = attributes`, then `player.scores.setScore(round, bidTricksScore(rules.roundInput, bid: ..., tricksTaken: ...))`, then persist.

---

## UI changes

### `lib/presentation/player_round/bid_tricks_round_panel.dart` (new)

A small editor modeled on `FrenchDrivingRoundPanel`: a **bid** field and a **tricks taken** field, each emitting an updated `BidTricksRoundAttributes` via `onChanged`. Static keys for tests (`bidFieldKey`, `tricksFieldKey`).

### `lib/presentation/player_round/player_round_modal.dart`

Show `BidTricksRoundPanel` when `rules.roundInput` is `calculatedOhHell` or `calculatedWizard` (parallel to the existing `calculatedFrenchDriving` branch); the typed score field is read-only for these modes (calculated).

### Score table wiring

Thread an `onBidTricksAttributesChanged` callback through `score_table.dart` → `PlayerRoundCell` → the modal, parallel to `onFrenchDrivingAttributesChanged`. The round cell displays the calculated score (from `Scores`), as French Driving does.

---

## Localization (`lib/l10n/app_*.arb`)

- Mode names: `gameModeOhHell` ("Oh Hell"), `gameModeWizard` ("Wizard") — untranslated brand/game names across en/es/fr, like `gameModeSkyjo`.
- Panel labels (localized, incl. any semantics labels): `bidLabel` ("Bid"), `tricksTakenLabel` ("Tricks taken"). Follow the semantics-label localization rule.

---

## Wire compatibility (checked per the live-share rule)

The shared snapshot serializes `GameConfiguration.toJson()` and `Player.toJson()`. This slice:

- Adds new **values** to the `gameMode` string (`ohHell`, `wizard`) — additive.
- Adds one new **optional key** `bidTricksAttributes` to `Player.toJson`.

An added optional key that older readers ignore and newer readers default (via `Player.fromJson`) is **non-breaking within a major** — and the same-major connection gate holds regardless. **Not a breaking change; no major version bump.** See the `fs-game-score-live-sync` skill (Wire compatibility and versioning).

---

## Documentation (per the game-change doc rule)

- **README.md** — two rows in the "Scoreboards and game types" table.
- **CHANGELOG.md** — one bullet under `## [2.1.0] - not yet released`.
- **docs/Game-Modes.md** — supported-modes list + a per-mode section each (with the scoring formula).
- **docs/Game-Modes-Roadmap.md** — mark Tier 1A delivered (Tier 1B / teams still pending).

---

## Testing

| Layer                                                 | Coverage                                                                                                                                                                             |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `test/bid_tricks_score_test.dart` (new)               | `bidTricksScore`: Oh Hell exact vs miss; Wizard exact, over-bid, under-bid (negative); non-bid `RoundInput` returns 0.                                                               |
| `test/bid_tricks_serialization_test.dart` (new)       | `BidTricksRoundAttributes` round-trips; `Player.fromJson` defaults `bidTricksAttributes` when the key is absent (wire back-compat).                                                  |
| `test/game_rules_test.dart`                           | Oh Hell / Wizard descriptors expose the expected `roundInput` and negatives.                                                                                                         |
| Widget (`test/bid_tricks_round_panel_test.dart`, new) | Entering bid + tricks emits updated attributes.                                                                                                                                      |
| `test/splash_game_mode_test.dart`                     | The picker offers Oh Hell and Wizard.                                                                                                                                                |
| Integration (`integration_test/app_test.dart`)        | **Lean, one per mode**: select the mode → open the round editor → enter a bid + tricks → the round cell and total show the calculated score (Oh Hell exact; Wizard a negative miss). |

---

## Out of scope (YAGNI)

- **Teams / partnerships** — Tier 1B; unlocks Spades/Euchre later.
- **Bags / sandbag penalties, nil bids** — Spades-specific; not needed for Oh Hell/Wizard.
- **Configurable formula per variant beyond these two** — each game is one `RoundInput` value; add more when a third bid game arrives.
- **Per-mode round-count presets** — use the standard `1..20` range and suggested 14.
