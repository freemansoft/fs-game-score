# State Management Documentation

## Retaining and Managing State

The application saves the game configuration when the game is started and the current game state while the game is being played. There is currently a 5-second delay (debounce) for saving the game state to disk to prevent excessive writes.

### Upon Startup:

- **No game state to restore**: It loads the persisted game configuration and makes it the active configuration when the game is launched, showing it on the **Splash Screen**.
- **Game state to restore exists**: The active game is loaded, and the application navigates directly to the `score_table_screen`. This enables seamless game resumption after an app crash, a browser reload on the web, or a pause/dehydration event on mobile.

The "New Game" function on the Splash Screen clears out any previous game state whenever a new game is started.

Currently, there is no way to clear the game configuration or game state other than to configure and start a new game.

## Known Issues and Defects

1.  **Game / Player state is not saved until the first score sheet piece of data is entered (either a round score or a player name).**
    This means a reload, crash, or app restart prior to entering the first score results in the app restarting on the Splash Screen instead of the Score Table. (See the [Identified State Management Problems & Architectural Risks](#identified-state-management-problems--architectural-risks) section below for a detailed root cause analysis).

## Data Model

A game is represented by the `Game` class that contains a game `id` (automatically generated as a UUID) and a game `configuration` implemented by the `GameConfiguration` class. The `GameConfiguration` contains the number of players, the maximum number of rounds, the game mode (`Standard`, `Phase 10`, `French Driving`, `Skyjo`), the score filter, the end game score, and the version.

The players and their scores in a game are represented by the `Players` class, which wraps a list of `Player` objects.

Each player is represented by a `Player` object that contains:
- `name`: The player's display name.
- `scores`: A `Scores` object containing individual round scores.
- `phases`: A `Phases` object tracking phase completion status.
- `frenchDrivingAttributes`: A list of `FrenchDrivingRoundAttributes` (for the French Driving game mode).
- `roundStates`: A `RoundStates` object representing per-round information (such as round column locks that tell the UI to block editing for that round).

---

## State Management

This application uses **Riverpod 3** (via `flutter_riverpod` and `hooks_riverpod` version `^3.1.0`) as its state management solution. Riverpod provides compile-time safety, unidirectional data flow, and powerful reactive programming capabilities. The architecture uses `Notifier` and `NotifierProvider` to manage and modify synchronous application state.

### Features Include:
- **Separation of Concerns**: Game configuration and Player data are managed in separate providers (`gameProvider` and `playersProvider`).
- **Reactive UI**: The UI widgets automatically watch and rebuild in real-time when the state changes.
- **Persistence**: Game configuration and Player progress are persisted locally using `SharedPreferences`, enabling app restart recovery ("Resume Game").

### Core Concepts:
- **Notifier**: A class extending `Notifier<T>` that encapsulates business logic and manages state of type `T`.
- **NotifierProvider**: Declares a provider that exposes and manages a `Notifier` instance.
- **ref.watch()**: Subscribes a widget or another provider to state changes, triggering a rebuild when the state updates.
- **ref.read()**: Reads the current state or triggers actions inside a notifier without subscribing to future updates (typically used in event handlers like buttons).

---

## Persistence Strategy

The application implements a persistence strategy using `SharedPreferences` to handle app restarts and crashes:

1.  **Game Configuration**: Saved immediately when a game is created/started.
2.  **Player Progress**: Auto-saved with a **5-second debounce** during gameplay to prevent excessive disk writes.
3.  **Resume Game**: On startup, if both a valid game configuration and player state exist, the app automatically navigates to the Score Table, bypassing the Splash Screen.
4.  **New Game**: Entering the Splash Screen explicitly clears previous player state to ensure a fresh start.

---

## Provider Architecture

The application uses two main providers to manage different aspects of state:

### 1. GameProvider

**Location**: `lib/provider/game_provider.dart`

The `gameProvider` manages the global game configuration, settings, and active game ID. It persists its state using `GameRepository`.

```dart
class GameNotifier extends Notifier<Game> {
  @override
  Game build() {
    return GameRepository().loadedPrefsGame ?? Game();
  }

  // Anti-pattern: Returns state directly. Use ref.read(gameProvider) instead.
  Game stateValue() => state;

  Future<void> newGame({
    int? maxRounds,
    int? numPlayers,
    GameMode? gameMode,
    String? scoreFilter,
    int? endGameScore,
    String? version,
  }) async {
    state = Game(
      configuration: GameConfiguration(
        maxRounds: maxRounds ?? state.configuration.maxRounds,
        numPlayers: numPlayers ?? state.configuration.numPlayers,
        gameMode: gameMode ?? state.configuration.gameMode,
        scoreFilter: scoreFilter ?? state.configuration.scoreFilter,
        endGameScore: endGameScore ?? state.configuration.endGameScore,
        version: version ?? state.configuration.version,
      ),
      // A new unique gameId UUID is automatically generated upon initialization
    );
    await GameRepository().saveGameToPrefs(state);
  }

  /// Sets the game state loaded from the repository.
  /// Called by the repository after loading from SharedPreferences.
  void repositoryDidLoadPrefs(Game game) {
    state = game;
  }
}

final gameProvider = NotifierProvider<GameNotifier, Game>(GameNotifier.new);
```

**State Managed (`Game`):**
- `gameId`: A unique string identifying the current game match.
- `configuration`: A `GameConfiguration` class containing:
  - `numPlayers`: Number of players in the game (2-8).
  - `maxRounds`: Maximum number of rounds (1-20).
  - `gameMode`: Selected mode (`Standard`, `Phase 10`, `French Driving`, `Skyjo`).
  - `endGameScore`: Target score to end the game (e.g., auto-set to 5000 for French Driving or 100 for Skyjo).
  - `numPhases`: Derived from game mode (10 for Phase 10, 0 otherwise).
  - `allowNegativeScores`: Derived from game mode (true for Skyjo).
  - `scoreFilter`: Regex pattern for validating input scores.
  - `version`: Application version string.

---

### 2. PlayersProvider

**Location**: `lib/provider/players_provider.dart`

The `playersProvider` manages all player data, scores, phases, and active round lock states. It watches `gameProvider` to automatically rebuild or reinitialize when game configurations change, and depends on `PlayersRepository` for persistence.

```dart
final playersProvider = NotifierProvider<PlayersNotifier, Players>(
  PlayersNotifier.new,
);

class PlayersNotifier extends Notifier<Players> {
  Timer? _saveTimer;

  @override
  Players build() {
    final game = ref.watch(gameProvider);

    // Check if we have loaded players from repository
    final loadedPlayers = PlayersRepository().loadedPrefsPlayers;

    // If loaded players exist and match game configuration, use them
    if (loadedPlayers != null &&
        loadedPlayers.players.isNotEmpty &&
        loadedPlayers.players.length == game.configuration.numPlayers) {
      final firstPlayer = loadedPlayers.players[0];
      if (firstPlayer.scores.roundScores.length == game.configuration.maxRounds &&
          firstPlayer.phases.completedPhases.length == game.configuration.numPhases) {
        return loadedPlayers;
      }
    }

    // Otherwise create new players based on game configuration
    return Players(
      numPlayers: game.configuration.numPlayers,
      maxRounds: game.configuration.maxRounds,
    );
  }

  /// Schedule a save to repository after 5 seconds of idle time (debounced)
  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 5), () {
      unawaited(PlayersRepository().savePlayersToPrefs(state));
    });

    /// Cancel any pending save timer on dispose
    ref.onDispose(() {
      _saveTimer?.cancel();
    });
  }

  void updateScore(int playerIdx, int round, int? score) {
    final player = state.players[playerIdx];
    player.scores.setScore(round, score);
    state = state.withPlayer(player, playerIdx);
    _scheduleSave();
  }

  void updateFrenchDrivingAttributes(
    int playerIdx,
    int round,
    FrenchDrivingRoundAttributes attributes,
  ) {
    final player = state.players[playerIdx];
    player.frenchDrivingAttributes[round] = attributes;
    player.scores.setScore(round, attributes.calculateScore());
    state = state.withPlayer(player, playerIdx);
    _scheduleSave();
  }

  void updatePhase(int playerIdx, int round, int? phase) {
    final player = state.players[playerIdx];
    player.phases.setPhase(round, phase);
    state = state.withPlayer(player, playerIdx);
    _scheduleSave();
  }

  void updatePlayerName(int playerIdx, String name) {
    final player = state.players[playerIdx];
    final updatedPlayer = Player.withData(
      name: name,
      scores: player.scores,
      phases: player.phases,
      frenchDrivingAttributes: player.frenchDrivingAttributes,
      roundStates: player.roundStates,
    );
    state = state.withPlayer(updatedPlayer, playerIdx);
    _scheduleSave();
  }

  void resetGame({bool clearNames = false}) {
    final maxRounds = state.length > 0
        ? state.players[0].scores.roundScores.length
        : 0;
    final newPlayers = <Player>[];
    for (int i = 0; i < state.length; i++) {
      final oldPlayer = state.players[i];
      final newName = clearNames ? 'Player ${i + 1}' : oldPlayer.name;
      final newPlayer = Player(
        name: newName,
        maxRounds: maxRounds,
      );
      newPlayers.add(newPlayer);
    }
    state = Players(
      numPlayers: state.length,
      maxRounds: maxRounds,
      initialPlayers: newPlayers,
    );
    _scheduleSave();
  }

  void toggleRoundEnabled({required int round, required bool enabled}) {
    var newState = state;
    for (int i = 0; i < state.length; i++) {
      final player = state.players[i];
      player.roundStates.setEnabled(round: round, enabled: enabled);
      newState = newState.withPlayer(player, i);
    }
    state = newState;
    _scheduleSave();
  }

  /// Sets the players state loaded from repository (called by repository on load)
  void repositoryDidLoadPrefs(Players players) {
    state = players;
  }
}
```

**State Managed (`Players`):**
- Player names and structured metadata.
- Individual round scores for each player.
- Phase completion status (Phase 10).
- Round enable/disable state (column locks).
- Automatic total score calculations.

---

## Data Access Layer (Repositories)

The application uses a repository pattern backed by `SharedPreferences` to abstract data persistence.

### GameRepository

**Location**: `lib/data/game_repository.dart`
- **Responsibility**: Persist the `Game` configuration.
- **Key Methods**: `loadGameFromPrefs()`, `saveGameToPrefs()`, `clearGameFromPrefs()`.

### PlayersRepository

**Location**: `lib/data/players_repository.dart`
- **Responsibility**: Persist the list of `Players` and their gameplay progress.
- **Key Methods**: `loadPlayersFromPrefs()`, `savePlayersToPrefs()`, `clearPlayersFromPrefs()`.

---

## App Startup & Navigation Flow

The app startup logic handles state restoration and determines the initial screen.

### Startup Sequence (`lib/main.dart`):

1.  **Initialize bindings**: `WidgetsFlutterBinding.ensureInitialized()` is executed.
2.  **Container Creation**: A manual `ProviderContainer` is initialized.
3.  **Repository Handshakes**: Repositories are registered with the `ProviderContainer`:
    ```dart
    final container = ProviderContainer();
    GameRepository().initialize(container);
    PlayersRepository().initialize(container);
    ```
4.  **Asynchronous State Loading**:
    ```dart
    await GameRepository().loadGameFromPrefs();
    await PlayersRepository().loadPlayersFromPrefs();
    ```
    During this process, if the repositories find persisted states in `SharedPreferences`, they **manually push** that loaded state into the active providers via:
    ```dart
    _container?.read(gameProvider.notifier).repositoryDidLoadPrefs(loadedPrefsGame!);
    _container?.read(playersProvider.notifier).repositoryDidLoadPrefs(loadedPrefsPlayers!);
    ```
5.  **Run Application**: The app runs within an `UncontrolledProviderScope` using the pre-loaded `container`.

### Routing Logic (`lib/router/app_router.dart`):

A GoRouter instance determines the initial route using the repository singletons' values:
```dart
String _initialLocation() {
  final hasGame = GameRepository().loadedPrefsGame != null;
  final hasPlayers = PlayersRepository().loadedPrefsPlayers != null;

  // Resume game if both game and players state exist on disk
  if (hasGame && hasPlayers) {
    return '/score-table';
  }
  // Otherwise show splash screen
  return '/';
}
```

### New Game Flow (`lib/presentation/splash_screen.dart`):

1.  Entering the Splash Screen triggers an immediate deletion of previous player data to guarantee a fresh state:
    ```dart
    unawaited(PlayersRepository().clearPlayersFromPrefs());
    ```
2.  User configures game options on the UI.
3.  User clicks the "Continue" button:
    - Creates and saves a new game configuration using `ref.read(gameProvider.notifier).newGame(...)` (which immediately writes to preferences).
    - Navigates to `/score-table`.
    - `PlayersNotifier` watches `gameProvider`, detects the new game configuration, and automatically rebuilds with a fresh, empty `Players` state.

---

## Identified State Management Problems & Architectural Risks

### 1. New Game Startup Redirect Defect (Known Issue #1)
*   **Symptom**: If the user starts a new game (navigating from the Splash Screen to the Score Table) and restarts/reloads the application *prior* to entering a score or editing a player's name, the app opens to the Splash Screen instead of resuming on the Score Table screen.
*   **Root Cause**:
    1.  Entering the Splash Screen clears previous player progress via `PlayersRepository().clearPlayersFromPrefs()`.
    2.  Clicking "Continue" creates the new game configuration and immediately saves it to disk via `GameRepository().saveGameToPrefs()`.
    3.  `PlayersNotifier` rebuilds with a fresh in-memory `Players` object, but **does not write this new, empty state to disk immediately**.
    4.  Instead, `PlayersNotifier` only schedules saves (`_scheduleSave()`) on subsequent state mutations (like score or name updates).
    5.  On app reload, the routing logic checks `GameRepository().loadedPrefsGame != null && PlayersRepository().loadedPrefsPlayers != null`. Because the empty player state was never persisted, `loadedPrefsPlayers` is null, causing the router to route back to the Splash Screen `/`, discarding the newly started game.
*   **Recommended Remediation**:
    Ensure the empty initialized player state is saved to the repository immediately upon game creation. This can be achieved by calling `PlayersRepository().savePlayersToPrefs(state)` at the end of the `PlayersNotifier` initialization or when starting a new game in `splash_screen.dart`.

### 2. Imperative Startup & Tight Coupling (Riverpod Anti-Pattern)
*   **Problem**: The application utilizes a highly custom imperative sequence to initialize providers. It creates a manual `ProviderContainer` in `main.dart` and injects it into singleton repositories (`GameRepository` and `PlayersRepository`). The repositories perform async disk reads and then **manually push** state into the notifiers via backdoor methods (`repositoryDidLoadPrefs()`).
*   **Risks**:
    *   **Tight Coupling / Circular Dependency**: The repositories import and depend directly on the notifiers to push state, while the notifiers import and depend on the repositories for saving, breaking clean layer separation.
    *   **Testability Problems**: Bypassing Riverpod's standard dependency injection makes unit and integration tests difficult to write and maintain, as they depend on singleton instantiations, global variables, and side-channel container injection.
    *   **Ignoring Riverpod Paradigms**: The native state loading capabilities of Riverpod are ignored.
*   **Recommended Remediation**:
    Refactor the providers to be declarative using Riverpod's **`AsyncNotifier`** or **`FutureProvider`**. The `build()` method of `GameNotifier` and `PlayersNotifier` should be asynchronous and fetch state from the repositories directly:
    ```dart
    @override
    Future<Game> build() async {
      final repository = ref.watch(gameRepositoryProvider);
      return repository.loadGame();
    }
    ```
    This removes the need for injecting `ProviderContainer` into repositories, removes `repositoryDidLoadPrefs()`, and isolates repositories from knowing about UI state management providers.

---

## Key Files Referenced

- `lib/provider/game_provider.dart` - Game configuration state and UUID logic
- `lib/provider/players_provider.dart` - Player data state, validations, and auto-save debouncing
- `lib/data/game_repository.dart` - Game configuration persistence using SharedPreferences
- `lib/data/players_repository.dart` - Player state persistence using SharedPreferences
- `lib/main.dart` - App startup and imperative ProviderContainer setup
- `lib/router/app_router.dart` - App router with initial route resume logic
- `lib/presentation/splash_screen.dart` - Game configuration setting UI & new game initialization
