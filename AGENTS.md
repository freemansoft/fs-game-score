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
* Core providers:
  * `gameNotifierProvider` ([game_provider.dart](file:///Users/joefreeman/Documents/GitHub/freemansoft/fs-game-score/lib/provider/game_provider.dart)): Manages global game settings (`Game` and `GameConfiguration`).
  * `playersNotifierProvider` ([players_provider.dart](file:///Users/joefreeman/Documents/GitHub/freemansoft/fs-game-score/lib/provider/players_provider.dart)): Manages player score sheets, round states, phases, and attributes.
* Auto-saving and persistence:
  * Game configurations and player progress are saved to local preferences using `SharedPreferences`.
  * Player state is auto-saved with a **5-second debounce** (`_scheduleSave()`) in the `PlayersNotifier` to prevent excessive write operations.
  * For deep architecture discussions and known issues, refer to [State-Management.md](file:///Users/joefreeman/Documents/GitHub/freemansoft/fs-game-score/docs/State-Management.md).

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
