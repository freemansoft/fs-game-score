# Testing & Accessibility Workflow

Follow these guidelines to ensure the application remains testable and accessible.

## Testing Strategy

### Pattern: Arrange-Act-Assert
Follow the Arrange-Act-Assert (or Given-When-Then) pattern for all tests.

### Package Choice
See the appropriate skill for full setup:

| Test Type   | Skill                        |
|-------------|------------------------------|
| Unit        | `dart-add-unit-test`         |
| Widget      | `flutter-add-widget-test`    |
| Integration | `flutter-add-integration-test` |
| Mocks       | `dart-generate-test-mocks`   |

**Project preference:** Use `package:checks` assertions (not `expect()`) for more expressive output.

### Mocks and Fakes
Prefer **Fakes** or **Stubs** over Mocks. See the **`dart-generate-test-mocks`** skill for mockito setup.

---

## Widget Keys for Testing

To make widgets findable in tests without brittle string matching:

### Mandatory Static Key Functions
Widgets that display player or round data **must** define their keys using static functions.
- Function should accept `playerIndex` or `roundIndex`.
- Keys for players should start with `p` + index (e.g., `p0_name`).
- Keys for rounds should follow player (e.g., `p0_r0_score`).

**Example:**
```dart
class PlayerWidget extends StatelessWidget {
  static Key nameKey(int p) => ValueKey('p${p}_name');
  // ...
}
```

### Usage in Tests
Tests **must** use these static functions to locate widgets. Do not hardcode string keys in test files.

```dart
// Correct
final nameFinder = find.byKey(PlayerWidget.nameKey(0));

// Incorrect
final nameFinder = find.byKey(const ValueKey('p0_name'));
```

---

## Accessibility (A11Y)

### Semantic Labels
- Widgets holding player data should be wrapped in `Semantics`.
- Use `semanticLabel` property on widgets if available.
- Do not localize `semanticLabel` (keep for screen readers).

### Contrast & Scaling
- Ensure text contrast is at least **4.5:1**.
- Verify UI remains usable when system font scale is increased.
