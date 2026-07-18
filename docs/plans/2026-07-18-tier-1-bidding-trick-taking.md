# Tier-1A Bidding/Trick-Taking (Oh Hell + Wizard) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

Planning artifact for **Tier 1A** of the [Game-Modes-Roadmap](../Game-Modes-Roadmap.md). Implements [specs/2026-07-18-tier-1-bidding-trick-taking.md](../specs/2026-07-18-tier-1-bidding-trick-taking.md). Not Diátaxis prose — out of scope for docs-diataxis.

**Goal:** Add a bid + tricks → calculated round score primitive and ship two per-player trick-taking games, Oh Hell and Wizard. No teams.

**Architecture:** Mirror the French Driving calculated-score pattern. A `BidTricksRoundAttributes` (bid, tricksTaken) per round; a pure `bidTricksScore(RoundInput, ...)` formula keyed by two new `RoundInput` values; the derived score is written into `Scores` (so the Total column is unchanged). A shared `BidTricksRoundPanel` editor is threaded through the modal/cell/table like the French Driving one.

**Tech Stack:** Flutter/Dart, Riverpod 3, `flutter_test`, `flutter gen-l10n`. Commands prefixed **`fvm`**.

## Global Constraints

- **`fvm` prefix** on every `flutter` / `dart` command.
- **No branching on `GameMode`** — behavior is keyed off descriptor fields (`RoundInput`).
- **`GameMode.toString()` / `RoundInput` values are persisted/wire keys** — only *append* enum values.
- **Mode names untranslated**; **all** `.arb` files hold every key; localize any semantics labels.
- **Additive wire key** — `bidTricksAttributes` added to `Player.toJson`; `Player.fromJson` defaults it when absent. Not a shape-breaking change; no major bump.
- **Existing modes unchanged**; all current tests stay green.
- `fvm dart format .`, `fvm flutter analyze`, `fvm flutter test` clean before each commit; `npm run check:md` before markdown commits.

---

### Task 1: `RoundInput` values, `BidTricksRoundAttributes`, and the formula

**Files:**
- Modify: `lib/model/game_rules.dart` (add two `RoundInput` values)
- Create: `lib/model/bid_tricks_round_attributes.dart`
- Test: `test/bid_tricks_score_test.dart`

**Interfaces:**
- Produces: `RoundInput.calculatedOhHell`, `RoundInput.calculatedWizard`; `class BidTricksRoundAttributes { int bid; int tricksTaken; ... }`; `int bidTricksScore(RoundInput input, {required int bid, required int tricksTaken})`.

- [ ] **Step 1: Write the failing test**

Create `test/bid_tricks_score_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
import 'package:fs_score_card/model/game.dart'; // re-exports RoundInput

void main() {
  group('bidTricksScore', () {
    test('Oh Hell: exact bid scores 10 + bid', () {
      expect(
        bidTricksScore(RoundInput.calculatedOhHell, bid: 3, tricksTaken: 3),
        13,
      );
      expect(
        bidTricksScore(RoundInput.calculatedOhHell, bid: 0, tricksTaken: 0),
        10,
      );
    });

    test('Oh Hell: any miss scores 0', () {
      expect(
        bidTricksScore(RoundInput.calculatedOhHell, bid: 3, tricksTaken: 2),
        0,
      );
      expect(
        bidTricksScore(RoundInput.calculatedOhHell, bid: 1, tricksTaken: 4),
        0,
      );
    });

    test('Wizard: exact bid scores 20 + 10*bid', () {
      expect(
        bidTricksScore(RoundInput.calculatedWizard, bid: 2, tricksTaken: 2),
        40,
      );
      expect(
        bidTricksScore(RoundInput.calculatedWizard, bid: 0, tricksTaken: 0),
        20,
      );
    });

    test('Wizard: miss scores -10 per trick over/under', () {
      expect(
        bidTricksScore(RoundInput.calculatedWizard, bid: 3, tricksTaken: 5),
        -20,
      );
      expect(
        bidTricksScore(RoundInput.calculatedWizard, bid: 4, tricksTaken: 1),
        -30,
      );
    });

    test('non-bid RoundInput scores 0', () {
      expect(
        bidTricksScore(RoundInput.typedScore, bid: 3, tricksTaken: 3),
        0,
      );
    });
  });

  group('BidTricksRoundAttributes', () {
    test('round-trips through JSON', () {
      final attrs = BidTricksRoundAttributes(bid: 3, tricksTaken: 2);
      final restored = BidTricksRoundAttributes.fromJson(attrs.toJson());
      expect(restored.bid, 3);
      expect(restored.tricksTaken, 2);
    });

    test('fromJson defaults missing fields to 0', () {
      final restored = BidTricksRoundAttributes.fromJson(<String, dynamic>{});
      expect(restored.bid, 0);
      expect(restored.tricksTaken, 0);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/bid_tricks_score_test.dart`
Expected: FAIL — `bid_tricks_round_attributes.dart` and the `RoundInput` values don't exist.

- [ ] **Step 3: Write minimal implementation**

In `lib/model/game_rules.dart`, extend `RoundInput`:

```dart
enum RoundInput {
  /// The scorekeeper types the round score directly.
  typedScore,

  /// The round score is calculated from French Driving round attributes.
  calculatedFrenchDriving,

  /// The round score is calculated from a bid + tricks taken (Oh Hell).
  calculatedOhHell,

  /// The round score is calculated from a bid + tricks taken (Wizard).
  calculatedWizard,
}
```

Create `lib/model/bid_tricks_round_attributes.dart`:

```dart
import 'package:fs_score_card/model/game_rules.dart';

/// Per-round inputs for a bid/tricks trick-taking game (Oh Hell, Wizard).
class BidTricksRoundAttributes {
  BidTricksRoundAttributes({this.bid = 0, this.tricksTaken = 0});

  factory BidTricksRoundAttributes.fromJson(Map<String, dynamic> json) {
    return BidTricksRoundAttributes(
      bid: (json['bid'] as num?)?.toInt() ?? 0,
      tricksTaken: (json['tricksTaken'] as num?)?.toInt() ?? 0,
    );
  }

  final int bid;
  final int tricksTaken;

  Map<String, dynamic> toJson() => {'bid': bid, 'tricksTaken': tricksTaken};

  BidTricksRoundAttributes copyWith({int? bid, int? tricksTaken}) {
    return BidTricksRoundAttributes(
      bid: bid ?? this.bid,
      tricksTaken: tricksTaken ?? this.tricksTaken,
    );
  }
}

/// Round score for a bid/tricks game, keyed by the descriptor's [RoundInput].
///
/// Oh Hell: making the bid exactly scores `10 + bid`; any miss scores 0.
/// Wizard: exact scores `20 + 10 * bid`; a miss scores `-10` per trick
/// over or under the bid.
int bidTricksScore(
  RoundInput input, {
  required int bid,
  required int tricksTaken,
}) {
  final exact = bid == tricksTaken;
  return switch (input) {
    RoundInput.calculatedOhHell => exact ? 10 + bid : 0,
    RoundInput.calculatedWizard =>
      exact ? 20 + 10 * bid : -10 * (bid - tricksTaken).abs(),
    RoundInput.typedScore || RoundInput.calculatedFrenchDriving => 0,
  };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/bid_tricks_score_test.dart`
Expected: PASS. Then `fvm flutter test` (the exhaustive `switch (roundInput)` in `player_round_modal.dart` uses a boolean check, not a switch, so adding values does not break it — confirm the suite stays green).

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/model/game_rules.dart lib/model/bid_tricks_round_attributes.dart test/bid_tricks_score_test.dart
fvm flutter analyze
git add lib/model/game_rules.dart lib/model/bid_tricks_round_attributes.dart test/bid_tricks_score_test.dart
git commit -m "feat: add bid/tricks round attributes and scoring formula"
```

---

### Task 2: `Player.bidTricksAttributes` (additive, back-compatible)

**Files:**
- Modify: `lib/model/player.dart`
- Test: `test/bid_tricks_serialization_test.dart`

**Interfaces:**
- Consumes: `BidTricksRoundAttributes` (Task 1).
- Produces: `Player.bidTricksAttributes` (`List<BidTricksRoundAttributes>`), serialized under `'bidTricksAttributes'`, defaulted when the key is absent.

- [ ] **Step 1: Write the failing test**

Create `test/bid_tricks_serialization_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
import 'package:fs_score_card/model/player.dart';

void main() {
  test('Player round-trips bidTricksAttributes', () {
    final player = Player(name: 'A', maxRounds: 3);
    player.bidTricksAttributes[0] = BidTricksRoundAttributes(
      bid: 2,
      tricksTaken: 2,
    );
    final restored = Player.fromJson(player.toJson());
    expect(restored.bidTricksAttributes.length, 3);
    expect(restored.bidTricksAttributes[0].bid, 2);
    expect(restored.bidTricksAttributes[0].tricksTaken, 2);
  });

  test('Player.fromJson defaults bidTricksAttributes when key absent', () {
    // Simulate an older snapshot that predates the field.
    final json = Player(name: 'B', maxRounds: 4).toJson()
      ..remove('bidTricksAttributes');
    final restored = Player.fromJson(json);
    // Padded to the score length so bid/tricks modes never index out of range.
    expect(restored.bidTricksAttributes.length, 4);
    expect(restored.bidTricksAttributes[0].bid, 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/bid_tricks_serialization_test.dart`
Expected: FAIL — `bidTricksAttributes` is not a member of `Player`.

- [ ] **Step 3: Write minimal implementation**

In `lib/model/player.dart`:

Add the import:

```dart
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
```

Main constructor — generate the list:

```dart
  Player({required this.name, required int maxRounds})
    : scores = Scores(maxRounds),
      phases = Phases(maxRounds),
      frenchDrivingAttributes = List.generate(
        maxRounds,
        (_) => FrenchDrivingRoundAttributes(),
      ),
      bidTricksAttributes = List.generate(
        maxRounds,
        (_) => BidTricksRoundAttributes(),
      ),
      roundStates = RoundStates(maxRounds);
```

`Player.withData` — optional named param, defaulted from `scores` length (keeps existing callers working):

```dart
  Player.withData({
    required this.name,
    required this.scores,
    required this.phases,
    required this.frenchDrivingAttributes,
    List<BidTricksRoundAttributes>? bidTricksAttributes,
    RoundStates? roundStates,
  }) : bidTricksAttributes =
           bidTricksAttributes ??
           List.generate(
             scores.roundScores.length,
             (_) => BidTricksRoundAttributes(),
           ),
       roundStates = roundStates ?? RoundStates(scores.roundScores.length);
```

`Player.fromJson` — parse or **pad to the score length** when absent:

```dart
      bidTricksAttributes =
          (json['bidTricksAttributes'] as List<dynamic>?)
              ?.map(
                (e) =>
                    BidTricksRoundAttributes.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          List.generate(
            (json['scores'] as List<dynamic>).length,
            (_) => BidTricksRoundAttributes(),
          ),
```

`copyWith` — add the param and pass through:

```dart
    List<BidTricksRoundAttributes>? bidTricksAttributes,
```
```dart
      bidTricksAttributes:
          bidTricksAttributes ??
          this.bidTricksAttributes.map((e) => e.copyWith()).toList(),
```

Field declaration (near `frenchDrivingAttributes`):

```dart
  final List<BidTricksRoundAttributes> bidTricksAttributes;
```

`toJson` — add the key:

```dart
    'bidTricksAttributes': bidTricksAttributes.map((e) => e.toJson()).toList(),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/bid_tricks_serialization_test.dart`
Expected: PASS. Then `fvm flutter test` — the existing player serialization/export tests must stay green (the new key is additive).

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/model/player.dart test/bid_tricks_serialization_test.dart
fvm flutter analyze
git add lib/model/player.dart test/bid_tricks_serialization_test.dart
git commit -m "feat: persist bidTricksAttributes on Player (additive, defaulted)"
```

---

### Task 3: Oh Hell + Wizard modes and descriptors

**Files:**
- Modify: `lib/model/game_rules.dart`
- Test: `test/game_rules_test.dart`

**Interfaces:**
- Produces: `GameMode.ohHell`, `GameMode.wizard`.

- [ ] **Step 1: Write the failing test**

Add to `test/game_rules_test.dart`, inside `group('rulesFor', ...)`:

```dart
    test('oh hell is a calculated bid/tricks mode, high-wins, no negatives', () {
      final rules = rulesFor(GameMode.ohHell);
      expect(rules.roundInput, RoundInput.calculatedOhHell);
      expect(rules.winDirection, WinDirection.highestWins);
      expect(rules.allowNegativeScores, isFalse);
      expect(rules.suggestedEndGameScore, 0);
    });

    test('wizard is a calculated bid/tricks mode allowing negatives', () {
      final rules = rulesFor(GameMode.wizard);
      expect(rules.roundInput, RoundInput.calculatedWizard);
      expect(rules.winDirection, WinDirection.highestWins);
      expect(rules.allowNegativeScores, isTrue);
      expect(rules.suggestedEndGameScore, 0);
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/game_rules_test.dart`
Expected: FAIL — `GameMode.ohHell` / `GameMode.wizard` undefined.

- [ ] **Step 3: Write minimal implementation**

In `lib/model/game_rules.dart`, append to the enum:

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
  ohHell,
  wizard,
}
```

Add descriptors after `_rummikubRules`:

```dart
const GameRules _ohHellRules = GameRules(
  roundInput: RoundInput.calculatedOhHell,
  allowNegativeScores: false,
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

const GameRules _wizardRules = GameRules(
  roundInput: RoundInput.calculatedWizard,
  // A missed bid scores negative in Wizard.
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
  GameMode.ohHell: _ohHellRules,
  GameMode.wizard: _wizardRules,
```

- [ ] **Step 4: Run tests**

Run: `fvm flutter test test/game_rules_test.dart` then `fvm flutter test`
Expected: PASS.

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/model/game_rules.dart test/game_rules_test.dart
fvm flutter analyze
git add lib/model/game_rules.dart test/game_rules_test.dart
git commit -m "feat: add Oh Hell and Wizard bid/tricks game modes"
```

---

### Task 4: `PlayersNotifier.updateBidTricksAttributes`

**Files:**
- Modify: `lib/provider/players_provider.dart`
- Test: `test/bid_tricks_provider_test.dart`

**Interfaces:**
- Consumes: `BidTricksRoundAttributes`, `bidTricksScore` (Task 1), Oh Hell/Wizard modes (Task 3).
- Produces: `PlayersNotifier.updateBidTricksAttributes(int playerIdx, int round, BidTricksRoundAttributes attributes)`.

- [ ] **Step 1: Write the failing test**

Create `test/bid_tricks_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
import 'package:fs_score_card/model/game.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('updateBidTricksAttributes writes the calculated Oh Hell score', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await container
        .read(gameNotifierProvider.notifier)
        .newGame(gameMode: GameMode.ohHell, numPlayers: 2, maxRounds: 3);

    container.read(playersNotifierProvider.notifier).updateBidTricksAttributes(
          0,
          0,
          BidTricksRoundAttributes(bid: 3, tricksTaken: 3),
        );

    final players = container.read(playersNotifierProvider)!;
    // Exact bid -> 10 + 3 = 13 stored in scores.
    expect(players[0].scores.getScore(0), 13);
    expect(players[0].bidTricksAttributes[0].bid, 3);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/bid_tricks_provider_test.dart`
Expected: FAIL — `updateBidTricksAttributes` undefined.

- [ ] **Step 3: Write minimal implementation**

In `lib/provider/players_provider.dart`, add after `updateFrenchDrivingAttributes` (mirror it). Reference the existing method for the exact state-update + persist idiom:

```dart
  void updateBidTricksAttributes(
    int playerIdx,
    int round,
    BidTricksRoundAttributes attributes,
  ) {
    final player = state![playerIdx];
    player.bidTricksAttributes[round] = attributes;
    final rules = ref.read(gameNotifierProvider).configuration.rules;
    player.scores.setScore(
      round,
      bidTricksScore(
        rules.roundInput,
        bid: attributes.bid,
        tricksTaken: attributes.tricksTaken,
      ),
    );
    _requestPersist();
  }
```

Add the import if not present:

```dart
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
```

Note: match the exact `state` access idiom used by `updateFrenchDrivingAttributes` (it references the same `state`/`player` shape — copy that method's structure verbatim, swapping the attribute list and score computation).

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/bid_tricks_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/provider/players_provider.dart test/bid_tricks_provider_test.dart
fvm flutter analyze
git add lib/provider/players_provider.dart test/bid_tricks_provider_test.dart
git commit -m "feat: updateBidTricksAttributes writes the calculated round score"
```

---

### Task 5: Localization — mode names and panel labels

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_es.arb`, `lib/l10n/app_fr.arb`
- Generated: `lib/l10n/app_localizations*.dart`

**Interfaces:**
- Produces: `l10n.gameModeOhHell`, `l10n.gameModeWizard`, `l10n.bidLabel`, `l10n.tricksTakenLabel`.

- [ ] **Step 1: Add keys to `app_en.arb`**

```json
  "gameModeOhHell": "Oh Hell",
  "@gameModeOhHell": {
    "description": "Oh Hell trick-taking game mode option"
  },
  "gameModeWizard": "Wizard",
  "@gameModeWizard": {
    "description": "Wizard trick-taking game mode option"
  },
  "bidLabel": "Bid",
  "@bidLabel": {
    "description": "Label for the bid input in the bid/tricks round editor"
  },
  "tricksTakenLabel": "Tricks taken",
  "@tricksTakenLabel": {
    "description": "Label for the tricks-taken input in the bid/tricks round editor"
  },
```

- [ ] **Step 2: Mirror the same values into `app_es.arb`** (values only)

```json
  "gameModeOhHell": "Oh Hell",
  "gameModeWizard": "Wizard",
  "bidLabel": "Apuesta",
  "tricksTakenLabel": "Bazas ganadas",
```

- [ ] **Step 3: Mirror the same values into `app_fr.arb`** (values only)

```json
  "gameModeOhHell": "Oh Hell",
  "gameModeWizard": "Wizard",
  "bidLabel": "Annonce",
  "tricksTakenLabel": "Plis réalisés",
```

- [ ] **Step 4: Verify parity**

```bash
python3 -c "import json;k=lambda f:{x for x in json.load(open(f)) if x[0]!='@'};\
b=k('lib/l10n/app_en.arb');[print(l,sorted(b-k(f'lib/l10n/app_{l}.arb'))) for l in('es','fr')]"
```

Expected: `es []`, `fr []`.

- [ ] **Step 5: Regenerate, analyze, test, commit**

```bash
fvm flutter gen-l10n
fvm flutter analyze
fvm flutter test
git add lib/l10n/app_en.arb lib/l10n/app_es.arb lib/l10n/app_fr.arb lib/l10n/app_localizations*.dart
git commit -m "feat: localize Oh Hell/Wizard names and bid/tricks labels"
```

---

### Task 6: `BidTricksRoundPanel` editor

**Files:**
- Create: `lib/presentation/player_round/bid_tricks_round_panel.dart`
- Test: `test/bid_tricks_round_panel_test.dart`

**Interfaces:**
- Consumes: `BidTricksRoundAttributes` (Task 1), `l10n.bidLabel` / `l10n.tricksTakenLabel` (Task 5).
- Produces: `BidTricksRoundPanel({required attributes, required onChanged})` with static `bidFieldKey`, `tricksFieldKey`.

- [ ] **Step 1: Write the failing test**

Create `test/bid_tricks_round_panel_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
import 'package:fs_score_card/presentation/player_round/bid_tricks_round_panel.dart';

void main() {
  Widget wrap(ValueChanged<BidTricksRoundAttributes> onChanged) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: BidTricksRoundPanel(
          attributes: BidTricksRoundAttributes(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  testWidgets('entering a bid emits updated attributes', (tester) async {
    BidTricksRoundAttributes? latest;
    await tester.pumpWidget(wrap((a) => latest = a));

    await tester.enterText(
      find.byKey(BidTricksRoundPanel.bidFieldKey),
      '3',
    );
    await tester.pump();
    expect(latest?.bid, 3);

    await tester.enterText(
      find.byKey(BidTricksRoundPanel.tricksFieldKey),
      '2',
    );
    await tester.pump();
    expect(latest?.tricksTaken, 2);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/bid_tricks_round_panel_test.dart`
Expected: FAIL — the panel does not exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/presentation/player_round/bid_tricks_round_panel.dart`. Model the controller/onChanged idiom on `french_driving_round_panel.dart` (a `StatefulWidget` holding local attributes + `TextEditingController`s that call `widget.onChanged` on edit):

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';

class BidTricksRoundPanel extends StatefulWidget {
  const BidTricksRoundPanel({
    super.key,
    required this.attributes,
    required this.onChanged,
  });

  final BidTricksRoundAttributes attributes;
  final ValueChanged<BidTricksRoundAttributes> onChanged;

  static const ValueKey<String> bidFieldKey = ValueKey<String>('bt_bid_field');
  static const ValueKey<String> tricksFieldKey = ValueKey<String>(
    'bt_tricks_field',
  );

  @override
  State<BidTricksRoundPanel> createState() => _BidTricksRoundPanelState();
}

class _BidTricksRoundPanelState extends State<BidTricksRoundPanel> {
  late final TextEditingController _bidController;
  late final TextEditingController _tricksController;

  @override
  void initState() {
    super.initState();
    _bidController = TextEditingController(
      text: widget.attributes.bid.toString(),
    );
    _tricksController = TextEditingController(
      text: widget.attributes.tricksTaken.toString(),
    );
  }

  @override
  void dispose() {
    _bidController.dispose();
    _tricksController.dispose();
    super.dispose();
  }

  void _emit({int? bid, int? tricksTaken}) {
    widget.onChanged(
      widget.attributes.copyWith(bid: bid, tricksTaken: tricksTaken),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            key: BidTricksRoundPanel.bidFieldKey,
            controller: _bidController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.bidLabel),
            onChanged: (v) => _emit(bid: int.tryParse(v) ?? 0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            key: BidTricksRoundPanel.tricksFieldKey,
            controller: _tricksController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.tricksTakenLabel),
            onChanged: (v) => _emit(tricksTaken: int.tryParse(v) ?? 0),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/bid_tricks_round_panel_test.dart`
Expected: PASS.

- [ ] **Step 5: Format, analyze, custom-lint, commit**

```bash
fvm dart format lib/presentation/player_round/bid_tricks_round_panel.dart test/bid_tricks_round_panel_test.dart
fvm flutter analyze
fvm dart run custom_lint
git add lib/presentation/player_round/bid_tricks_round_panel.dart test/bid_tricks_round_panel_test.dart
git commit -m "feat: add bid/tricks round editor panel"
```

---

### Task 7: Wire the panel through the modal, cell, table, and splash

**Files:**
- Modify: `lib/presentation/player_round/player_round_modal.dart`
- Modify: `lib/presentation/player_round/player_round_cell.dart`
- Modify: `lib/presentation/score_table.dart`
- Modify: `lib/presentation/splash_screen.dart`
- Test: `test/splash_game_mode_test.dart`

**Interfaces:**
- Consumes: `BidTricksRoundPanel` (Task 6), `updateBidTricksAttributes` (Task 4), Oh Hell/Wizard modes + l10n names.
- Produces: a threaded `onBidTricksAttributesChanged` callback; splash picker items.

- [ ] **Step 1: Write the failing test** (splash picker offers the modes)

Add to `test/splash_game_mode_test.dart` (mirror the existing Tier-3 reskins picker test, but asserting the two names):

```dart
  testWidgets('game-mode dropdown offers Oh Hell and Wizard', (tester) async {
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

    expect(find.text('Oh Hell'), findsWidgets);
    expect(find.text('Wizard'), findsWidgets);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/splash_game_mode_test.dart`
Expected: FAIL — items not present.

- [ ] **Step 3: Wire everything**

**a. `player_round_modal.dart`** — add the callback prop (parallel to `onFrenchDrivingAttributesChanged`):

Constructor param + field:
```dart
    required this.onBidTricksAttributesChanged,
```
```dart
  final ValueChanged<BidTricksRoundAttributes> onBidTricksAttributesChanged;
```
Import:
```dart
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
import 'package:fs_score_card/presentation/player_round/bid_tricks_round_panel.dart';
```
In `build`, next to `showFrenchDrivingPanel`:
```dart
    final showBidTricksPanel =
        rules.roundInput == RoundInput.calculatedOhHell ||
        rules.roundInput == RoundInput.calculatedWizard;
```
Render it in **both** the landscape and portrait branches (place beside the French Driving panel blocks):
```dart
                      if (showBidTricksPanel) ...[
                        const SizedBox(height: 16),
                        BidTricksRoundPanel(
                          attributes: player.bidTricksAttributes[widget.round],
                          onChanged: widget.onBidTricksAttributesChanged,
                        ),
                      ],
```
(The score field is already read-only for non-`typedScore` modes via `enabled: typedScore`, so no change there.)

**b. `player_round_cell.dart`** — add the prop and pass it to the modal:
```dart
    required this.onBidTricksAttributesChanged,
```
```dart
  final ValueChanged<BidTricksRoundAttributes> onBidTricksAttributesChanged;
```
```dart
import 'package:fs_score_card/model/bid_tricks_round_attributes.dart';
```
Where it constructs `PlayerRoundModal(...)`:
```dart
      onBidTricksAttributesChanged: onBidTricksAttributesChanged,
```

**c. `score_table.dart`** — pass the callback when constructing `PlayerRoundCell` (mirror `onFrenchDrivingAttributesChanged`):
```dart
                    onBidTricksAttributesChanged: readOnly
                        ? (_) {}
                        : (attrs) {
                            ref
                                .read(playersNotifierProvider.notifier)
                                .updateBidTricksAttributes(
                                  playerIdx,
                                  round,
                                  attrs,
                                );
                          },
```

**d. `splash_screen.dart`** — append two dropdown items in `_buildGameModeField` after the Rummikub item:
```dart
              DropdownMenuItem(
                value: GameMode.ohHell,
                child: Text(l10n.gameModeOhHell),
              ),
              DropdownMenuItem(
                value: GameMode.wizard,
                child: Text(l10n.gameModeWizard),
              ),
```

- [ ] **Step 4: Run tests**

Run: `fvm flutter test test/splash_game_mode_test.dart` then `fvm flutter test`
Expected: PASS (widget/unit suite green; the new required props are satisfied at the single call sites).

- [ ] **Step 5: Format, analyze, commit**

```bash
fvm dart format lib/presentation/player_round/player_round_modal.dart lib/presentation/player_round/player_round_cell.dart lib/presentation/score_table.dart lib/presentation/splash_screen.dart test/splash_game_mode_test.dart
fvm flutter analyze
git add lib/presentation/ test/splash_game_mode_test.dart
git commit -m "feat: wire bid/tricks panel through modal, cell, table, and splash"
```

---

### Task 8: Lean per-mode integration tests

**Files:**
- Modify: `integration_test/app_test.dart`

**Interfaces:**
- Consumes: everything above + existing helpers/keys, plus `BidTricksRoundPanel.bidFieldKey` / `tricksFieldKey`.

- [ ] **Step 1: Add the two tests** (before the final `}` of `main`)

```dart
  testWidgets('Oh Hell computes the round score from bid and tricks', (
    tester,
  ) async {
    await launchAppOnSplash(tester);

    await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oh Hell').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SplashScreen.continueButtonKey));
    await waitForScoreTable(tester);

    // Open the round editor for player 0, round 0.
    await tester.tap(find.byKey(PlayerRoundCell.scoreKey(0, 0)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(BidTricksRoundPanel.bidFieldKey), '3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(BidTricksRoundPanel.tricksFieldKey), '3');
    await tester.pumpAndSettle();

    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
    await tester.pumpAndSettle();

    // Exact bid of 3 -> 10 + 3 = 13.
    expect(
      (tester.widget(find.byKey(PlayerRoundCell.scoreKey(0, 0))) as Text).data,
      '13',
    );
    expect(
      (tester.widget(find.byKey(PlayerGameCell.totalScoreKey(0))) as Text).data,
      '13',
    );
  });

  testWidgets('Wizard scores a missed bid negative', (tester) async {
    await launchAppOnSplash(tester);

    await tester.tap(find.byKey(SplashScreen.gameModeDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wizard').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SplashScreen.continueButtonKey));
    await waitForScoreTable(tester);

    await tester.tap(find.byKey(PlayerRoundCell.scoreKey(0, 0)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(BidTricksRoundPanel.bidFieldKey), '3');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(BidTricksRoundPanel.tricksFieldKey), '5');
    await tester.pumpAndSettle();

    await tester.tapAt(
      tester.getTopLeft(find.byType(Phase10App)).translate(5, 5),
    );
    await tester.pumpAndSettle();

    // Missed by 2 -> -10 * 2 = -20.
    expect(
      (tester.widget(find.byKey(PlayerGameCell.totalScoreKey(0))) as Text).data,
      '-20',
    );
  });
```

Add the import at the top of `integration_test/app_test.dart`:
```dart
import 'package:fs_score_card/presentation/player_round/bid_tricks_round_panel.dart';
```

- [ ] **Step 2: Run the two tests**

Run: `fvm flutter test integration_test/app_test.dart --plain-name "Oh Hell" -d macos` and `--plain-name "Wizard"`, then the whole file:
Run: `fvm flutter test integration_test/app_test.dart -d macos`
Expected: PASS (all existing + two new).

- [ ] **Step 3: Format, analyze, commit**

```bash
fvm dart format integration_test/app_test.dart
fvm flutter analyze integration_test/app_test.dart
git add integration_test/app_test.dart
git commit -m "test: integration tests for Oh Hell and Wizard bid/tricks scoring"
```

---

### Task 9: Documentation

**Files:**
- Modify: `README.md`, `CHANGELOG.md`, `docs/Game-Modes.md`, `docs/Game-Modes-Roadmap.md`

- [ ] **Step 1: README — game-types table** (two rows after Rummikub)

```markdown
| **Oh Hell** | Bid the tricks you'll take; the round score is **calculated** — make it exactly for `10 + bid`, miss for `0`. Highest total wins. |
| **Wizard**  | Bid tricks; the round score is **calculated** — exact for `20 + 10×bid`, a miss for `−10` per trick over/under (negatives allowed). Highest total wins. |
```

- [ ] **Step 2: CHANGELOG — unreleased bullet**

```markdown
- Added two trick-taking game modes with **calculated bid/tricks scoring**: **Oh Hell** (exact bid → 10 + bid, miss → 0) and **Wizard** (exact → 20 + 10×bid, miss → −10 per trick). Localized in English, Spanish, and French. See [docs/Game-Modes-Roadmap.md](docs/Game-Modes-Roadmap.md) (Tier 1A)
```

- [ ] **Step 3: Game-Modes.md — supported list + sections**

Add to the list:
```markdown
- Oh Hell
- Wizard
```
Add sections before `## System facts for developers`:
```markdown
## Oh Hell Mode

A trick-taking game with a **calculated** round score. Each round a player enters their **bid** and the **tricks taken**; if they match exactly the round scores `10 + bid`, otherwise `0`. Highest total wins. Uses the bid/tricks round editor.

## Wizard Mode

A trick-taking game with a **calculated** round score. Each round a player enters their **bid** and **tricks taken**; an exact bid scores `20 + 10 × bid`, and a miss scores `-10` for each trick over or under (negative round scores allowed). Highest total wins.
```

- [ ] **Step 4: Roadmap — mark Tier 1A delivered**

In `docs/Game-Modes-Roadmap.md`, under `### Tier 1 — build first`, add after the intro paragraph:
```markdown
**Status: 🟡 1A delivered** — the bid/tricks calculated-score primitive ships as Oh Hell and Wizard (see [spec](specs/2026-07-18-tier-1-bidding-trick-taking.md)). Team/partnership totals (1B) remain.
```

- [ ] **Step 5: Format, verify, commit**

```bash
npx prettier --write "README.md" "CHANGELOG.md" "docs/Game-Modes.md" "docs/Game-Modes-Roadmap.md"
npm run check:md
git add README.md CHANGELOG.md docs/Game-Modes.md docs/Game-Modes-Roadmap.md
git commit -m "docs: document Oh Hell and Wizard trick-taking modes"
```

---

## Self-Review

**Spec coverage:**
- `RoundInput` values + `BidTricksRoundAttributes` + formula → Task 1 ✅
- `Player.bidTricksAttributes` additive + fromJson default → Task 2 ✅
- Oh Hell / Wizard descriptors → Task 3 ✅
- `updateBidTricksAttributes` writes derived score → Task 4 ✅
- l10n (mode names untranslated + panel labels) → Task 5 ✅
- `BidTricksRoundPanel` → Task 6 ✅
- Modal/cell/table/splash wiring → Task 7 ✅
- Lean per-mode integration tests → Task 8 ✅
- Docs + roadmap → Task 9 ✅
- Wire compatibility (additive key, non-breaking) → verified in Task 2's fromJson-default test ✅
- Out-of-scope (teams, bags/nil, extra variants) → none implemented ✅

**Type consistency:** `RoundInput.calculatedOhHell/calculatedWizard`, `BidTricksRoundAttributes{bid,tricksTaken}`, `bidTricksScore(RoundInput,{bid,tricksTaken})`, `Player.bidTricksAttributes`, `updateBidTricksAttributes(int,int,BidTricksRoundAttributes)`, `onBidTricksAttributesChanged`, `BidTricksRoundPanel.bidFieldKey/tricksFieldKey`, `l10n.gameModeOhHell/gameModeWizard/bidLabel/tricksTakenLabel` — consistent across tasks.

**Placeholder scan:** No TBD/TODO; each step has complete code and exact commands. The one "match the existing method" note (Task 4) points at `updateFrenchDrivingAttributes` in the same file and shows the target code.

---

## Execution notes

- Strict order: 1 → 9 (each builds on the prior; Task 7's wiring needs Tasks 4/6, and the l10n in Task 5 precedes the panel and splash).
- Run the **full** `fvm flutter test` at Tasks 1, 2, 3, 5, 7.
- Integration tests run `-d macos` locally; the authoritative check is the whole `app_test.dart` file (matches CI). Subset `--plain-name` runs on desktop can show cross-test flakiness — trust the full-file run.
