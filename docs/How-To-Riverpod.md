---
diataxis: how-to
---

# How to work with Riverpod in this app

Rules to follow when adding features or fixing bugs. For the concepts and the repository-vs-notifier rationale, see [State-Management.md](State-Management.md) and [State-Management.md — Provider Architecture](State-Management.md#provider-architecture). For the data model and provider/prefs reference, see [State-Reference.md](State-Reference.md).

## Provider layers (top to bottom)

| Provider                                               | Responsibility                                                                         |
| ------------------------------------------------------ | -------------------------------------------------------------------------------------- |
| `sharedPreferencesProvider`                            | Injects the single `SharedPreferences` instance (must be overridden in `bootstrapApp`) |
| `gameRepositoryProvider` / `playersRepositoryProvider` | Stateless persistence services (`load*`, `save*`, `clear*`)                            |
| `gameNotifierProvider` / `playersNotifierProvider`     | In-memory app state (`Game`, `Players`) and gameplay mutations                         |
| `appRouterProvider`                                    | `GoRouter` wired to prefs for initial route                                            |
| UI (`ConsumerWidget`)                                  | `ref.watch` notifier providers; never own persistence logic                            |

## `ref.watch` vs `ref.read`

- **`ref.watch`**: Use in widget `build()` methods and in other providers' `build()` when the consumer must rebuild when dependencies change.
- **`ref.read`**: Use in callbacks (`onPressed`, `initState` one-shot setup), notifier mutation methods, and when calling `.notifier` to run an action without subscribing.
- **Do not** call `ref.watch` inside event handlers; it does not subscribe the widget and is misleading.

## UI and notifier rules

- Widgets should use **`gameNotifierProvider`** and **`playersNotifierProvider`** for display and actions (`ref.read(...notifier).updateScore(...)`).
- Do **not** call `GameRepository` / `PlayersRepository` from widgets except documented exceptions:
  - Splash: `playersNotifierProvider.notifier.prepareForSplashEntry()` on entry (via `SplashScreen`; see [State-Management.md — Splash entry and coalesced persist race](State-Management.md#splash-entry-and-coalesced-persist-race))
  - Router: `initialLocation()` reads repos before the widget tree exists (see [State-Management.md — Routing Logic](State-Management.md#routing-logic-librouterapp_routerdart))
- Do **not** push loaded state from repositories into notifiers via side channels; restore in `Notifier.build()` only.

## `Notifier.build()` rules

- Load synchronously from the matching repository provider (`ref.watch(gameRepositoryProvider)` then `loadGame()`).
- Return persisted data when validation passes (`playersMatchConfiguration` for players).
- **No** saves, timers, or `unawaited` disk writes in `build()` — those belong in mutation methods or explicit UI flows (e.g. splash **Start new game** saving the baseline roster).

## Mutations and persistence

1. Update `state` on the notifier.
2. Persist with `ref.read(gameRepositoryProvider).saveGame(state)` or `playersRepositoryProvider` (coalesced single-flight for players).

## Startup and `UncontrolledProviderScope`

`bootstrapApp()` in `lib/main.dart`:

1. Awaits `SharedPreferences.getInstance()` before `runApp`.
2. Creates a `ProviderContainer` with `sharedPreferencesProvider.overrideWithValue(sharedPrefs)`.
3. Mounts the tree with **`UncontrolledProviderScope`** so the container created in `main` is the app's provider scope (the framework does not create a separate container).

Notifiers load persisted data the first time something `watch`es or `read`s them — there is no imperative `repositoryDidLoadPrefs()`.

## Anti-patterns (do not reintroduce)

| Anti-pattern                                         | Why it fails                                             |
| ---------------------------------------------------- | -------------------------------------------------------- |
| Singleton `GameRepository()` / `PlayersRepository()` | Untestable, hides DI, duplicate prefs instances          |
| `repositoryDidLoadPrefs()` on notifiers              | Bypasses `build()` validation; caused restore bugs       |
| Resume routing via `prefs.containsKey` only          | Routes to score table when JSON is invalid or mismatched |
| `phases.completedPhases.length == numPhases`         | Wrong dimension; phases lists are sized by `maxRounds`   |
| Fire-and-forget `main()` in integration tests        | Races `runApp` on slow Android devices                   |
| `ref.watch` inside event handlers / callbacks        | Does not subscribe the widget — use `ref.read`           |
| Saves / timers / `unawaited` writes in `build()`     | Belong in mutators or explicit UI flows, not `build()`   |

## Integration and widget testing

**Unit / widget tests** (`test/`):

- `test/flutter_test_config.dart` sets `SharedPreferences.setMockInitialValues({})` before each run.
- Widget tests that need repositories should wrap the widget in `ProviderScope` and override `sharedPreferencesProvider` with the same mock instance.

**Integration tests** (`integration_test/`):

- Use helpers in `integration_test/app_test_helpers.dart`:
  - `clearPersistedGameState()` in `setUp` / `tearDown` (real prefs on devices)
  - `await launchApp(tester)` or `launchAppOnSplash(tester)` — **must** `await bootstrapApp()`, not `main()` without await
  - `waitForSplashReady(tester)` — before tapping Continue on initial splash (Android CI prefs race)
  - `waitForScoreTable(tester)` — after Continue / navigation to score table
  - `pumpUntilFound` when waiting for splash widgets on slow emulators
  - `waitForSplashPlayersCleared(tester)` after navigating back to splash when asserting `players_state` was removed (see [State-Management.md — Splash entry and coalesced persist race](State-Management.md#splash-entry-and-coalesced-persist-race))
- Read notifier state via `ProviderScope.containerOf(element).read(gameNotifierProvider)` — works with `UncontrolledProviderScope`.
