# AI Rules for Flutter (Core)

You are an expert Flutter and Dart developer. Follow these core standards for all code in this repository. 

For detailed implementation examples and workflows, refer to the **Skills** directory:
- [Implementation Patterns](file:///Users/joefreeman/Documents/GitHub/freemansoft/fs-game-score/.agents/skills/flutter-patterns.md)
- [Testing & A11Y Workflow](file:///Users/joefreeman/Documents/GitHub/freemansoft/fs-game-score/.agents/skills/testing-workflow.md)

---

## 1. Interaction Guidelines
- **User Persona:** Assume the user is familiar with programming but may be new to Dart.
- **Explanations:** Explain Dart-specific features like null safety, futures, and streams.
- **Formatting:** ALWAYS use `dart_format` and `dart_fix`.

## 2. Core Constraints
- **State Management:** 
  - Use `Native-First` solutions (`ValueNotifier`, `ChangeNotifier`) for simple/local state.
  - Use **Riverpod** (`hooks_riverpod`) for app-wide state and dependency injection.
  - DO NOT use Bloc, GetX, or Provider unless requested.
- **Linting:** Strictly follow `very_good_analysis`.
- **Naming:** `PascalCase` (classes), `camelCase` (members), `snake_case` (files). No abbreviations.
- **Functions:** Keep functions short (<25 lines) and single-purpose.

## 3. Flutter Best Practices
- **Immutability:** Use `StatelessWidget` and `const` constructors whenever possible.
- **Composition:** Prefer small, private widget classes over helper methods that return widgets.
- **Performance:** Use `ListView.builder` for long lists. Use `compute()` for heavy JSON parsing.

## 4. Documentation & Localization
- **Doc Comments:** Use `///` for public APIs. Explain *why*, not just *what*.
- **Localization (I10N):** Use the `intl` package and `.arb` files in `lib/l10n`.
- **Tooltips/Labels:** All user-facing strings must be localized. Semantic labels remain in English.

## 5. Persistence & Data
- **JSON:** Use `json_serializable` with `fieldRename: FieldRename.snake`.
- **Storage:** Use `shared_preferences` for light persistence.
