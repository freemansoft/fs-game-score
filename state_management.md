# State Management Documentation

## Overview

This application uses **Riverpod 3** as its state management solution. Riverpod was chosen for its excellent integration with Flutter, compile-time safety, and powerful reactive programming capabilities. The architecture follows Riverpod 3's modern patterns using `Notifier` and `NotifierProvider` for state management.

### Core Concepts

- **Notifier**: A class that extends `Notifier<T>` and manages state of type `T`
- **NotifierProvider**: Declares a provider that creates and manages a `Notifier` instance
- **ref.watch()**: Subscribes to state changes and rebuilds widgets when state updates
- **ref.read()**: Reads current state or triggers actions without subscribing to updates

## Provider Architecture

The application uses three main providers to manage different aspects of state:

### GameProvider

**Location**: `lib/provider/game_provider.dart`

The `GameProvider` manages global game configuration and settings:

```dart
final gameProvider = NotifierProvider<GameNotifier, Game>(() => GameNotifier());

class GameNotifier extends Notifier<Game> {
  @override
  Game build() => const Game();

  void setNumPlayers(int numPlayers) {
    state = state.copyWith(numPlayers: numPlayers);
  }

  void setMaxRounds(int maxRounds) {
    state = state.copyWith(maxRounds: maxRounds);
  }

  void newGame({int? maxRounds, int? numPhases, int? numPlayers, bool? enablePhases}) {
    state = Game(
      maxRounds: maxRounds ?? state.maxRounds,
      numPhases: numPhases ?? state.numPhases,
      numPlayers: numPlayers ?? state.numPlayers,
      enablePhases: enablePhases ?? state.enablePhases,
    );
  }
}
```

**State Managed**:

- `numPlayers`: Number of players in the game (2-8)
- `maxRounds`: Maximum number of rounds (1-20)
- `numPhases`: Number of phases (default: 10)
- `enablePhases`: Whether to show phase tracking
- `scoreFilter`: Regex pattern for valid scores
- `version`: Application version string

### PlayersProvider

**Location**: `lib/provider/players_provider.dart`

The `PlayersProvider` manages all player data and depends on `GameProvider`:

```dart
final playersProvider = NotifierProvider<PlayersNotifier, Players>(() => PlayersNotifier());

class PlayersNotifier extends Notifier<Players> {
  @override
  Players build() {
    final game = ref.watch(gameProvider);
    return Players(
      numPlayers: game.numPlayers,
      maxRounds: game.maxRounds,
      numPhases: game.numPhases,
    );
  }

  void updateScore(int playerIdx, int round, int? score) {
    final player = state.players[playerIdx];
    player.scores.setScore(round, score);
    state = state.withPlayer(player, playerIdx);
  }

  void toggleRoundEnabled(int round, bool enabled) {
    var newState = state;
    for (int i = 0; i < state.length; i++) {
      final player = state.players[i];
      player.scores.setEnabled(round, enabled);
      player.phases.setEnabled(round, enabled);
      newState = newState.withPlayer(player, i);
    }
    state = newState;
  }
}
```

**State Managed**:

- Player names and data
- Individual round scores for each player
- Phase completion status
- Round enable/disable state (column locking)
- Automatic total score calculation

**Key Feature**: The `build()` method watches `gameProvider`, ensuring that when game configuration changes, the players are automatically recreated with the correct dimensions.

### ThemeProvider

**Location**: `lib/presentation/in_game_app_bar.dart`

The `ThemeProvider` manages UI theme state:

```dart
final themeProvider = NotifierProvider<ThemeNotifier, bool>(() => ThemeNotifier());

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setTheme(bool isDark) {
    state = isDark;
  }
}
```

**State Managed**:

- Light/dark mode toggle (boolean)

## State Management Patterns

### Cross-Game State Persistence

The application persists game configuration across sessions using `SharedPreferences`:

**SplashScreen State Loading** (`lib/splash_screen.dart`):

```dart
Future<void> _loadGameFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final gameJson = prefs.getString(_gamePrefsKey);
  if (gameJson != null && gameJson.isNotEmpty) {
    final game = Game.fromJson(gameJson);
    ref.read(gameProvider.notifier).setNumPlayers(game.numPlayers);
    ref.read(gameProvider.notifier).setMaxRounds(game.maxRounds);
    ref.read(gameProvider.notifier).setEnablePhases(game.enablePhases);
    ref.read(gameProvider.notifier).setVersion(game.version);
  }
}
```

**State Saving on Game Start**:

```dart
ElevatedButton(
  onPressed: () async {
    ref.read(gameProvider.notifier).setNumPlayers(_selectedPlayers);
    ref.read(gameProvider.notifier).setMaxRounds(_selectedMaxRounds);
    // ... other configuration updates

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final game = ref.read(gameProvider.notifier).stateValue();
    await prefs.setString(_gamePrefsKey, game.toJson());
  },
  child: const Text('Continue'),
)
```

### Reactive Updates

Widgets automatically update when state changes through `ref.watch()`:

**Score Table Watching State** (`lib/score_table.dart`):

```dart
Widget build(BuildContext context) {
  final players = ref.watch(playersProvider);
  final game = ref.watch(gameProvider);

  // UI automatically rebuilds when players or game state changes
}
```

**Real-time Score Updates** (`lib/round_score_field.dart`):

```dart
void _onInputChanged(String value) {
  _validateInput(value);

  // Update score immediately for real-time total calculation
  if (!_hasValidationError && value.isNotEmpty) {
    final parsed = int.tryParse(value);
    widget.onChanged(parsed); // Triggers playersProvider update
  }
}
```

### State Dependencies

The `PlayersProvider` demonstrates dependency injection through the `build()` method:

```dart
@override
Players build() {
  final game = ref.watch(gameProvider); // Dependency on GameProvider
  return Players(
    numPlayers: game.numPlayers,
    maxRounds: game.maxRounds,
    numPhases: game.numPhases,
  );
}
```

When `GameProvider` state changes, `PlayersProvider` automatically rebuilds with the new configuration, ensuring data consistency.

## Key Use Cases

### New Game Flow

1. **SplashScreen displays game configuration UI**
2. **User selects players, rounds, and options**
3. **GameProvider state updated via notifier methods**
4. **PlayersProvider automatically rebuilds due to dependency**
5. **Configuration saved to SharedPreferences**
6. **Navigation to score table**

### Score Updates and Total Calculation

1. **User enters score in RoundScoreField**
2. **RoundScoreField calls onChanged callback immediately for real-time updates**
3. **Callback invokes playersProvider.notifier.updateScore()**
4. **PlayersNotifier updates specific player's score in state**
5. **TotalScoreField displays player.totalScore (computed getter from Scores.total)**
6. **UI automatically updates via ref.watch(playersProvider)**

### Column Lock Actions

1. **User clicks lock/unlock icon in column header**
2. **IconButton calls playersProvider.notifier.toggleRoundEnabled()**
3. **PlayersNotifier updates enabled state for all players for that round**
4. **RoundScoreField and PhaseCheckboxDropdown receive new enabled prop**
5. **UI reflects locked state (disabled fields, lock icon changes)**

## Code Examples

### Provider Declarations

```dart
// Game configuration provider
final gameProvider = NotifierProvider<GameNotifier, Game>(() => GameNotifier());

// Player data provider (depends on gameProvider)
final playersProvider = NotifierProvider<PlayersNotifier, Players>(() => PlayersNotifier());

// Theme provider
final themeProvider = NotifierProvider<ThemeNotifier, bool>(() => ThemeNotifier());
```

### ref.watch vs ref.read Usage

```dart
// ref.watch - subscribes to state changes, rebuilds widget when state updates
final players = ref.watch(playersProvider);
final game = ref.watch(gameProvider);

// ref.read - reads current state or triggers actions without subscribing
final currentPlayers = ref.read(playersProvider);
ref.read(playersProvider.notifier).updateScore(playerIdx, round, score);
```

### Dependency Injection in build() Method

```dart
class PlayersNotifier extends Notifier<Players> {
  @override
  Players build() {
    // Watch gameProvider - when it changes, this provider rebuilds
    final game = ref.watch(gameProvider);

    return Players(
      numPlayers: game.numPlayers,
      maxRounds: game.maxRounds,
      numPhases: game.numPhases,
    );
  }
}
```

### State Update Patterns

```dart
// Simple state update
void setTheme(bool isDark) {
  state = isDark;
}

// Complex state update with object creation
void updateScore(int playerIdx, int round, int? score) {
  final player = state.players[playerIdx];
  player.scores.setScore(round, score);
  state = state.withPlayer(player, playerIdx);
}

// Bulk state update
void toggleRoundEnabled(int round, bool enabled) {
  var newState = state;
  for (int i = 0; i < state.length; i++) {
    final player = state.players[i];
    player.scores.setEnabled(round, enabled);
    player.phases.setEnabled(round, enabled);
    newState = newState.withPlayer(player, i);
  }
  state = newState;
}
```

### Real-time Total Score Calculation Flow

```dart
// 1. User input triggers immediate update
RoundScoreField(
  onChanged: enabled ? (parsed) {
    ref.read(playersProvider.notifier).updateScore(playerIdx, round, parsed);
  } : (parsed) {},
)

// 2. PlayersNotifier updates state
void updateScore(int playerIdx, int round, int? score) {
  final player = state.players[playerIdx];
  player.scores.setScore(round, score);
  state = state.withPlayer(player, playerIdx);
}

// 3. Player model calculates total
int get totalScore => scores.total;

// 4. Scores model computes sum
int get total => roundScores.whereType<int>().fold(0, (a, b) => a + b);

// 5. TotalScoreField displays updated total
TotalScoreField(
  totalScore: player.totalScore, // Automatically updates via ref.watch
)
```

## Key Files Referenced

- `lib/provider/game_provider.dart` - Game configuration state
- `lib/provider/players_provider.dart` - Player data state
- `lib/presentation/in_game_app_bar.dart` - Theme state
- `lib/splash_screen.dart` - State initialization and persistence
- `lib/score_table.dart` - State consumption and column locking
- `lib/round_score_field.dart` - Real-time score updates
- `lib/total_score_field.dart` - Computed total display
- `lib/model/scores.dart` - Score calculation logic
- `lib/model/player.dart` - Player model with totalScore getter
