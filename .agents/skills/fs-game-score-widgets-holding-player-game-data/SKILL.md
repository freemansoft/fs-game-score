---
name: fs-game-score-widgets-holding-player-game-data
description: >
  Widget keys, semantics, and modal layout rules for player/round UI in this app.
  Use when editing score table cells, modals, or configuration screens.
---

# Widget and layout behavior

## modal alert behavior

- The content area of modal alerts AlertDialog should change the layout based on orientation if there are only 2 to 3 fields or dropdowns or pickers in the alert panel
- The close button is not required for alert panels
- AlertDialog should be set with scrollable: true
- AlertDialog should have a key set where the ValueKey includes '_model' and the player or round number if appropriate

## Widget key behaviors

- Flutter widgets containing player or game data must have well formatted "key" properties using the ValueKey and some string
- Widget "key" properties for widgets showing a specific player's info should include specify the player number with 'p' followed by the index of the player in the player collection. The 'p' section should be at the start of the key string.
- Widget "key" properties for widgets showing a specific round's info should include the round number with 'r' followed by the index of the round. The 'r' section should follow the 'p0' section if if it exists else the 'r' section should be at the start of the key string.
- Files containing widgets with custom keys should define the ValueKey in static functions.  The function should accept player number or round number if appropriate.
- Tests involving those keys should use the key functions and not define the ValueKey objects using static strings

- Fields in global modal panels should have specific keys set
- Fields in modal panels tied to players or rounds should have repeatable keys that include the player number and/or round number

## Widget semantics

- Widgets holding player game data should be directly wrapped with semantics or use the semanticlabels on the widgets if available.
- Widgets on the configuraiton screens should be direclty wrapped with semantics if the widget does not have a semanticlabel property
