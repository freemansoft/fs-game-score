# Flutter Implementation Patterns

These patterns should be followed when implementing UI, state management, and data handling.

This app uses **Riverpod 3** (`Notifier` / `NotifierProvider`) for app state — see [docs/State-Management.md](../../../docs/State-Management.md). Player edits debounce to disk for 3 seconds (`kPlayersSaveDebounceDuration`). Splash entry must use `prepareForSplashEntry()` (debounced-save race). For **LAN live score sharing** (`gameSyncHostProvider`, `gameSyncSpectatorProvider`, WebSocket handshake, PIN/app version validation), use the **`fs-game-score-live-sync`** skill and [docs/Game-Sync.md](../../../docs/Game-Sync.md).

## State Management

### Simple Local State (ValueNotifier)

Use `ValueNotifier` with `ValueListenableBuilder` for simple, local state that involves a single value.

```dart
// Define a ValueNotifier to hold the state.
final ValueNotifier<int> _counter = ValueNotifier<int>(0);

// Use ValueListenableBuilder to listen and rebuild.
ValueListenableBuilder<int>(
  valueListenable: _counter,
  builder: (context, value, child) {
    return Text('Count: $value');
  },
);
```

### Complex State (ChangeNotifier)

For state that is more complex or shared across multiple widgets, use `ChangeNotifier` with `ListenableBuilder`.

---

## Routing & Navigation

Use `go_router` for all navigation. See the **`flutter-setup-declarative-routing`** skill for full
setup, nested routes, deep linking, and shell navigation patterns.

---

## Data Handling & Serialization

### JSON Serialization

Use `json_serializable` and `json_annotation`. Use `fieldRename: FieldRename.snake` for consistency with JSON keys.

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String firstName;
  final String lastName;

  User({required this.firstName, required this.lastName});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

---

## Visual Design & Theming

### Material 3 Theme Generation

Generate harmonious color palettes from a single seed color.

```dart
final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.outfitTextTheme(),
);
```

### Custom Design Tokens (ThemeExtension)

Use `ThemeExtension` to define custom styles (e.g., semantic colors) that aren't part of standard `ThemeData`.

```dart
@immutable
class MyColors extends ThemeExtension<MyColors> {
  const MyColors({required this.success, required this.danger});

  final Color? success;
  final Color? danger;

  @override
  ThemeExtension<MyColors> copyWith({Color? success, Color? danger}) {
    return MyColors(success: success ?? this.success, danger: danger ?? this.danger);
  }

  @override
  ThemeExtension<MyColors> lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) return this;
    return MyColors(
      success: Color.lerp(success, other.success, t),
      danger: Color.lerp(danger, other.danger, t),
    );
  }
}
```

---

## Advanced UI

### OverlayPortal for Popups/Dropdowns

Use `OverlayPortal` to show UI elements on top of everything else.

```dart
class _MyDropdownState extends State<MyDropdown> {
  final _controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (BuildContext context) {
        return Positioned(
          top: 50,
          left: 10,
          child: Card(child: Text('I am an overlay!')),
        );
      },
      child: ElevatedButton(
        onPressed: _controller.toggle,
        child: const Text('Toggle Overlay'),
      ),
    );
  }
}
```

### Network Images with Error Handling

Always provide `loadingBuilder` and `errorBuilder`.

```dart
Image.network(
  'https://example.com/img.png',
  loadingBuilder: (context, child, progress) => progress == null ? child : const CircularProgressIndicator(),
  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
);
```
