# Agent Instructions: fs-game-score (fs_score_card)

This file contains crucial instructions, guidelines, and context for AI agents and developer tools operating on the `fs-game-score` repository. If you are an agent modifying, building, or analyzing this codebase, you **must** read and adhere to these guidelines.

---

## ⚠️ Critical Rule: ALWAYS Use FVM (Flutter Version Management)

This project uses **FVM** (Flutter Version Management) to manage the Flutter SDK version and ensure consistency across development environments. The specific Flutter version for this project is managed by `.fvmrc`.

> [!IMPORTANT]
> **Every Flutter and Dart command MUST be prefixed with `fvm`.**
> Never run raw `flutter` or `dart` commands. Always use `fvm flutter` and `fvm dart`.

### Correct Command Usage Examples

| Task | Incorrect Command | Correct Command |
| :--- | :--- | :--- |
| **Clean Project** | `flutter clean` | `fvm flutter clean` |
| **Get Dependencies** | `flutter pub get` | `fvm flutter pub get` |
| **Run App** | `flutter run` | `fvm flutter run` |
| **Build Web** | `flutter build web ...` | `fvm flutter build web ...` |
| **Run Analysis** | `flutter analyze` | `fvm flutter analyze` |
| **Run Tests** | `flutter test` | `fvm flutter test` |
| **Format Code** | `dart format .` | `fvm dart format .` |
| **Run Dart tool** | `dart run ...` | `fvm dart run ...` |

> [!WARNING]
> Running commands without the `fvm` prefix can cause compilation issues, version mismatch errors, or corrupt the local build cache due to using a different system-installed Flutter version than the one specified in `.fvmrc`.

---

## 🛠️ Codebase Context & Architecture

### 1. State Management (Riverpod 3)

* The application utilizes **Riverpod 3** (via `flutter_riverpod` and `hooks_riverpod` version `^3.1.0`) for compile-time safe, reactive state management.
* **Provider layers** (see [docs/State-Management.md](docs/State-Management.md) for full patterns):
  * `sharedPreferencesProvider` ([prefs_provider.dart](lib/provider/prefs_provider.dart)): DI for `SharedPreferences`; overridden in `bootstrapApp()` before `runApp`.
  * `gameRepositoryProvider` / `playersRepositoryProvider`: Persistence only (`load*`, `save*`, `clear*`).
  * `gameNotifierProvider` ([game_provider.dart](lib/provider/game_provider.dart)): Live `Game` configuration and `gameId`.
  * `playersNotifierProvider` ([players_provider.dart](lib/provider/players_provider.dart)): Live roster, scores, phases, round locks.
  * `appRouterProvider` ([app.dart](lib/app.dart)): `GoRouter` with resume logic from prefs.
* **Rules**: Widgets `ref.watch` / `ref.read` **notifier** providers; use **repository** providers only from notifiers, router startup, or documented splash flows. Do not restore state via repository callbacks into notifiers.
* **Startup**: `bootstrapApp()` in [main.dart](lib/main.dart) pre-inits prefs and mounts `UncontrolledProviderScope` with a pre-built `ProviderContainer`.
* **Persistence**: Game config saved on `newGame()`; player progress debounced (5s) during play; baseline roster saved on splash **Continue**.
* **Integration tests**: Use `integration_test/app_test_helpers.dart` — **`await bootstrapApp()`** via `launchApp` / `launchAppOnSplash`; never call `main()` without awaiting (Android race). Clear prefs in `setUp`/`tearDown`.

### 2. Localization

* Localization is configured in `l10n.yaml` and generated code is used.
* When adding or modifying user-facing text, ensure it utilizes the generated localization bindings.

### 3. Code Quality and Styling

* This codebase enforces high code quality standard guidelines defined in `analysis_options.yaml` and is configured with `very_good_analysis`.
* Before submitting code modifications:
  1. Format your changes: `fvm dart format .`
  2. Run static analysis: `fvm flutter analyze`
  3. Ensure no errors or warnings are introduced.

---

## 📝 Running Tests & Verification

To verify that your changes did not break existing functionality, run the unit and widget tests:

```bash
fvm flutter test
```

For integration tests, run:

```bash
fvm flutter test integration_test/
```

Thank you for building responsibly!
