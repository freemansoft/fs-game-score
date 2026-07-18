# Tier-2 Low-Score-Wins (Golf + Hearts) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

Planning artifact for **Tier 2** of the [Game-Modes-Roadmap](../Game-Modes-Roadmap.md). Implements the spec at [specs/2026-07-17-tier-2-low-score-wins.md](../specs/2026-07-17-tier-2-low-score-wins.md). Not Diátaxis prose — this is a design/plan record, out of scope for the docs-diataxis skill.

**Goal:** Add a low-score-wins scoring capability and ship the two games it unlocks — Golf (fixed rounds, lowest total wins) and Hearts (lowest total wins, ends when a player crosses 100).

**Architecture:** A new `WinDirection` descriptor field and a `loserThreshold` end condition are added to `GameRules` (data, not `switch`-on-`GameMode`). `Players.leaderIndices()` is the first cross-player ranking primitive. The score table computes the leader(s) once per build (only in low-wins modes) and passes an `isLeader` flag to `PlayerGameCell`, which renders a leader marker **inside its existing two rows**.

**Tech Stack:** Flutter/Dart, Riverpod 3 (`Notifier`), `flutter_test`, `flutter gen-l10n` (`.arb`), `data_table_2`. All Flutter/Dart commands are prefixed with **`fvm`** per [AGENTS.md](../../AGENTS.md).

## Global Constraints

- **`fvm` prefix** on every `flutter` / `dart` command.
- **No branching on `GameMode`** — per-mode behavior lives in the `GameRules` descriptor (`lib/model/game_rules.dart`); enforced convention.
- **`GameMode.toString()` values are the persisted key** — only *append* enum values; never reorder or rename existing ones.
- **Localize every user-facing string, including semantic labels** — new `Semantics`/`semanticsLabel` strings must be `l10n` calls (custom lint `localize_semantic_labels`). Every key exists in **all three** `.arb` files (en template + es + fr).
- **The player total cell displays exactly two rows** (name row, total row) — new highlights must not add a third row.
- **Existing modes unchanged** — standard, phase10, frenchDriving, skyjo keep identical behavior and existing tests must stay green.
- Run `fvm dart format .`, `fvm flutter analyze`, `fvm flutter test` clean before each commit.

---

### Task 1: Descriptor plumbing — `WinDirection` + `loserThreshold`

Adds the two descriptor axes and defaults every existing mode to today's behavior (high-wins).

**Files:**
- Modify: `lib/model/game_rules.dart`
- Test: `test/game_rules_test.dart`

**Interfaces:**
- Produces: `enum WinDirection { highestWins, lowestWins }`; `EndCondition.loserThreshold`; `GameRules.winDirection` (`WinDirection`, default `WinDirection.highestWins`).

- [ ] **Step 1: Write the failing test**

Add to `test/game_rules_test.dart`, inside `group('rulesFor', ...)`:

```dart
test('existing modes win on the highest total', () {
  for (final mode in [
    GameMode.standard,
    GameMode.phase10,
    GameMode.frenchDriving,
    GameMode.skyjo,
  ]) {
    expect(rulesFor(mode).winDirection, WinDirection.highestWins);
  }
});

test('EndCondition exposes a loserThreshold value', () {
  expect(EndCondition.values, contains(EndCondition.loserThreshold));
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/game_rules_test.dart`
Expected: FAIL — `winDirection` getter and `EndCondition.loserThreshold` are undefined.

- [ ] **Step 3: Write minimal implementation**

In `lib/model/game_rules.dart`:

Add the enum near the other axis enums (after `ScoreAggregation`):

```dart
/// Whether the highest or the lowest total wins.
///
/// Orthogonal to [ScoreAggregation]: win direction and per-player-vs-team
/// roll-up compose independently, so this is its own field rather than more
/// values on [ScoreAggregation].
enum WinDirection { highestWins, lowestWins }
```

Extend `EndCondition`:

```dart
enum EndCondition {
  /// A player whose total reaches the end-game score is highlighted.
  reachTargetHighlight,

  /// The end-game score is a limit: a player crossing it ends the game;
  /// the winner is the lowest total (see [WinDirection.lowestWins]).
  loserThreshold,
}
```

Add the field to `GameRules` — new named param with a default (so the four existing `const` descriptors need no change, matching how `aggregation`/`endCondition` already default):

```dart
  const GameRules({
    required this.roundInput,
    required this.allowNegativeScores,
    required this.enablePhases,
    required this.numPhases,
    required this.suggestedScoreFilter,
    required this.suggestedEndGameScore,
    this.aggregation = ScoreAggregation.sumPerPlayer,
    this.endCondition = EndCondition.reachTargetHighlight,
    this.winDirection = WinDirection.highestWins,
  });
```

And the field declaration (near `aggregation` / `endCondition`):

```dart
  /// Whether the highest or lowest total wins (Tier 0: always
  /// [WinDirection.highestWins]; low-score-wins modes set [WinDirection.lowestWins]).
  final WinDirection winDirection;
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/game_rules_test.dart`
Expected: PASS.

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/model/game_rules.dart test/game_rules_test.dart
fvm flutter analyze
git add lib/model/game_rules.dart test/game_rules_test.dart
git commit -m "feat: add WinDirection field and loserThreshold end condition"
```

---

### Task 2: `Players.leaderIndices()` cross-player primitive

**Files:**
- Modify: `lib/model/players.dart`
- Test: `test/players_leader_test.dart` (create)

**Interfaces:**
- Consumes: `WinDirection` (Task 1).
- Produces: `List<int> Players.leaderIndices(WinDirection dir)` — indices of the extreme-total player(s); ties included; empty until a score exists.

- [ ] **Step 1: Write the failing test**

Create `test/players_leader_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
// game.dart re-exports game_rules.dart (WinDirection).
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/model/players.dart';

void main() {
  group('leaderIndices', () {
    // Builds N players on a single round; null leaves that player's board empty.
    Players build(List<int?> firstRoundScores) {
      final players = Players(
        numPlayers: firstRoundScores.length,
        maxRounds: 1,
      );
      for (var i = 0; i < firstRoundScores.length; i++) {
        final score = firstRoundScores[i];
        if (score != null) players[i].scores.setScore(0, score);
      }
      return players;
    }

    test('empty board returns no leader', () {
      final players = build([null, null, null]);
      expect(players.leaderIndices(WinDirection.lowestWins), isEmpty);
      expect(players.leaderIndices(WinDirection.highestWins), isEmpty);
    });

    test('lowestWins picks the minimum total', () {
      final players = build([10, 3, 7]);
      expect(players.leaderIndices(WinDirection.lowestWins), [1]);
    });

    test('highestWins picks the maximum total', () {
      final players = build([10, 3, 7]);
      expect(players.leaderIndices(WinDirection.highestWins), [0]);
    });

    test('ties return every matching index', () {
      final players = build([5, 5, 9]);
      expect(players.leaderIndices(WinDirection.lowestWins), [0, 1]);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/players_leader_test.dart`
Expected: FAIL — `leaderIndices` is undefined.

- [ ] **Step 3: Write minimal implementation**

In `lib/model/players.dart`, add the import at the top (alongside the existing `player.dart` import):

```dart
import 'package:fs_score_card/model/game_rules.dart';
```

Add the method to the `Players` class (e.g. after `allPlayersEnabledForRound`):

```dart
  /// Indices of the player(s) currently winning under [dir]:
  /// the minimum ([WinDirection.lowestWins]) or maximum total. Ties return
  /// all matching indices. Returns an empty list until at least one score
  /// has been entered, so a fresh 0–0 board highlights no one.
  List<int> leaderIndices(WinDirection dir) {
    final anyScore = players.any(
      (p) => p.scores.roundScores.any((s) => s != null),
    );
    if (players.isEmpty || !anyScore) return const [];

    final totals = players.map((p) => p.totalScore).toList();
    final extreme = dir == WinDirection.lowestWins
        ? totals.reduce((a, b) => a < b ? a : b)
        : totals.reduce((a, b) => a > b ? a : b);

    return [
      for (var i = 0; i < totals.length; i++)
        if (totals[i] == extreme) i,
    ];
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/players_leader_test.dart`
Expected: PASS.

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/model/players.dart test/players_leader_test.dart
fvm flutter analyze
git add lib/model/players.dart test/players_leader_test.dart
git commit -m "feat: add Players.leaderIndices cross-player ranking primitive"
```

---

### Task 3: Golf + Hearts modes and descriptors

**Files:**
- Modify: `lib/model/game_rules.dart`
- Test: `test/game_rules_test.dart`

**Interfaces:**
- Consumes: `WinDirection`, `EndCondition.loserThreshold` (Task 1).
- Produces: `GameMode.golf`, `GameMode.hearts`, resolvable via `rulesFor`.

- [ ] **Step 1: Write the failing test**

Add to `test/game_rules_test.dart`, inside `group('rulesFor', ...)`:

```dart
test('golf mode is typed low-score-wins with no threshold', () {
  final rules = rulesFor(GameMode.golf);
  expect(rules.roundInput, RoundInput.typedScore);
  expect(rules.winDirection, WinDirection.lowestWins);
  expect(rules.endCondition, EndCondition.reachTargetHighlight);
  expect(rules.suggestedEndGameScore, 0);
  expect(rules.allowNegativeScores, isFalse);
});

test('hearts mode is typed low-score-wins with a 100 loser threshold', () {
  final rules = rulesFor(GameMode.hearts);
  expect(rules.roundInput, RoundInput.typedScore);
  expect(rules.winDirection, WinDirection.lowestWins);
  expect(rules.endCondition, EndCondition.loserThreshold);
  expect(rules.suggestedEndGameScore, 100);
});
```

Note: the existing `test('every GameMode resolves to a descriptor', ...)` will now also cover golf/hearts automatically — good.

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/game_rules_test.dart`
Expected: FAIL — `GameMode.golf` / `GameMode.hearts` undefined.

- [ ] **Step 3: Write minimal implementation**

In `lib/model/game_rules.dart`, **append** to the enum (never reorder existing values):

```dart
enum GameMode { standard, phase10, frenchDriving, skyjo, golf, hearts }
```

Add the two descriptors after `_skyjoRules`:

```dart
const GameRules _golfRules = GameRules(
  roundInput: RoundInput.typedScore,
  allowNegativeScores: false,
  enablePhases: false,
  numPhases: 0,
  suggestedScoreFilter: ScoreFilters.none,
  // Golf ends when the fixed rounds are played out; no target line.
  suggestedEndGameScore: 0,
  winDirection: WinDirection.lowestWins,
);

const GameRules _heartsRules = GameRules(
  roundInput: RoundInput.typedScore,
  allowNegativeScores: false,
  enablePhases: false,
  numPhases: 0,
  suggestedScoreFilter: ScoreFilters.none,
  // Hearts: 100 is a loser limit, not a goal — crossing it ends the game.
  suggestedEndGameScore: 100,
  winDirection: WinDirection.lowestWins,
  endCondition: EndCondition.loserThreshold,
);
```

Register both in `_rulesByMode`:

```dart
const Map<GameMode, GameRules> _rulesByMode = {
  GameMode.standard: _standardRules,
  GameMode.phase10: _phase10Rules,
  GameMode.frenchDriving: _frenchDrivingRules,
  GameMode.skyjo: _skyjoRules,
  GameMode.golf: _golfRules,
  GameMode.hearts: _heartsRules,
};
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/game_rules_test.dart`
Expected: PASS. Also run the full model suite to confirm nothing else switches exhaustively on `GameMode`:
Run: `fvm flutter test`
Expected: PASS (if a `switch (mode)` without a default fails to compile, add the golf/hearts cases there — but per the convention there should be none).

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/model/game_rules.dart test/game_rules_test.dart
fvm flutter analyze
git add lib/model/game_rules.dart test/game_rules_test.dart
git commit -m "feat: add Golf and Hearts low-score-wins game modes"
```

---

### Task 4: Localization — mode names + leader semantic label

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_es.arb`, `lib/l10n/app_fr.arb`
- Generated (do not edit by hand): `lib/l10n/app_localizations*.dart` via `fvm flutter gen-l10n`

**Interfaces:**
- Produces: `l10n.gameModeGolf`, `l10n.gameModeHearts` (String); `l10n.playerLeaderLabel(int playerNumber)` (String).

- [ ] **Step 1: Add keys to the template `app_en.arb`**

Add these entries (place mode names next to the other `gameMode*` keys; put `playerLeaderLabel` near the other player labels):

```json
  "gameModeGolf": "Golf",
  "@gameModeGolf": {
    "description": "Golf card game mode option"
  },
  "gameModeHearts": "Hearts",
  "@gameModeHearts": {
    "description": "Hearts card game mode option"
  },
  "playerLeaderLabel": "Player {playerNumber} is leading",
  "@playerLeaderLabel": {
    "description": "Screen-reader label announced on the leading player's total cell",
    "placeholders": {
      "playerNumber": { "type": "int" }
    }
  },
```

- [ ] **Step 2: Mirror values into `app_es.arb`** (values only — no `@` metadata)

```json
  "gameModeGolf": "Golf",
  "gameModeHearts": "Corazones",
  "playerLeaderLabel": "El jugador {playerNumber} va en cabeza",
```

- [ ] **Step 3: Mirror values into `app_fr.arb`** (values only — no `@` metadata)

```json
  "gameModeGolf": "Golf",
  "gameModeHearts": "Cœurs",
  "playerLeaderLabel": "Le joueur {playerNumber} est en tête",
```

- [ ] **Step 4: Verify key parity across all three `.arb` files**

Run:

```bash
python3 -c "import json;k=lambda f:{x for x in json.load(open(f)) if x[0]!='@'};\
b=k('lib/l10n/app_en.arb');[print(l,sorted(b-k(f'lib/l10n/app_{l}.arb'))) for l in('es','fr')]"
```

Expected: `es []` and `fr []` (no missing keys).

- [ ] **Step 5: Regenerate, analyze, test, commit**

```bash
fvm flutter gen-l10n
fvm flutter analyze
fvm flutter test
git add lib/l10n/app_en.arb lib/l10n/app_es.arb lib/l10n/app_fr.arb lib/l10n/app_localizations*.dart
git commit -m "feat: localize Golf/Hearts mode names and leader label (en/es/fr)"
```

---

### Task 5: `PlayerGameCell` leader marker (inside two rows)

**Files:**
- Modify: `lib/presentation/player_game/player_game_cell.dart`
- Test: `test/player_game_cell_test.dart` (create)

**Interfaces:**
- Consumes: `l10n.playerLeaderLabel` (Task 4).
- Produces: `PlayerGameCell({ ..., bool isLeader = false })`. When `isLeader`, the total row renders `Row[Icon(Icons.emoji_events), Text(total)]` in the accent color — still one visual row.

- [ ] **Step 1: Write the failing test**

Create `test/player_game_cell_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/presentation/player_game/player_game_cell.dart';

void main() {
  Widget wrap({required bool isLeader}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: PlayerGameCell(
          playerIdx: 0,
          name: 'Alice',
          totalScore: 3,
          isLeader: isLeader,
          onTap: () {},
        ),
      ),
    );
  }

  testWidgets('shows the leader marker when isLeader is true', (tester) async {
    await tester.pumpWidget(wrap(isLeader: true));
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('shows no leader marker when isLeader is false', (tester) async {
    await tester.pumpWidget(wrap(isLeader: false));
    expect(find.byIcon(Icons.emoji_events), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/player_game_cell_test.dart`
Expected: FAIL — `isLeader` is not a parameter of `PlayerGameCell`.

- [ ] **Step 3: Write minimal implementation**

In `lib/presentation/player_game/player_game_cell.dart`:

Add the constructor param (after `endGameScore`):

```dart
    this.endGameScore = 0,
    this.isLeader = false,
    this.readOnly = false,
```

Add the field (near `endGameScore`):

```dart
  /// Whether this player currently holds the winning total (low-score-wins
  /// modes only). Renders a leader marker inside the total row.
  final bool isLeader;
```

Replace the total `Text(...)` inside the `Column` with a leader-aware total row. Find the existing:

```dart
          Text(
            '$totalScore',
            key: totalScoreKey(playerIdx),
            textAlign: TextAlign.center,
            style: textStyle,
            semanticsLabel: AppLocalizations.of(
              context,
            )!.playerTotalScoreLabel(playerIdx + 1),
          ),
```

Replace it with:

```dart
          if (isLeader)
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                  semanticLabel: AppLocalizations.of(
                    context,
                  )!.playerLeaderLabel(playerIdx + 1),
                ),
                const SizedBox(width: 2),
                Text(
                  '$totalScore',
                  key: totalScoreKey(playerIdx),
                  textAlign: TextAlign.center,
                  style: (textStyle ?? const TextStyle()).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  semanticsLabel: AppLocalizations.of(
                    context,
                  )!.playerTotalScoreLabel(playerIdx + 1),
                ),
              ],
            )
          else
            Text(
              '$totalScore',
              key: totalScoreKey(playerIdx),
              textAlign: TextAlign.center,
              style: textStyle,
              semanticsLabel: AppLocalizations.of(
                context,
              )!.playerTotalScoreLabel(playerIdx + 1),
            ),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/player_game_cell_test.dart`
Expected: PASS.

- [ ] **Step 5: Format, analyze (incl. custom lint), commit**

```bash
fvm dart format lib/presentation/player_game/player_game_cell.dart test/player_game_cell_test.dart
fvm flutter analyze
fvm dart run custom_lint
git add lib/presentation/player_game/player_game_cell.dart test/player_game_cell_test.dart
git commit -m "feat: render leader marker inside the two-row player cell"
```

---

### Task 6: Wire the leader marker into the score table (low-wins only)

**Files:**
- Modify: `lib/presentation/score_table.dart`
- Test: `test/score_table_leader_test.dart` (create)

**Interfaces:**
- Consumes: `Players.leaderIndices` (Task 2), `GameRules.winDirection` (Task 1), `PlayerGameCell.isLeader` (Task 5), `GameMode.golf` (Task 3).

- [ ] **Step 1: Write the failing test**

Create `test/score_table_leader_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/presentation/score_table.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> seed(GameMode mode, int endGameScore) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    await container.read(gameNotifierProvider.notifier).newGame(
          gameMode: mode,
          numPlayers: 3,
          maxRounds: 1,
          endGameScore: endGameScore,
        );
    container.read(playersNotifierProvider.notifier)
      ..updateScore(0, 0, 10)
      ..updateScore(1, 0, 3) // lowest total
      ..updateScore(2, 0, 7);
    return container;
  }

  Widget wrap(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: const Scaffold(
          body: SizedBox(width: 900, height: 600, child: ScoreTable()),
        ),
      ),
    );
  }

  testWidgets('low-wins (Golf) marks the lowest total as leader',
      (tester) async {
    final container = await seed(GameMode.golf, 0);
    await tester.pumpWidget(wrap(container));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
  });

  testWidgets('high-wins (Standard) shows no leader marker', (tester) async {
    final container = await seed(GameMode.standard, 0);
    await tester.pumpWidget(wrap(container));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.emoji_events), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/score_table_leader_test.dart`
Expected: FAIL — the low-wins case finds no `emoji_events` icon (score table does not pass `isLeader` yet).

- [ ] **Step 3: Write minimal implementation**

In `lib/presentation/score_table.dart`, inside `build`, after `game` is resolved and the null guard (right before `final minWidth = ...`), compute the leaders:

```dart
    final rules = game.configuration.rules;
    final leaders = rules.winDirection == WinDirection.lowestWins
        ? players.leaderIndices(rules.winDirection)
        : const <int>[];
```

Then pass it to the cell — update the existing `PlayerGameCell(...)` (around `score_table.dart:142`) to add one argument:

```dart
                PlayerGameCell(
                  playerIdx: playerIdx,
                  name: player.name,
                  totalScore: player.totalScore,
                  endGameScore: game.configuration.endGameScore,
                  isLeader: leaders.contains(playerIdx),
                  readOnly: readOnly,
                  onTap: readOnly
                      ? null
                      : () => _openModal(playerIdx, player, game),
                ),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/score_table_leader_test.dart`
Expected: PASS (Golf finds one icon; Standard finds none).

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/presentation/score_table.dart test/score_table_leader_test.dart
fvm flutter analyze
git add lib/presentation/score_table.dart test/score_table_leader_test.dart
git commit -m "feat: mark the leading player in low-score-wins modes"
```

---

### Task 7: Splash mode picker — offer Golf and Hearts

**Files:**
- Modify: `lib/presentation/splash_screen.dart`
- Test: `test/splash_game_mode_test.dart` (create)

**Interfaces:**
- Consumes: `GameMode.golf` / `GameMode.hearts` (Task 3), `l10n.gameModeGolf` / `l10n.gameModeHearts` (Task 4).

- [ ] **Step 1: Write the failing test**

Create `test/splash_game_mode_test.dart`. This verifies the dropdown exposes the two new entries via their localized labels:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/presentation/splash_screen.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('game-mode dropdown offers Golf and Hearts', (tester) async {
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

    // Open the dropdown.
    await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
    await tester.pumpAndSettle();

    expect(find.text('Golf'), findsWidgets);
    expect(find.text('Hearts'), findsWidgets);
  });
}
```

Note: if `SplashScreen` requires constructor args or a different key name than `gameModeDropdownKey`, adjust to match the actual widget (see `lib/presentation/splash_screen.dart`).

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/splash_game_mode_test.dart`
Expected: FAIL — no "Golf"/"Hearts" items in the dropdown.

- [ ] **Step 3: Write minimal implementation**

In `lib/presentation/splash_screen.dart`, inside `_buildGameModeField`, add two `DropdownMenuItem`s after the `skyjo` item:

```dart
              DropdownMenuItem(
                value: GameMode.golf,
                child: Text(l10n.gameModeGolf),
              ),
              DropdownMenuItem(
                value: GameMode.hearts,
                child: Text(l10n.gameModeHearts),
              ),
```

The existing `onChanged` already reads `rulesFor(value)` for `suggestedScoreFilter` / `suggestedEndGameScore`, so Hearts auto-fills the 100 target and Golf auto-clears it with **no further changes**.

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/splash_game_mode_test.dart`
Expected: PASS.

- [ ] **Step 5: Full suite, format, analyze, commit**

```bash
fvm flutter test
fvm dart format lib/presentation/splash_screen.dart test/splash_game_mode_test.dart
fvm flutter analyze
git add lib/presentation/splash_screen.dart test/splash_game_mode_test.dart
git commit -m "feat: offer Golf and Hearts in the splash game-mode picker"
```

---

### Task 8: Update the roadmap deviation note

Closes the spec's action item: the roadmap said low-vs-high would live in `ScoreAggregation`; we shipped a dedicated `WinDirection` field.

**Files:**
- Modify: `docs/Game-Modes-Roadmap.md`

- [ ] **Step 1: Update the aggregation description**

In `docs/Game-Modes-Roadmap.md`, in the Phase 0 section, find:

```markdown
- **aggregation** (`ScoreAggregation.sumPerPlayer` today; later per-team roll-up, low-vs-high, subtractive);
```

Replace with:

```markdown
- **aggregation** (`ScoreAggregation.sumPerPlayer` today; later per-team roll-up, subtractive) and **win direction** (`WinDirection.highestWins` today; `lowestWins` shipped in Tier 2 for Golf/Hearts) — kept as separate fields because they compose independently;
```

- [ ] **Step 2: Mark Tier 2 delivered**

Find the `### Tier 2 — high leverage, smaller` heading's body and add a status line at its top:

```markdown
**Status: ✅ delivered** as `WinDirection` + `EndCondition.loserThreshold` with `Players.leaderIndices`; ships Golf and Hearts. See [spec](specs/2026-07-17-tier-2-low-score-wins.md).
```

- [ ] **Step 3: Commit**

```bash
git add docs/Game-Modes-Roadmap.md
git commit -m "docs: mark Tier 2 delivered; record WinDirection deviation"
```

---

### Task 9: Full-flow integration test (splash → score table → scores → totals → leader)

End-to-end coverage requested in review: drive the real app from the startup page through scoring, exercising modal score entry/editing, table cell values, totals, and the new leader marker.

**Files:**
- Modify: `integration_test/app_test.dart`

**Interfaces:**
- Consumes: `GameMode.golf` (Task 3), the leader marker (Tasks 5–6), and existing helpers in `integration_test/app_test_helpers.dart` (`launchAppOnSplash`, `waitForScoreTable`) plus widget keys (`SplashScreen.*`, `PlayerRoundCell.scoreKey`, `PlayerRoundModal.scoreFieldKey`, `PlayerGameCell.*`).

- [ ] **Step 1: Add the test** (`integration_test/app_test.dart`, before the final closing `}` of `main`)

```dart
  testWidgets(
    'Golf full flow: splash to scoring, scores, totals, leader, modal edit',
    (tester) async {
      await launchAppOnSplash(tester);

      // Two players keeps the table on-screen.
      await tester.tap(find.byKey(SplashScreen.numPlayersDropdownKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2').last);
      await tester.pumpAndSettle();

      // Select Golf (low-score-wins).
      await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Golf').last);
      await tester.pumpAndSettle();

      // Continue to the score table.
      await tester.tap(find.byKey(SplashScreen.continueButtonKey));
      await waitForScoreTable(tester);

      // Enters a round score through the round modal, then closes it.
      Future<void> enterRoundScore(int p, int r, String value) async {
        await tester.tap(find.byKey(PlayerRoundCell.scoreKey(p, r)));
        await tester.pumpAndSettle();
        expect(find.byType(PlayerRoundModal), findsOneWidget);
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

      String cellText(Key key) =>
          (tester.widget(find.byKey(key)) as Text).data!;

      Finder leaderIn(int playerIdx) => find.descendant(
            of: find.byKey(PlayerGameCell.cellKey(playerIdx)),
            matching: find.byIcon(Icons.emoji_events),
          );

      // Player 0: 20 + 40 = 60.
      await enterRoundScore(0, 0, '20');
      await enterRoundScore(0, 1, '40');
      expect(cellText(PlayerRoundCell.scoreKey(0, 0)), '20');
      expect(cellText(PlayerRoundCell.scoreKey(0, 1)), '40');
      expect(cellText(PlayerGameCell.totalScoreKey(0)), '60');

      // Player 1: 10 + 20 = 30 (the lower total).
      await enterRoundScore(1, 0, '10');
      await enterRoundScore(1, 1, '20');
      expect(cellText(PlayerGameCell.totalScoreKey(1)), '30');

      // Leader marker sits on the lowest total (player 1), not player 0.
      expect(leaderIn(1), findsOneWidget);
      expect(leaderIn(0), findsNothing);

      // Modal score EDITING: change player 0 round 1 from 40 to 5.
      await enterRoundScore(0, 1, '5');
      expect(cellText(PlayerRoundCell.scoreKey(0, 1)), '5');
      expect(cellText(PlayerGameCell.totalScoreKey(0)), '25'); // 20 + 5

      // Player 0 (25) is now below player 1 (30): the leader marker moves.
      expect(leaderIn(0), findsOneWidget);
      expect(leaderIn(1), findsNothing);

      // The player game modal opens from the total cell and shows the name field.
      await tester.tap(find.byKey(PlayerGameCell.cellKey(0)));
      await tester.pumpAndSettle();
      expect(find.byType(PlayerGameModal), findsOneWidget);
      expect(find.byKey(PlayerGameModal.nameFieldKey(0)), findsOneWidget);
      await tester.tapAt(
        tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PlayerGameModal), findsNothing);
    },
  );
```

- [ ] **Step 2: Run the integration test**

Run: `fvm flutter test integration_test/app_test.dart --plain-name "Golf full flow"`
Expected: PASS. (Runs on the headless flutter tester like the other tests in this file.)

- [ ] **Step 3: Format, analyze, commit**

```bash
fvm dart format integration_test/app_test.dart
fvm flutter analyze integration_test/app_test.dart
git add integration_test/app_test.dart
git commit -m "test: full-flow Golf integration test (scores, totals, leader, modal edit)"
```

---

## Self-Review

**Spec coverage:**
- WinDirection field → Task 1 ✅
- loserThreshold end condition → Task 1 ✅
- `Players.leaderIndices` (min/max, ties, empty-board guard) → Task 2 ✅
- Golf + Hearts descriptors/defaults → Task 3 ✅
- Two highlights within two rows (leader marker; bold+italic untouched) → Task 5 ✅
- Leader marker low-wins only + wiring → Task 6 ✅
- l10n en/es/fr (mode names + `playerLeaderLabel`) → Task 4 ✅
- Splash picker offers the modes and auto-applies target → Task 7 ✅
- Tests: game_rules, players, cell widget, table widget, splash → Tasks 1–7 ✅
- Full-flow integration test (splash → scores → totals → modal edit → leader) → Task 9 ✅
- Roadmap deviation action item → Task 8 ✅
- Out-of-scope items (no game-over banner, no ranking beyond 1st, no auto-lock, no per-mode round counts, no custom editor, no teams) → none implemented ✅

**Type consistency:** `WinDirection`, `EndCondition.loserThreshold`, `GameRules.winDirection`, `Players.leaderIndices(WinDirection)`, `PlayerGameCell.isLeader`, `l10n.playerLeaderLabel(int)`, `l10n.gameModeGolf/gameModeHearts` — names/signatures match across all tasks.

**Placeholder scan:** No TBD/TODO; every code step shows complete code and exact commands.

---

## Execution notes

- Tasks are ordered by dependency; execute in sequence.
- Existing modes must stay green — run the **full** `fvm flutter test` at Tasks 3, 4, and 7 (the cross-cutting ones).
- After Task 7, optionally verify in the running app via the `run-fs-game-score` skill: start a Hearts game, enter scores past 100, and confirm the lowest total shows the leader marker while the 100-crosser shows the existing bold+italic.
