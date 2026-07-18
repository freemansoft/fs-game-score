import 'package:fs_score_card/model/score_filters.dart';

/// The scoring styles the app supports.
///
/// This enum is the persisted key for a game's rules (see
/// `GameConfiguration.toJson`); its `toString()` values must stay stable for
/// backward compatibility. Behavior for each mode is declared once in the
/// [GameRules] descriptor returned by [rulesFor] — not by branching on this
/// enum across the codebase.
enum GameMode { standard, phase10, frenchDriving, skyjo, golf, hearts }

/// How a round's score is entered for a mode.
enum RoundInput {
  /// The scorekeeper types the round score directly.
  typedScore,

  /// The round score is calculated from French Driving round attributes;
  /// the typed field is read-only.
  calculatedFrenchDriving,
}

/// How player scores are aggregated into standings.
///
/// Only [sumPerPlayer] exists today. Team roll-up and low-score-wins are
/// Tier 1–2 of the game-mode roadmap; they add values here rather than new
/// branches elsewhere.
enum ScoreAggregation { sumPerPlayer }

/// Whether the highest or the lowest total wins.
///
/// Orthogonal to [ScoreAggregation]: win direction and per-player-vs-team
/// roll-up compose independently, so this is its own field rather than more
/// values on [ScoreAggregation].
enum WinDirection { highestWins, lowestWins }

/// How/when the game signals an end or a leader.
enum EndCondition {
  /// A player whose total reaches the end-game score is highlighted.
  reachTargetHighlight,

  /// The end-game score is a limit: a player crossing it ends the game;
  /// the winner is the lowest total (see [WinDirection.lowestWins]).
  loserThreshold,
}

/// Immutable descriptor of the scoring rules for a [GameMode].
///
/// Centralizes behavior that used to be scattered as `switch`/`if` on
/// `GameMode` across the model and presentation layers. To add a game mode,
/// add an enum value and a descriptor to [_rulesByMode] — you should not need
/// to thread a new enum case through the model, splash screen, round editors,
/// and tests.
class GameRules {
  const GameRules({
    required this.roundInput,
    required this.allowNegativeScores,
    required this.enablePhases,
    required this.numPhases,
    required this.suggestedScoreFilter,
    required this.suggestedEndGameScore,
    // Required (no defaults) so every descriptor states these explicitly and
    // nothing silently shifts if a would-be default were ever changed.
    required this.aggregation,
    required this.endCondition,
    required this.winDirection,
    required this.roundOptions,
    required this.suggestedMaxRounds,
  });

  /// How the round score is entered.
  final RoundInput roundInput;

  /// Whether negative round scores are accepted.
  final bool allowNegativeScores;

  /// Whether the mode collects a completed-phase number per round.
  final bool enablePhases;

  /// Number of phases in the mode (0 when [enablePhases] is false).
  final int numPhases;

  /// Score-entry filter suggested when this mode is selected on the splash
  /// screen. See [ScoreFilters].
  final String suggestedScoreFilter;

  /// End-game target suggested when this mode is selected; 0 means "none".
  final int suggestedEndGameScore;

  /// How scores aggregate into standings (Tier 0: always [ScoreAggregation.sumPerPlayer]).
  final ScoreAggregation aggregation;

  /// How the game signals an end/leader (Tier 0: always [EndCondition.reachTargetHighlight]).
  final EndCondition endCondition;

  /// Whether the highest or lowest total wins (Tier 0: always
  /// [WinDirection.highestWins]; low-score-wins modes set
  /// [WinDirection.lowestWins]).
  final WinDirection winDirection;

  /// The round counts the splash screen offers for this mode, in display
  /// order (most modes use the full [_standardRoundOptions] range; Golf offers
  /// only 9 and 18).
  final List<int> roundOptions;

  /// The round count applied when this mode is selected **if** the current
  /// selection is not one of [roundOptions] (e.g. selecting Golf from a
  /// 14-round Standard game snaps to 18).
  final int suggestedMaxRounds;
}

/// The default round counts offered for modes without a bespoke set (1–20).
const List<int> _standardRoundOptions = [
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, //
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
];

/// The round count suggested for modes without a bespoke default.
/// Mirrors `GameConfiguration.defaultMaxRounds` (kept in sync manually — the
/// model layers cannot import each other without a cycle).
const int _standardSuggestedMaxRounds = 14;

/// The number of phases in Phase 10.
const int _phase10PhaseCount = 10;

const GameRules _standardRules = GameRules(
  roundInput: RoundInput.typedScore,
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

const GameRules _phase10Rules = GameRules(
  roundInput: RoundInput.typedScore,
  allowNegativeScores: false,
  enablePhases: true,
  numPhases: _phase10PhaseCount,
  // Phase 10 scores always end in 0 or 5.
  suggestedScoreFilter: ScoreFilters.endsWith0or5,
  suggestedEndGameScore: 0,
  aggregation: ScoreAggregation.sumPerPlayer,
  endCondition: EndCondition.reachTargetHighlight,
  winDirection: WinDirection.highestWins,
  roundOptions: _standardRoundOptions,
  suggestedMaxRounds: _standardSuggestedMaxRounds,
);

const GameRules _frenchDrivingRules = GameRules(
  roundInput: RoundInput.calculatedFrenchDriving,
  allowNegativeScores: false,
  enablePhases: false,
  numPhases: 0,
  // French Driving mile totals always end in 0 or 5.
  suggestedScoreFilter: ScoreFilters.endsWith0or5,
  suggestedEndGameScore: 5000,
  aggregation: ScoreAggregation.sumPerPlayer,
  endCondition: EndCondition.reachTargetHighlight,
  winDirection: WinDirection.highestWins,
  roundOptions: _standardRoundOptions,
  suggestedMaxRounds: _standardSuggestedMaxRounds,
);

const GameRules _skyjoRules = GameRules(
  roundInput: RoundInput.typedScore,
  allowNegativeScores: true,
  enablePhases: false,
  numPhases: 0,
  suggestedScoreFilter: ScoreFilters.none,
  suggestedEndGameScore: 100,
  aggregation: ScoreAggregation.sumPerPlayer,
  endCondition: EndCondition.reachTargetHighlight,
  winDirection: WinDirection.highestWins,
  roundOptions: _standardRoundOptions,
  suggestedMaxRounds: _standardSuggestedMaxRounds,
);

const GameRules _golfRules = GameRules(
  roundInput: RoundInput.typedScore,
  allowNegativeScores: false,
  enablePhases: false,
  numPhases: 0,
  suggestedScoreFilter: ScoreFilters.none,
  // Golf ends when the fixed rounds are played out; no target line.
  suggestedEndGameScore: 0,
  aggregation: ScoreAggregation.sumPerPlayer,
  endCondition: EndCondition.reachTargetHighlight,
  winDirection: WinDirection.lowestWins,
  // Golf is played over 9 or 18 holes; default a new game to 18.
  roundOptions: [9, 18],
  suggestedMaxRounds: 18,
);

const GameRules _heartsRules = GameRules(
  roundInput: RoundInput.typedScore,
  allowNegativeScores: false,
  enablePhases: false,
  numPhases: 0,
  suggestedScoreFilter: ScoreFilters.none,
  // Hearts: 100 is a loser limit, not a goal — crossing it ends the game.
  suggestedEndGameScore: 100,
  aggregation: ScoreAggregation.sumPerPlayer,
  endCondition: EndCondition.loserThreshold,
  winDirection: WinDirection.lowestWins,
  roundOptions: _standardRoundOptions,
  suggestedMaxRounds: _standardSuggestedMaxRounds,
);

const Map<GameMode, GameRules> _rulesByMode = {
  GameMode.standard: _standardRules,
  GameMode.phase10: _phase10Rules,
  GameMode.frenchDriving: _frenchDrivingRules,
  GameMode.skyjo: _skyjoRules,
  GameMode.golf: _golfRules,
  GameMode.hearts: _heartsRules,
};

/// Returns the [GameRules] descriptor for [mode].
///
/// Every [GameMode] has a descriptor; this is the single lookup that replaces
/// the former `switch (gameMode)` sites.
GameRules rulesFor(GameMode mode) => _rulesByMode[mode]!;
