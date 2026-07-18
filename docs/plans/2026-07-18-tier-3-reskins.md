# Tier-3 Reskins (Rummy, Uno, Farkle, Rummikub) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

Planning artifact for **Tier 3** of the [Game-Modes-Roadmap](../Game-Modes-Roadmap.md). Implements [specs/2026-07-18-tier-3-reskins.md](../specs/2026-07-18-tier-3-reskins.md). Not Diátaxis prose — out of scope for the docs-diataxis skill.

**Goal:** Add four named preset game modes — Rummy, Uno, Farkle, Rummikub — as `GameRules` descriptors with localized labels, no new engine primitives.

**Architecture:** Each mode is a `GameMode` value plus a `GameRules` descriptor. The splash mode picker's existing `onChanged` already applies the descriptor's suggested target/filter/rounds, so the only UI change is four new dropdown items.

**Tech Stack:** Flutter/Dart, Riverpod 3, `flutter_test`, `flutter gen-l10n`, `data_table_2`. All commands prefixed with **`fvm`**.

## Global Constraints

- **`fvm` prefix** on every `flutter` / `dart` command.
- **No branching on `GameMode`** — behavior lives in the `GameRules` descriptor.
- **`GameMode.toString()` is the persisted/wire key** — only *append* enum values; never reorder or rename.
- **Mode names untranslated** — identical value in `app_en.arb` / `app_es.arb` / `app_fr.arb`, like `gameModeSkyjo`. Every key exists in all three `.arb` files.
- **Additive wire change** — new `GameMode` values are not a shape change; no major version bump.
- **Existing modes unchanged** — all current tests stay green.
- Run `fvm dart format .`, `fvm flutter analyze`, `fvm flutter test` clean before each commit; run `npm run check:md` before committing markdown.

---

### Task 1: Descriptors and modes (Rummy, Uno, Farkle, Rummikub)

**Files:**
- Modify: `lib/model/game_rules.dart`
- Test: `test/game_rules_test.dart`

**Interfaces:**
- Produces: `GameMode.rummy`, `GameMode.uno`, `GameMode.farkle`, `GameMode.rummikub`, resolvable via `rulesFor`.

- [ ] **Step 1: Write the failing test**

Add to `test/game_rules_test.dart`, inside `group('rulesFor', ...)` (after the hearts round-options tests):

```dart
    test('rummy and uno are high-wins presets to 500', () {
      for (final mode in [GameMode.rummy, GameMode.uno]) {
        final rules = rulesFor(mode);
        expect(rules.roundInput, RoundInput.typedScore);
        expect(rules.winDirection, WinDirection.highestWins);
        expect(rules.allowNegativeScores, isFalse);
        expect(rules.suggestedScoreFilter, ScoreFilters.none);
        expect(rules.suggestedEndGameScore, 500);
      }
    });

    test('farkle is a high-wins preset to 10000 with a 0/5 filter', () {
      final rules = rulesFor(GameMode.farkle);
      expect(rules.winDirection, WinDirection.highestWins);
      expect(rules.suggestedScoreFilter, ScoreFilters.endsWith0or5);
      expect(rules.suggestedEndGameScore, 10000);
      expect(rules.allowNegativeScores, isFalse);
    });

    test('rummikub is a high-wins preset that allows negatives, no target', () {
      final rules = rulesFor(GameMode.rummikub);
      expect(rules.winDirection, WinDirection.highestWins);
      expect(rules.allowNegativeScores, isTrue);
      expect(rules.suggestedScoreFilter, ScoreFilters.none);
      expect(rules.suggestedEndGameScore, 0);
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/game_rules_test.dart`
Expected: FAIL — `GameMode.rummy` etc. undefined.

- [ ] **Step 3: Write minimal implementation**

In `lib/model/game_rules.dart`, **append** to the enum:

```dart
enum GameMode {
  standard,
  phase10,
  frenchDriving,
  skyjo,
  golf,
  hearts,
  rummy,
  uno,
  farkle,
  rummikub,
}
```

Add descriptors after `_heartsRules`:

```dart
const GameRules _rummyRules = GameRules(
  roundInput: RoundInput.typedScore,
  allowNegativeScores: false,
  enablePhases: false,
  numPhases: 0,
  suggestedScoreFilter: ScoreFilters.none,
  suggestedEndGameScore: 500,
  aggregation: ScoreAggregation.sumPerPlayer,
  endCondition: EndCondition.reachTargetHighlight,
  winDirection: WinDirection.highestWins,
  roundOptions: _standardRoundOptions,
  suggestedMaxRounds: _standardSuggestedMaxRounds,
);

const GameRules _unoRules = GameRules(
  roundInput: RoundInput.typedScore,
  allowNegativeScores: false,
  enablePhases: false,
  numPhases: 0,
  suggestedScoreFilter: ScoreFilters.none,
  suggestedEndGameScore: 500,
  aggregation: ScoreAggregation.sumPerPlayer,
  endCondition: EndCondition.reachTargetHighlight,
  winDirection: WinDirection.highestWins,
  roundOptions: _standardRoundOptions,
  suggestedMaxRounds: _standardSuggestedMaxRounds,
);

const GameRules _farkleRules = GameRules(
  roundInput: RoundInput.typedScore,
  allowNegativeScores: false,
  enablePhases: false,
  numPhases: 0,
  // Farkle scores are multiples of 50, so they end in 0 or 5.
  suggestedScoreFilter: ScoreFilters.endsWith0or5,
  suggestedEndGameScore: 10000,
  aggregation: ScoreAggregation.sumPerPlayer,
  endCondition: EndCondition.reachTargetHighlight,
  winDirection: WinDirection.highestWins,
  roundOptions: _standardRoundOptions,
  suggestedMaxRounds: _standardSuggestedMaxRounds,
);

const GameRules _rummikubRules = GameRules(
  roundInput: RoundInput.typedScore,
  // Tiles left in hand count against the player.
  allowNegativeScores: true,
  enablePhases: false,
  numPhases: 0,
  suggestedScoreFilter: ScoreFilters.none,
  suggestedEndGameScore: 0,
  aggregation: ScoreAggregation.sumPerPlayer,
  endCondition: EndCondition.reachTargetHighlight,
  winDirection: WinDirection.highestWins,
  roundOptions: _standardRoundOptions,
  suggestedMaxRounds: _standardSuggestedMaxRounds,
);
```

Register in `_rulesByMode`:

```dart
  GameMode.rummy: _rummyRules,
  GameMode.uno: _unoRules,
  GameMode.farkle: _farkleRules,
  GameMode.rummikub: _rummikubRules,
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `fvm flutter test test/game_rules_test.dart`
Expected: PASS. Then the full model suite:
Run: `fvm flutter test`
Expected: PASS.

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/model/game_rules.dart test/game_rules_test.dart
fvm flutter analyze
git add lib/model/game_rules.dart test/game_rules_test.dart
git commit -m "feat: add Rummy, Uno, Farkle, Rummikub preset game modes"
```

---

### Task 2: Localization — mode names (untranslated)

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_es.arb`, `lib/l10n/app_fr.arb`
- Generated: `lib/l10n/app_localizations*.dart` via `fvm flutter gen-l10n`

**Interfaces:**
- Produces: `l10n.gameModeRummy`, `l10n.gameModeUno`, `l10n.gameModeFarkle`, `l10n.gameModeRummikub`.

- [ ] **Step 1: Add keys to `app_en.arb`** (next to the other `gameMode*` keys)

```json
  "gameModeRummy": "Rummy",
  "@gameModeRummy": {
    "description": "Rummy card game mode option"
  },
  "gameModeUno": "Uno",
  "@gameModeUno": {
    "description": "Uno card game mode option"
  },
  "gameModeFarkle": "Farkle",
  "@gameModeFarkle": {
    "description": "Farkle dice game mode option"
  },
  "gameModeRummikub": "Rummikub",
  "@gameModeRummikub": {
    "description": "Rummikub tile game mode option"
  },
```

- [ ] **Step 2: Mirror the same values into `app_es.arb`** (values only, no `@` metadata)

```json
  "gameModeRummy": "Rummy",
  "gameModeUno": "Uno",
  "gameModeFarkle": "Farkle",
  "gameModeRummikub": "Rummikub",
```

- [ ] **Step 3: Mirror the same values into `app_fr.arb`** (values only, no `@` metadata)

```json
  "gameModeRummy": "Rummy",
  "gameModeUno": "Uno",
  "gameModeFarkle": "Farkle",
  "gameModeRummikub": "Rummikub",
```

- [ ] **Step 4: Verify key parity**

Run:

```bash
python3 -c "import json;k=lambda f:{x for x in json.load(open(f)) if x[0]!='@'};\
b=k('lib/l10n/app_en.arb');[print(l,sorted(b-k(f'lib/l10n/app_{l}.arb'))) for l in('es','fr')]"
```

Expected: `es []` and `fr []`.

- [ ] **Step 5: Regenerate, analyze, test, commit**

```bash
fvm flutter gen-l10n
fvm flutter analyze
fvm flutter test
git add lib/l10n/app_en.arb lib/l10n/app_es.arb lib/l10n/app_fr.arb lib/l10n/app_localizations*.dart
git commit -m "feat: localize Rummy/Uno/Farkle/Rummikub mode names (untranslated)"
```

---

### Task 3: Splash picker — offer the four reskins

**Files:**
- Modify: `lib/presentation/splash_screen.dart`
- Test: `test/splash_game_mode_test.dart`

**Interfaces:**
- Consumes: `GameMode.*` (Task 1), `l10n.gameMode*` (Task 2).

- [ ] **Step 1: Write the failing test**

Add to `test/splash_game_mode_test.dart` a new test (mirror the existing "offers Golf and Hearts" test, which sets a wide viewport and opens the dropdown):

```dart
  testWidgets('game-mode dropdown offers the Tier-3 reskins', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: Scaffold(body: SplashScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
    await tester.pumpAndSettle();

    expect(find.text('Rummy'), findsWidgets);
    expect(find.text('Uno'), findsWidgets);
    expect(find.text('Farkle'), findsWidgets);
    expect(find.text('Rummikub'), findsWidgets);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/splash_game_mode_test.dart`
Expected: FAIL — the four items are not in the dropdown.

- [ ] **Step 3: Write minimal implementation**

In `lib/presentation/splash_screen.dart`, in `_buildGameModeField`, append after the Hearts item:

```dart
              DropdownMenuItem(
                value: GameMode.rummy,
                child: Text(l10n.gameModeRummy),
              ),
              DropdownMenuItem(
                value: GameMode.uno,
                child: Text(l10n.gameModeUno),
              ),
              DropdownMenuItem(
                value: GameMode.farkle,
                child: Text(l10n.gameModeFarkle),
              ),
              DropdownMenuItem(
                value: GameMode.rummikub,
                child: Text(l10n.gameModeRummikub),
              ),
```

No `onChanged` change — it already reads `rulesFor(value)` for target/filter/rounds.

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/splash_game_mode_test.dart`
Expected: PASS.

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/presentation/splash_screen.dart test/splash_game_mode_test.dart
fvm flutter analyze
git add lib/presentation/splash_screen.dart test/splash_game_mode_test.dart
git commit -m "feat: offer Rummy/Uno/Farkle/Rummikub in the splash picker"
```

---

### Task 4: Lean per-mode integration tests

**Files:**
- Modify: `integration_test/app_test.dart`

**Interfaces:**
- Consumes: `GameMode.*` (Task 1), l10n names (Task 2), splash items (Task 3), existing helpers (`launchAppOnSplash`, `waitForScoreTable`) and widget keys.

Each test asserts only that mode's distinctive behavior. Add before the final closing `}` of `main`.

- [ ] **Step 1: Add the four tests**

```dart
  testWidgets('Rummy auto-fills a 500 target and highlights on reaching it', (
    tester,
  ) async {
    await launchAppOnSplash(tester);

    await tester.tap(find.byKey(SplashScreen.numPlayersDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rummy').last);
    await tester.pumpAndSettle();

    // Rummy auto-fills the end-game target with 500.
    expect(
      tester
          .widget<TextField>(find.byKey(SplashScreen.endGameScoreFieldKey))
          .controller
          ?.text,
      '500',
    );

    await tester.tap(find.byKey(SplashScreen.continueButtonKey));
    await waitForScoreTable(tester);

    Future<void> enterRoundScore(int p, int r, String value) async {
      await tester.tap(find.byKey(PlayerRoundCell.scoreKey(p, r)));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(PlayerRoundModal.scoreFieldKey(p, r)),
        value,
      );
      await tester.pumpAndSettle();
      await tester.tapAt(
        tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
      );
      await tester.pumpAndSettle();
    }

    // Reach 500 -> the total is bold (target-highlight).
    await enterRoundScore(0, 0, '300');
    await enterRoundScore(0, 1, '250');
    await tester.pumpAndSettle();
    expect(
      (tester.widget(find.byKey(PlayerGameCell.totalScoreKey(0))) as Text).data,
      '550',
    );
    final total = tester.widget<Text>(
      find.byKey(PlayerGameCell.totalScoreKey(0)),
    );
    expect(total.style?.fontWeight, FontWeight.bold);
  });

  testWidgets('Uno auto-fills a 500 target', (tester) async {
    await launchAppOnSplash(tester);

    await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uno').last);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(find.byKey(SplashScreen.endGameScoreFieldKey))
          .controller
          ?.text,
      '500',
    );

    await tester.tap(find.byKey(SplashScreen.continueButtonKey));
    await waitForScoreTable(tester);

    await tester.tap(find.byKey(PlayerRoundCell.scoreKey(0, 0)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(PlayerRoundModal.scoreFieldKey(0, 0)), '25');
    await tester.pumpAndSettle();
    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
    await tester.pumpAndSettle();

    expect(
      (tester.widget(find.byKey(PlayerGameCell.totalScoreKey(0))) as Text).data,
      '25',
    );
  });

  testWidgets('Farkle auto-fills a 10000 target', (tester) async {
    await launchAppOnSplash(tester);

    await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farkle').last);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(find.byKey(SplashScreen.endGameScoreFieldKey))
          .controller
          ?.text,
      '10000',
    );

    await tester.tap(find.byKey(SplashScreen.continueButtonKey));
    await waitForScoreTable(tester);

    // A valid multiple-of-50 score (ends in 0) is accepted.
    await tester.tap(find.byKey(PlayerRoundCell.scoreKey(0, 0)));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(PlayerRoundModal.scoreFieldKey(0, 0)),
      '1050',
    );
    await tester.pumpAndSettle();
    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
    await tester.pumpAndSettle();

    expect(
      (tester.widget(find.byKey(PlayerGameCell.totalScoreKey(0))) as Text).data,
      '1050',
    );
  });

  testWidgets('Rummikub allows a negative round score', (tester) async {
    await launchAppOnSplash(tester);

    await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rummikub').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SplashScreen.continueButtonKey));
    await waitForScoreTable(tester);

    await tester.tap(find.byKey(PlayerRoundCell.scoreKey(0, 0)));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(PlayerRoundModal.scoreFieldKey(0, 0)),
      '-30',
    );
    await tester.pumpAndSettle();
    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
    await tester.pumpAndSettle();

    expect(
      (tester.widget(find.byKey(PlayerGameCell.totalScoreKey(0))) as Text).data,
      '-30',
    );
  });
```

- [ ] **Step 2: Run the four tests**

Run: `fvm flutter test integration_test/app_test.dart --plain-name "Rummy" -d macos` (repeat for `"Uno"`, `"Farkle"`, `"Rummikub"`), or run the whole file:
Run: `fvm flutter test integration_test/app_test.dart -d macos`
Expected: PASS (all existing + four new).

- [ ] **Step 3: Format, analyze, commit**

```bash
fvm dart format integration_test/app_test.dart
fvm flutter analyze integration_test/app_test.dart
git add integration_test/app_test.dart
git commit -m "test: lean per-mode integration tests for the Tier-3 reskins"
```

---

### Task 5: Documentation

**Files:**
- Modify: `README.md`, `CHANGELOG.md`, `docs/Game-Modes.md`, `docs/Game-Modes-Roadmap.md`

- [ ] **Step 1: README — game-types table**

In `README.md`, add four rows after the Hearts row in the "Scoreboards and game types" table:

```markdown
| **Rummy**    | Standard scoring; selecting Rummy suggests an end-game target of **500** (highest total wins).                     |
| **Uno**      | Standard scoring; selecting Uno suggests an end-game target of **500** (highest total wins).                       |
| **Farkle**   | Standard scoring; selecting Farkle suggests **10,000** and restricts entry to scores ending in **0 or 5**.        |
| **Rummikub** | Standard scoring with **negative round scores** allowed (tiles left in hand); highest total wins, no fixed target. |
```

- [ ] **Step 2: CHANGELOG — unreleased bullet**

In `CHANGELOG.md`, add under `## [2.1.0] - not yet released`:

```markdown
- Added four preset game modes: **Rummy** and **Uno** (suggested target 500), **Farkle** (suggested target 10,000; scores end in 0 or 5), and **Rummikub** (negative round scores allowed). Highest total wins; localized mode names in English, Spanish, and French. See [docs/Game-Modes-Roadmap.md](docs/Game-Modes-Roadmap.md) (Tier 3)
```

- [ ] **Step 3: Game-Modes.md — supported list + per-mode sections**

In `docs/Game-Modes.md`, add to the "Supported modes" list:

```markdown
- Rummy
- Uno
- Farkle
- Rummikub
```

And add four sections before `## System facts for developers`:

```markdown
## Rummy Mode

Standard round scoring. Selecting Rummy suggests an end-game target of **500**; the player with the highest total wins. Round scores are typed directly.

## Uno Mode

Standard round scoring. Selecting Uno suggests an end-game target of **500**; the player with the highest total wins. Round scores are typed directly.

## Farkle Mode

Standard round scoring. Selecting Farkle suggests an end-game target of **10,000** and applies the "ends in 0 or 5" score filter (Farkle scores are multiples of 50). Highest total wins.

## Rummikub Mode

Standard round scoring with **negative round scores** allowed — tiles left in a player's hand count against them. Highest total wins; no fixed end-game target is suggested.
```

- [ ] **Step 4: Roadmap — mark Tier 3 delivered**

In `docs/Game-Modes-Roadmap.md`, under `### Tier 3 — easy reskins (little new machinery)`, add a status line at the top of the section:

```markdown
**Status: ✅ partially delivered** — Rummy, Uno, Farkle, Rummikub, and Golf (Tier 2) ship as descriptor presets. See [spec](specs/2026-07-18-tier-3-reskins.md).
```

- [ ] **Step 5: Format markdown, verify, commit**

```bash
npx prettier --write "README.md" "CHANGELOG.md" "docs/Game-Modes.md" "docs/Game-Modes-Roadmap.md"
npm run check:md
git add README.md CHANGELOG.md docs/Game-Modes.md docs/Game-Modes-Roadmap.md
git commit -m "docs: document Rummy/Uno/Farkle/Rummikub reskin modes"
```

---

## Self-Review

**Spec coverage:**
- Four descriptors (Rummy/Uno 500, Farkle 10000+filter, Rummikub negatives) → Task 1 ✅
- Untranslated l10n names → Task 2 ✅
- Splash picker items (no new logic) → Task 3 ✅
- Lean per-mode integration tests → Task 4 ✅
- Docs (README, CHANGELOG, Game-Modes, roadmap) → Task 5 ✅
- Wire compatibility (additive, no major bump) → no code needed; asserted in spec, unchanged serialization ✅
- Out-of-scope items (no primitives, no custom editors, no translation) → none implemented ✅

**Type consistency:** `GameMode.rummy/uno/farkle/rummikub`, `l10n.gameModeRummy/Uno/Farkle/Rummikub`, `ScoreFilters.endsWith0or5`/`none`, `_standardRoundOptions`, `_standardSuggestedMaxRounds` — all match Task 1 definitions and existing symbols.

**Placeholder scan:** No TBD/TODO; every step has complete code and exact commands.

---

## Execution notes

- Order matters: Task 1 (modes) → Task 2 (l10n names) → Task 3 (splash items) → Task 4 (integration) → Task 5 (docs).
- Run the **full** `fvm flutter test` at Task 1 and Task 2 (cross-cutting).
- Integration tests run on `-d macos` locally; CI runs `flutter test integration_test/app_test.dart` per platform.
