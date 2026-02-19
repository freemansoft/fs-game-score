# Semantics Labels

All of the important UI elements must have semantic labels. This includes any controls like buttons and any input fields. The following widgets have semantics labels defined to support accessibility and to support web and other e2e tests.

## In Game App Bar Controls

| Widget                     | Key                         | Semantics Label                                    |
| -------------------------- | --------------------------- | -------------------------------------------------- |
| New Scorecard `IconButton` | `new_scorecard_icon_button` | `'Request Change Scorecard Type'` (`button: true`) |
| New Game `IconButton`      | `new_game_new_game_button`  | `'Request New Game Same Type'` (`button: true`)    |
| Share Game `IconButton`    | `share_button`              | `'Share Game Scores'` (`button: true`)             |

## Splash Screen Elements

| Widget                        | Key                              | Semantics Label             |
| ----------------------------- | -------------------------------- | --------------------------- |
| Num Players `DropdownButton`  | `splash_num_players_dropdown`    | `'Number of Players'`       |
| Max Rounds `DropdownButton`   | `splash_max_rounds_dropdown`     | `'Maximum Rounds'`          |
| Game Mode `DropdownButton`    | `splash_game_mode_dropdown`      | `'Game Mode'`               |
| Score Filter `DropdownButton` | `splash_score_filter_dropdown`   | `'Score Filter'`            |
| End Game Score `Checkbox`     | `splash_end_game_score_checkbox` | `'Enable End Game Score'`   |
| End Game Score `TextField`    | `splash_end_game_score_field`    | `'End Game Score'`          |
| Continue `ElevatedButton`     | `splash_continue_button`         | `'Continue to Score Table'` |

## New Game Control

The New Game control opens a dialog to confirm starting a new game.

| Widget                         | Key                             | Semantics Label                                 |
| ------------------------------ | ------------------------------- | ----------------------------------------------- |
| New Game `IconButton`          | `new_game_new_game_button`      | `'Request New Game Same Type'` (`button: true`) |
| Clear Names `CheckboxListTile` | `new_game_clear_names_checkbox` | `'Clear Player Names'`                          |
| Cancel `TextButton`            | `new_game_cancel_button`        | _(implicit from button text)_                   |
| OK / New Game `ElevatedButton` | `new_game_ok_button`            | _(implicit from button text)_                   |

## New Scorecard Control

The New Scorecard dialog is the confirmation dialog for changing the scorecard type.

| Widget                        | Key                           | Semantics Label                                            |
| ----------------------------- | ----------------------------- | ---------------------------------------------------------- |
| New Scorecard `IconButton`    | `new_scorecard_icon_button`   | `'Request Change Scorecard Type'` (`button: true`)         |
| Cancel `TextButton`           | `new_scorecard_cancel_button` | _(implicit from button text)_                              |
| Change Scorecard `TextButton` | `new_scorecard_change_button` | _(implicit from button text)_                              |
| `AlertDialog`                 | _(no key)_                    | `'New Game - Change Scorecard Type'` (via `semanticLabel`) |

## Score Table

| Widget                             | Key        | Semantics Label |
| ---------------------------------- | ---------- | --------------- |
| `DataTable2` (the table container) | _(no key)_ | `'Score Table'` |

## Score Table Header

| Widget                             | Key        | Semantics Label                                       |
| ---------------------------------- | ---------- | ----------------------------------------------------- |
| Player/Total column heading `Text` | _(no key)_ | `'Player and Total'` (via `semanticsLabel` on `Text`) |

## Score Table Column Header

| Widget                           | Key / pattern | Semantics Label         |
| -------------------------------- | ------------- | ----------------------- |
| Round column `Semantics` wrapper | _(no key)_    | `'Round {N}'` (1-based) |

## Score Table Lock Button

| Widget                   | Key / pattern | Semantics Label                     |
| ------------------------ | ------------- | ----------------------------------- |
| Lock/Unlock `IconButton` | `lock_r{N}`   | `'Round {N} lock button'` (1-based) |

## Score Table Row Header

_(No semantic label defined — the row header is the `PlayerGameCell`, documented below.)_

## Score Table Cell

_(The `PlayerRoundCell` serves as the score table cells — see below.)_

## Player Game Cell

| Widget                               | Key / pattern      | Semantics Label                                      |
| ------------------------------------ | ------------------ | ---------------------------------------------------- |
| Cell `InkWell` (`Semantics` wrapper) | `p{N}_game_cell`   | `'Player {N} name and total score'` (`button: true`) |
| Player name `Text`                   | `p{N}_name`        | `'Player name {N}'` (via `semanticsLabel`)           |
| Total score `Text`                   | `p{N}_total_score` | `'Player total score {N}'` (via `semanticsLabel`)    |

## Player Name Field

| Widget          | Key / pattern     | Semantics Label                           |
| --------------- | ----------------- | ----------------------------------------- |
| `TextFormField` | `p{N}_name_field` | `'Player Name'` (via `Semantics` wrapper) |

## Player Game Modal

| Widget        | Key / pattern     | Semantics Label                                 |
| ------------- | ----------------- | ----------------------------------------------- |
| `AlertDialog` | `p{N}_game_modal` | `'Player {N} Game Modal'` (via `semanticLabel`) |

## Player Round Cell

| Widget         | Key / pattern          | Semantics Label                                       |
| -------------- | ---------------------- | ----------------------------------------------------- |
| Cell `InkWell` | `p{N}_r{R}_round_cell` | _(no Semantics wrapper; enabled state via `onTap`)_   |
| Score `Text`   | `p{N}_r{R}_score`      | `'Player {N} round {R} score'` (via `semanticsLabel`) |
| Phase `Text`   | `p{N}_r{R}_phase`      | `'Player {N} round {R} phase'` (via `semanticsLabel`) |

## Player Round Modal

| Widget        | Key / pattern           | Semantics Label                                      |
| ------------- | ----------------------- | ---------------------------------------------------- |
| `AlertDialog` | `p{N}_r{R}_round_modal` | `'Player {N} Round {R} Modal'` (via `semanticLabel`) |

## Player Score Field

| Widget          | Key / pattern           | Semantics Label                           |
| --------------- | ----------------------- | ----------------------------------------- |
| `TextFormField` | `p{N}_r{R}_score_field` | `'Round Score'` (via `Semantics` wrapper) |

## Player Phase Dropdown

| Widget                         | Key / pattern              | Semantics Label                                                   |
| ------------------------------ | -------------------------- | ----------------------------------------------------------------- |
| `RoundPhaseDropdown` (wrapper) | `p{N}_r{R}_phase_dropdown` | `'Player {N} Round {R} Phase Selector'` (via `Semantics` wrapper) |
| `PopupMenuButton` (internal)   | `p{N}_r{R}_phase_popup`    | _(child of Semantics wrapper)_                                    |

## French Driving Round Panel

| Widget                       | Key                          | Semantics Label                            |
| ---------------------------- | ---------------------------- | ------------------------------------------ |
| Miles `TextField`            | `mb_miles_field`             | `'Miles Driven'` (via `Semantics` wrapper) |
| Safeties `DropdownButton`    | `mb_safeties_dropdown`       | `'Number of Safeties'` (`button: true`)    |
| Coup Fourré `DropdownButton` | `mb_coup_fourre_dropdown`    | `'Number of Coup Fourre'` (`button: true`) |
| Delayed Action `Checkbox`    | `mb_delayed_action_checkbox` | `'Delayed Action Bonus'`                   |
| Safe Trip `Checkbox`         | `mb_safe_trip_checkbox`      | `'Safe Trip Bonus'`                        |
| Shut Out `Checkbox`          | `mb_shut_out_checkbox`       | `'Shut Out Bonus'`                         |
