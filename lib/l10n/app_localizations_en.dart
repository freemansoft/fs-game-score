// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FreemanS Score Card';

  @override
  String get continueButton => 'Continue';

  @override
  String get numberOfPlayers => 'Number of Players:';

  @override
  String get numberOfPlayersTooltip =>
      'Select the number of players for the game';

  @override
  String get maximumRounds => 'Maximum Rounds:';

  @override
  String get maximumRoundsTooltip =>
      'Set the maximum number of rounds for the game';

  @override
  String get sheetStyle => 'Sheet Style:';

  @override
  String get sheetStyleTooltip =>
      'Choose the score sheet style: basic or with phases';

  @override
  String get gameMode => 'Game Mode:';

  @override
  String get gameModeStandard => 'Standard';

  @override
  String get gameModePhase10 => 'Phase 10';

  @override
  String get gameModeFrenchDriving => 'French Driving';

  @override
  String get basicSheet => 'Basic Sheet';

  @override
  String get includePhases => 'Include Phases';

  @override
  String get scoreFilter => 'Score Filter:';

  @override
  String get scoreFilterTooltip =>
      'Limit score input values (e.g., any score or those ending in 5 or 0)';

  @override
  String get anyScore => 'Any Score';

  @override
  String get mustEndIn0Or5 => 'Must end in 0 or 5';

  @override
  String get endScore => 'End Score';

  @override
  String get endScoreTooltip =>
      'Enable game to end when a player reaches this score';

  @override
  String get gameEndingScore => 'Game ending score';

  @override
  String get copyright => 'Copyright (C) 2025 Joe Freeman';

  @override
  String version(String version) {
    return 'Version: $version';
  }

  @override
  String get scores => 'Scores';

  @override
  String get playerTotal => 'Player\nTotal';

  @override
  String get lockColumn => 'Lock column';

  @override
  String get unlockColumn => 'Unlock column';

  @override
  String get name => 'Name:';

  @override
  String get phasesByRound => 'Phases by Round:';

  @override
  String get noPhasesCompleted => 'No phases completed';

  @override
  String roundPhase(int roundNumber, int phaseNumber) {
    return 'Round $roundNumber: Phase $phaseNumber';
  }

  @override
  String get score => 'Score:';

  @override
  String get scoreHint => 'Score';

  @override
  String get phase => 'Phase:';

  @override
  String get selectCompletedPhases => 'Select completed phase(s)';

  @override
  String get noPhase => 'No Phase';

  @override
  String phaseNumber(int phaseNumber) {
    return 'Phase $phaseNumber';
  }

  @override
  String playerRoundModalTitle(int playerNumber, int roundNumber) {
    return 'Player $playerNumber - Round $roundNumber';
  }

  @override
  String get invalidScoreForRound => 'Invalid Score for this round';

  @override
  String get startNewGame => 'Start New Game?';

  @override
  String get startNewGameMessage =>
      'Are you sure you want to start a new game? The score card will be erased.';

  @override
  String get clearPlayerNames => 'Clear the player names';

  @override
  String get cancel => 'Cancel';

  @override
  String get newGame => 'New Game';

  @override
  String get gameReset => 'Game reset!';

  @override
  String get newGameSameTypeTooltip => 'New Game - Using same scorecard type';

  @override
  String get changeScorecardType => 'Change Scorecard Type';

  @override
  String get changeScorecardTypeMessage =>
      'Are you sure you want to change the scorecard type? The scorecard will be cleared.';

  @override
  String get changeScorecard => 'Change Scorecard';

  @override
  String get newGameChangeScorecardType => 'New Game - Change Scorecard Type';

  @override
  String get shareScores => 'Share Scores';

  @override
  String get noScoresToShare => 'No scores to share';

  @override
  String get miles => 'Miles';

  @override
  String get safeties => 'Safeties';

  @override
  String get coupFourre => 'Coup Fourré';

  @override
  String get delayedAction => 'Delayed Action';

  @override
  String get safeTrip => 'Safe Trip';

  @override
  String get shutOut => 'Shut Out';

  @override
  String get milesTooltip =>
      'Each team scores as many points as the total number of miles that it has traveled.';

  @override
  String get safetiesTooltip => '100 points for each Safety Card played.';

  @override
  String get coupFourreTooltip =>
      '300 points in addition to the 100 points for the Safety Card.';

  @override
  String get delayedActionTooltip =>
      'If trip is completed after all cards have been played from the draw pile.';

  @override
  String get safeTripTooltip =>
      'If trip is completed without playing any 200 Mile Cards.';

  @override
  String get shutOutTooltip =>
      'Completing trip of 1000 miles before opponents have played any Distance Cards.';
}
