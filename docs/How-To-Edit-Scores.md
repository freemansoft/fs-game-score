---
diataxis: how-to
---

# How to edit names and scores

Task steps for editing a scorecard during play. For what each game mode scores and its data model, see [Game-Modes.md](Game-Modes.md).

All editing happens in a **modal panel** that opens when you tap a cell and closes when you tap anywhere outside its border.

## Edit a player name

1. Tap the player's **name cell** in the scoring table.
2. Change the name in the modal editing panel.
3. Tap outside the panel to close it.

## Edit a round score (Standard and Skyjo modes)

1. Tap the **score cell** for that player and round.
2. The panel shows the _player name_, _round number_, and _round score_. The _round score_ field has focus.
3. Enter the _round score_ — a numeric field. Standard accepts positive numbers; **Skyjo** also accepts negative round scores.
4. Tap outside the panel to close it.

## Edit a round score (Phase 10 mode)

1. Tap the **score cell** for that player and round.
2. The panel shows the _player name_, _round number_, _round score_, and _phase completed_. The _round score_ field has focus.
3. Enter the _round score_ — entry must end in **0 or 5**.
4. Choose the _phase completed_ from the dropdown.
5. Tap outside the panel to close it.

To review which phases a player has completed, tap the player in the **Total** column to open the phases popup.

## Edit a round (French Driving mode)

The round score is **calculated** from the attributes you enter — you cannot type the score directly.

1. Tap the **score cell** for that player and round.
2. The panel shows non-editable _player name_, _round number_, and aggregated _round score_, plus the scoring inputs. The _miles traveled_ field has focus.
3. Fill in the attributes:
   - _Miles traveled_ — positive integer.
   - _Safeties played_ — dropdown, 0–4.
   - _Coup Fourré played_ — dropdown, 0–4.
   - _Delayed action_ — checkbox.
   - _Safe trip_ — checkbox.
   - _Shut out_ — checkbox.
4. Tap outside the panel to close it; the round score recalculates.

For the point values each attribute contributes, see [Game-Modes.md — French Driving Scoring](Game-Modes.md#french-driving-scoring).

## Input validation

Fields validate input and surface errors either as `errorText` on the field or as a SnackBar message.
