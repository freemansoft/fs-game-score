---
name: fs-game-score-widgets-holding-player-game-data
description: >
  Widget keys, semantics, and modal layout rules for player/round UI in this app.
  Use when editing score table cells, modals, splash configuration, or form fields.
---

# FS Score Card — Widget keys, semantics, and modals

Rules for widgets that display player or game data. Tests must use the **static key functions** below — never duplicate key strings.

---

## Widget key conventions

- Use **`ValueKey<String>`** via static functions on the widget class (or modal).
- **Player index** prefix: `p` + index at the **start** (e.g. `p0_name`).
- **Round index** suffix: `r` + index after player prefix (e.g. `p0_r2_score_field`).
- Modal/global panel fields need repeatable keys including player and/or round when applicable.

The tables below are a snapshot — the listed source files are the truth; verify there before relying on a pattern, and update these tables when keys change.

### Player game column (`lib/presentation/player_game/`)

| Function                          | Key pattern        | File                     |
| --------------------------------- | ------------------ | ------------------------ |
| `PlayerGameCell.cellKey(i)`       | `p{i}_game_cell`   | `player_game_cell.dart`  |
| `PlayerGameCell.nameKey(i)`       | `p{i}_name`        | `player_game_cell.dart`  |
| `PlayerGameCell.totalScoreKey(i)` | `p{i}_total_score` | `player_game_cell.dart`  |
| `PlayerGameModal.modalKey(i)`     | `p{i}_game_modal`  | `player_game_modal.dart` |
| `PlayerGameModal.nameFieldKey(i)` | `p{i}_name_field`  | `player_game_modal.dart` |

### Player round cells and modals (`lib/presentation/player_round/`)

| Function                                  | Key pattern                | File                        |
| ----------------------------------------- | -------------------------- | --------------------------- |
| `PlayerRoundCell.cellKey(i, r)`           | `p{i}_r{r}_cell`           | `player_round_cell.dart`    |
| `PlayerRoundCell.roundCellKey(i, r)`      | `p{i}_r{r}_round_cell`     | `player_round_cell.dart`    |
| `PlayerRoundCell.scoreKey(i, r)`          | `p{i}_r{r}_score`          | `player_round_cell.dart`    |
| `PlayerRoundCell.phaseKey(i, r)`          | `p{i}_r{r}_phase`          | `player_round_cell.dart`    |
| `PlayerRoundModal.modalKey(i, r)`         | `p{i}_r{r}_round_modal`    | `player_round_modal.dart`   |
| `PlayerRoundModal.scoreFieldKey(i, r)`    | `p{i}_r{r}_score_field`    | `player_round_modal.dart`   |
| `PlayerRoundModal.phaseDropdownKey(i, r)` | `p{i}_r{r}_phase_dropdown` | `player_round_modal.dart`   |
| `RoundPhaseDropdown.popupButtonKey(i, r)` | (round phase UI)           | `round_phase_dropdown.dart` |

### Score table and splash

| Function                                                            | File                                             |
| ------------------------------------------------------------------- | ------------------------------------------------ |
| `ScoreTable.lockRoundKey(round)`                                    | `score_table.dart`                               |
| `SplashScreen.continueButtonKey`, `numPlayersDropdownKey`, etc.     | `splash_screen.dart` — `const ValueKey` on class |
| `NewGameControl.cancelButtonKey`, `okButtonKey`, `newGameButtonKey` | `new_game_control.dart`                          |

### Tests

```dart
// Correct
find.byKey(PlayerRoundModal.scoreFieldKey(0, 2));

// Wrong — do not hardcode strings in tests
find.byKey(const ValueKey('p0_r2_score_field'));
```

---

## Modal `AlertDialog` behavior

Applies to player/round editors and similar panels with **2–3 fields, dropdowns, or pickers**:

- Set **`scrollable: true`** on `AlertDialog`.
- **Layout by orientation:** use `MediaQuery.of(context).orientation` — e.g. `Row` in landscape, `Column` in portrait (`PlayerRoundModal`, `PlayerGameModal`, `FrenchDrivingRoundPanel`).
- Set dialog **`key`** via the modal static function (e.g. `PlayerRoundModal.modalKey(playerIdx, round)`).
- **Close button is optional** — not required on every alert.
- Avoid nesting widgets that break **intrinsic dimensions** inside scrollable dialogs (see comment in `live_share_control.dart` for QR in dialog).

Reference implementations: `player_round_modal.dart`, `player_game_modal.dart`.

---

## Semantics

- Widgets holding **player/game data** must expose **`semanticLabel`** or be wrapped in **`Semantics`**.
- **Configuration screens** (splash): wrap controls in `Semantics` when the widget has no `semanticLabel` property.
- Semantic labels are screen-reader text and **must be localized** — use a `*Label`-suffixed key (e.g. `playerGameModalLabel`) with runtime values as placeholders. The rule and its rationale are canonical in **`fs-game-score-flutter-patterns` → Localization**; follow it there rather than relying on this summary.
- All user-visible strings — titles, tooltips, field labels, and semantics labels — **must** use `AppLocalizations`.

Example (`PlayerRoundModal`):

```dart
AlertDialog(
  key: PlayerRoundModal.modalKey(widget.playerIdx, widget.round),
  semanticLabel: AppLocalizations.of(context)!
      .playerGameModalLabel(widget.playerIdx + 1),
  scrollable: true,
  // ...
)
```

---

## Read-only / spectator mode

`PlayerGameCell` and `PlayerRoundCell` accept **`readOnly: true`** — disable taps when spectating live scores. Do not wire spectator edits to host notifiers.
