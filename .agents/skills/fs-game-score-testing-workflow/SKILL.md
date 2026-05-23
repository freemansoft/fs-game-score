---
name: fs-game-score-testing-workflow
description: >
  Unit, widget, and integration testing patterns, widget keys in tests, and a11y for this app.
  Use when writing or updating tests or accessibility behavior.
---

# FS Score Card — Testing and accessibility

See [docs/State-Management.md — Integration and widget testing](../../../docs/State-Management.md#integration-and-widget-testing).

Always run tests with **`fvm flutter test`** per [AGENTS.md](../../../AGENTS.md).

---

## Test types and skills

| Type | Location | Skill |
| --- | --- | --- |
| Unit | `test/` | `dart-add-unit-test` |
| Widget | `test/` | `flutter-add-widget-test` |
| Integration | `integration_test/` | `flutter-add-integration-test` |
| Mocks | `test/` | `dart-generate-test-mocks` |

Use **Arrange-Act-Assert**. Prefer **fakes/stubs** over mocks where possible (`FakeGameSyncTransport`).

New tests may use **`package:checks`** (`dart-migrate-to-checks-package` skill); existing tests still use **`package:matcher`** / `expect()`.

---

## Unit / widget test setup

- `test/flutter_test_config.dart` — `SharedPreferences.setMockInitialValues({})` before each run.
- Wrap widgets under test in **`ProviderScope`** and override **`sharedPreferencesProvider`** when code touches repositories.

Read notifier state:

```dart
final container = ProviderScope.containerOf(tester.element(find.byType(MyWidget)));
container.read(gameNotifierProvider);
```

Works with **`UncontrolledProviderScope`** from `bootstrapApp()`.

### Project unit tests (examples)

| File | Covers |
| --- | --- |
| `test/players_notifier_persist_test.dart` | Coalesced persist burst, splash clear, in-flight + splash race |
| `test/game_sync_protocol_test.dart` | Wire messages, version matching |
| `test/game_sync_connection_label_test.dart` | Banner / host labels |
| `test/game_sync_mapper_test.dart` | Snapshot ↔ domain mapping |
| `test/game_sync_qr_test.dart`, `test/game_sync_platform_test.dart` | QR URLs, platform gates |
| `test/game_serialization_test.dart` | `Game.fromJson` / new `gameId` behavior |

---

## Integration tests

Helpers: **`integration_test/app_test_helpers.dart`**

| Helper | Purpose |
| --- | --- |
| `clearPersistedGameState()` | `setUp` / `tearDown` — real prefs on devices |
| `await launchApp(tester)` | **`await bootstrapApp()`** — never unawaited `main()` |
| `await launchAppOnSplash(tester)` | Launch + wait for splash Continue button |
| `pumpUntilFound(tester, finder)` | Slow emulators |
| `waitForSplashPlayersCleared(tester)` | After navigating to splash — coalesced persist race |

### Splash player clear

After **New Score Card** or back to splash, assert cleared roster with **`waitForSplashPlayersCleared(tester)`** — not a raw prefs read immediately after `pumpAndSettle`. See [State-Management.md — Splash entry and coalesced persist race](../../../docs/State-Management.md#splash-entry-and-coalesced-persist-race).

---

## Widget keys in tests

Use static key functions from presentation widgets — see **`fs-game-score-widgets-holding-player-game-data`**.

```dart
await tester.tap(find.byKey(PlayerGameCell.nameKey(0)));
await tester.enterText(find.byKey(PlayerRoundModal.scoreFieldKey(0, 1)), '42');
```

Integration tests demonstrate patterns in `integration_test/*_test.dart`.

---

## Live sync testing

Override transport factory:

```dart
gameSyncTransportFactoryProvider.overrideWith(
  (ref) => () => fakeTransport,
);
```

`FakeGameSyncTransport` — `lib/sync/fake_game_sync_transport.dart`. Toggle `pinAccepted`, `appVersionAccepted`, `expectedHostAppVersion`.

Details: **`fs-game-score-live-sync`**, [docs/Game-Sync.md](../../../docs/Game-Sync.md).

---

## Accessibility

- Wrap player-data widgets in **`Semantics`** or set **`semanticLabel`** (English only).
- Target **4.5:1** text contrast; verify UI at increased system font scale.
- Do not localize semantic labels — see widget skill.
