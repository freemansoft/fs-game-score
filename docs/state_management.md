# State Management Documentation

## Retaining and managing state

The application saves the game configuration when the game is started. It loads that configuration and makes it the current configuration when the game program is rerun and shows that on the spalsh screen. The program always starts on the splash_screen that uses that configuration as the defaults for the game configuration.

The applicaton also saves the current game state as the game is played. This is used to restore the game state after a crash or reload on the web. If an in-flight or really any game is found on startup then that game is loaded and the application jumps directly to the score_table_screen. There is currently a 5 second delay for saving the game state to disk to prevent excessive writes.

The new game function on the splash screen clears out any previous game state whenever it starts a new game

## Overview

This application uses **Riverpod 3** as its state management solution. Riverpod was chosen for its excellent integration with Flutter, compile-time safety, and powerul reactive programming capabilities. The architecture follows Riverpod 3's modern patterns using `Notifier` and `NotifierProvider` for state management.

Features include:

- **Separation of Concerns**: Game configuration and Player data are managed in separate providers.
- **Reactive UI**: The UI automatically updates in real-time when state changes.
- **Persistence**: Game configuration and Player progress are persisted locally using `SharedPreferences`, enabling app restart recovery ("Resume Game").

### Core Concepts

- **Notifier**: A class that extends `Notifier<T>` and manages state of type `T`
- **NotifierProvider**: Declares a provider that creates and manages a `Notifier` instance
- **ref.watch()**: Subscribes to state changes and rebuilds widgets when state updates
- **ref.read()**: Reads current state or triggers actions without subscribing to updates

## Persistence Strategy

The application implements a robust persistence strategy to handle app restarts and crashes.

1.  **Game Configuration**: Saved immediately when a game is started.
2.  **Player Progress**: Auto-saved with a **5-second debounce** during gameplay to prevent excessive writes.
3.  **Resume Game**: On startup, if both a valid game configuration and player state exist, the app automatically navigates to the Score Table, bypassing the Splash Screen.
4.  **New Game**: Starting a new game from the Splash Screen explicitly clears previous player state to ensure a fresh start.

## Provider Architecture

The application uses three main providers to manage different aspects of state:

### GameProvider

**Location**: `lib/provider/game_provider.dart`

The `GameProvider` manages global game configuration and settings. It persists state using `GameRepository`.

```dart
final gameProvider = NotifierProvider<GameNotifier, Game>(() => GameNotifier());

class GameNotifier extends Notifier<Game> {
  @override
  Game build() => const Game();

  Future<void> newGame({ ... }) async {
    state = Game( ... );
    // Immediate save on new game creation
    await GameRepository().saveGameToPrefs(state);
  }
}
```

**State Managed**:

`Game` class containing:

- `numPlayers`: Number of players in the game (2-8)
- `maxRounds`: Maximum number of rounds (1-20)
- `numPhases`: Number of phases (default: 10)
- `enablePhases`: Whether to show phase tracking
- `scoreFilter`: Regex pattern for valid scores
- `version`: Application version string

### PlayersProvider

**Location**: `lib/provider/players_provider.dart`

The `PlayersProvider` manages all player data. It depends on `GameProvider` for initialization configuration and `PlayersRepository` for persistence.

```dart
final playersProvider = NotifierProvider<PlayersNotifier, Players>(() => PlayersNotifier());

class PlayersNotifier extends Notifier<Players> {
  Timer? _saveTimer;

  @override
  Players build() {
    final game = ref.watch(gameProvider);

    // Attempt to load existing players from repository
    final loadedPlayers = PlayersRepository().loadedPrefsPlayers;

    // Validation logic ensures loaded players match current game config
    if (loadedPlayers != null && _isValid(loadedPlayers, game)) {
        return loadedPlayers;
    }

    // Default: Create new players based on game config
    return Players( ... );
  }

  // Auto-save logic
  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 5), () {
      unawaited(PlayersRepository().savePlayersToPrefs(state));
    });
  }

  void updateScore(...) {
    // update state...
    _scheduleSave();
  }
}
```

**State Managed**:

`Player` class containing:

- Player names and data
- Individual round scores for each player
- Phase completion status
- Round enable/disable state (column locking)
- Automatic total score calculation

**Key Feature**: The `build()` method attempts to restore state from `PlayersRepository`. If valid state exists, it is used; otherwise, a fresh state is created based on the current `GameProvider` configuration.

### ThemeProvider

**Location**: `lib/presentation/in_game_app_bar.dart`

The `ThemeProvider` manages UI theme state (light/dark mode).

## Data Access Layer (Repositories)

The application uses a repository pattern backed by `SharedPreferences` to abstract data persistence.

### GameRepository

**Location**: `lib/data/game_repository.dart`

- **Responsibility**: Persist `Game` configuration.
- **Key Methods**: `loadGameFromPrefs()`, `saveGameToPrefs()`.

### PlayersRepository

**Location**: `lib/data/players_repository.dart`

- **Responsibility**: Persist `Players` list and their progress.
- **Key Methods**: `loadPlayersFromPrefs()`, `savePlayersToPrefs()`, `clearPrefsPlayers()`.

## App Startup & Navigation Flow

The app startup logic handles state restoration and determines the initial screen.

**Startup Logic (`lib/main.dart`)**:

1.  Initialize Flutter bindings.
2.  `GameRepository().loadGameFromPrefs()`: Load game config.
3.  `PlayersRepository().loadPlayersFromPrefs()`: Load player progress.
4.  Run App.

**Routing Logic (`lib/router/app_router.dart`)**:

- Checks if both `Game` and `Players` state were successfully loaded.
- **If Both Exist**: Sets initial route to `/score-table` (Resume Game).
- **Otherwise**: Sets initial route to `/` (Splash Screen).

**New Game Flow (`lib/splash_screen.dart`)**:

1.  User configures game.
2.  User clicks "Continue".
3.  `PlayersRepository().clearPrefsPlayers()`: Clears old data.
4.  `GameNotifier.newGame()`: Updates and saves new game config.
5.  `PlayersNotifier` rebuilds with fresh state.
6.  Navigate to Score Table.

## Code Examples

### State Saving on Game Start

```dart
// lib/splash_screen.dart

ElevatedButton(
  onPressed: () async {
    // 1. Clear previous player state
    await PlayersRepository().clearPrefsPlayers();

    // 2. Create and save new game configuration
    await ref.read(gameProvider.notifier).newGame( ... );

    // 3. Navigate (PlayersProvider will rebuild automatically)
    if (context.mounted) {
      context.goNamed('scoreTable');
    }
  },
  child: const Text('Continue'),
)

// lib/provider/game_provider.dart
Future<void> newGame(...) async {
    state = Game(...);
    await GameRepository().saveGameToPrefs(state);
}
```

### Reactive Updates & Auto-Save

```dart
// lib/provider/players_provider.dart

void updateScore(int playerIdx, int round, int? score) {
  final player = state.players[playerIdx];
  player.scores.setScore(round, score);
  state = state.withPlayer(player, playerIdx);

  // Debounced save
  _scheduleSave();
}
```

## Key Files Referenced

- `lib/provider/game_provider.dart` - Game configuration state & logic
- `lib/provider/players_provider.dart` - Player data state & auto-save logic
- `lib/data/game_repository.dart` - Game persistence
- `lib/data/players_repository.dart` - Players persistence
- `lib/main.dart` - App startup & state loading
- `lib/router/app_router.dart` - Conditional navigation (resume logic)
- `lib/splash_screen.dart` - New game creation flow
