# Game modes to support special scoring rules for different games in this application.

The game mode is selected on the splash screen. You can end a game and start a new game with a different game mode using the "New Game" icon in the app bar.

## Overview

This app supports the special scoring rules as a general purpose score sheet, for Phase-10 the card game for French Driving. The game mode is selected on the splash screen. The game sheet and editing panels change based on the game mode

Player names can be edited by clicking on the name cell in the scoring table. The name can be changed in the modal editing panel that appears.

Scores or rounds state is edited by clicking on the cell representing the round for the player. This will open a modal editing panel for that round. The modal editing panel will close when the user clicks anywhere outside of the panel border.

## General Scoring

This mode supports round base scoring an player total calculation on per round basis. The round score is displayed in the cell representing the round for the player. Total scores and player names are displayed in the "Total" column. The total column is the calculated sum of the per rounds scores.

An end-game condition can be specified that will cause the game to highlght any players that reach the "end game" score. The end game condition is specified as a number of points.

### General Scoring: Editing Per Round Scores

- Click on a score cell in the scoring table to edit the score.
- The score can be changed in the modal editing panel that appears. The panel will show the _player name_, _round number_, and _round score_ for the selected round.
- You can edit the _round score_ in the field.
- Close the editing panel by clicking anywhere outside of the panel border.

### General Scoring internal model

The internal model is a list of Players. Each Player has

- A Scores object that contains a list containing the _round score_ for each round
- A RoundScores object that contains a list of per round lock flags that block editing of scores for that round. Locking is used to prevent accidental changes to the round scores.

## Phase 10 Scoring

This mode supports round base scoring an player total calculation on per round basis. The round score and any phase completed in that round is displayed in the cell representing the round for the player. Total scores and player names are displayed in the "Total" column. The total column is the calculated sum of the per rounds scores.

Phase-10 also supports the collection of completed phases and the display of the total score for each player. Total scores and player names are displayed in the "Total" column. You can click on a player in the total column to see which phases have been completed in a popup modal. Phase-10 rounds scores all end in 0 or 5 and a filter can be applied on the splash screen to only allow entry of rounds that end in 0 or 5.

## Phase 10: Editing Per Round Scores

- Click on a score cell in the scoring table to edit the score. The score can be changed in the modal editing panel that appears.
- The panel will show the _player name_, _round number_, and _round score_ and the _phase completed_ for the selected round.
  You can edit the _round score_ in the field and change the _phase completed_ in the dropdown.
- Close the editing panel by clicking anywhere outside of the panel border.

### Phase Scoring internal model

The internal model is a list of Players. Each Player has

- A Scores object that contains a list containing the _round score_ for each round
- A Phases object that contains alist of _phases_ that represents the completed phases for that player in specific rounds.
- A RoundScores object that contains a list of per round lock flags that block editing of scores for that round. Locking is used to prevent accidental changes to the round scores.

## French Driving

This program supports the special scoring rules for French Driving when configured in French Driving mode on the splash screen.

### French Driving Scoring

The per round score is calculated by applying the following rules to the attributes of the round. The score for a given round is displayed in the cell representing the round for the player. You can only see the composite category scores that made up the cell score by clicking on the cell. The score is totaled at the end of each hand, whether or not a trip of 1000 miles was completed, as follows:

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

### French Driving Score Editing

- Click on a score cell in the scoring table to edit the score. The score can be changed in the modal editing panel that appears.
- The panel will show the following used to score the round
  - _player name_, _round number_, and _round score as miles traveled_
  - the 4 safety cards along with checkboxes to indicate if they were played and checkboxes to indicate if they were coup fourré
  - check box for delayed action
  - check box for safe trip
  - check box for shut out
- You can edit the _round score_ in the field.
- Close the editing panel by clicking anywhere outside of the panel border.

### French Driving Scoring internal model

The internal model is a list of Players. Each Player has

- A Scores object that contains a list containing the _round score_ for each round
- A FrenchDrivingRoundAttributes object that contains a list of French Driving round attribute objects that hold the 8 attributes of the round used to calculate the score
- A RoundScores object that contains a list of per round lock flags that block editing of scores for that round. Locking is used to prevent accidental changes to the round scores.

## Developer Notes

This section is developer notes for developer and Agent based programming.

### Internationalization

This application supports multiple languages. The language is selected based on the device language. All user displayed text and labels are internationalized and can be found in the `lib/l10n` directory. The application will display the text in the selected language. If the selected language is not supported, the application will display the text in the default language, which is English.

### Automated tests

All major functional areas of the application are supported by automated tests. Full featured integration tests should exist for each game mode. Unit tests should exist for all data models and business logic.
