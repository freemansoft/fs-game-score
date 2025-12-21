<!-- Copilot instructions for fs-game-score -->
# Quick AI coding guide — fs-game-score

Purpose: give an AI coding agent the exact, discoverable knowledge to be productive in this Flutter app.

1) Big picture
- Flutter multi-platform app (mobile, desktop, web). Entry points: [lib/main.dart](lib/main.dart) and [lib/app.dart](lib/app.dart).
- Code organized by feature/concern: `lib/model/`, `lib/presentation/`, `lib/provider/`. Business logic lives in domain/data layers under `lib/model` and provider-backed state in `lib/provider`.

2) Key files and places to inspect
- App entry and routing: [lib/main.dart](lib/main.dart) and [lib/app.dart](lib/app.dart).
- Models and serialization: `lib/model/` (uses `json_serializable` conventions and generated files).
- UI and widgets: `lib/presentation/` (widgets use small private Widget classes and `const` constructors).
- State: `lib/provider/` (uses Flutter built-in state patterns; Riverpod used only when explicitly requested).
- Tests: `test/` (unit & widget tests) and `integration_test/` (integration tests).
- Project rules for AI assistants: see `.cursor/rules/*` (e.g. `.cursor/rules/widgets-holding-player-game-data-keys.mdc`) for repository-specific conventions.

3) Project-specific conventions (must follow)
- File names: `snake_case`. Classes: `PascalCase`. Members/functions: `camelCase`.
- Widget keys: prefer `ValueKey` generator functions (see `.cursor/rules/widgets-holding-player-game-data-keys.mdc`). Tests must use those key helper functions rather than hard-coded key strings.
- JSON: use `json_serializable` + `@JsonSerializable(fieldRename: FieldRename.snake)`. Run codegen after edits.
- Keep `build()` methods small; prefer small private Widget classes instead of long build helper methods.

4) Developer workflows and exact commands
- Install deps: `flutter pub get`
- Run tests: `flutter test` (unit & widget). Integration tests live in `integration_test/`.
- Code generation (required after model changes):
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Run app: `flutter run` (specify `-d` for platform as needed, e.g., `-d macos`).

5) Patterns & examples to mimic
- Key helper functions: create `static ValueKey<String> playerKey(int i)` functions and reuse in tests.
- State choices: prefer `ValueNotifier`/`ChangeNotifier`/Stream for local state; use manual constructor DI for services.
- Serializers: update model class + run `build_runner` to regenerate `*.g.dart`.

6) Integration points & traps
- Native platform code exists under `android/`, `ios/`, `macos/` and CocoaPods are present; avoid editing generated Pod files.
- Build outputs and generated artifacts are in `build/` — do not commit generated files unless a test or CI requires it.

7) Tests & CI hints
- Tests follow Arrange-Act-Assert. Look for existing tests in `test/` (e.g., `game_serialization_test.dart`) for style and assertion patterns.
- When changing models, update tests and run `build_runner` before running `flutter test`.

8) If you need clarification
- Ask which platform target to prioritize (mobile, macOS, web) and whether introducing a new third-party state package (e.g., Riverpod) is approved.

If any section is unclear or you'd like more examples (key function patterns, a sample model+generated file pair, or common test fixtures), tell me which area to expand.
