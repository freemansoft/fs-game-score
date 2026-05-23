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
  String get continueButton => 'Start new game';

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
  String get gameModeSkyjo => 'Skyjo';

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

  @override
  String get trademarkDisclaimer =>
      'All product and company names are trademarks™ or registered® trademarks of their respective holders. Use of them does not imply any affiliation with or endorsement by them. FreemanS Score Card is an independent application and is not sponsored or approved by any third-party trademark owner.';

  @override
  String get shareLive => 'Share live view';

  @override
  String get joinLiveGame => 'Join live game';

  @override
  String get joinLiveGameTooltip =>
      'Both devices must be on the same Wi-Fi network.';

  @override
  String get liveSharingTitle => 'Live sharing';

  @override
  String get liveSharingInstructions =>
      'Players on the same Wi-Fi can scan this code or pick this game from [Join live game].';

  @override
  String connectionPin(String pin) {
    return 'PIN: $pin';
  }

  @override
  String get copyConnectionUrl => 'Copy connection link';

  @override
  String get connectionUrlCopied => 'Connection link copied';

  @override
  String get stopLiveSharing => 'Stop sharing';

  @override
  String get liveSharingUnavailable =>
      'Live sharing is available on Android and iOS when everyone is on the same Wi-Fi.';

  @override
  String get joinLiveGameTitle => 'Join live game';

  @override
  String get discoveredHosts => 'Games on this network';

  @override
  String get noHostsFound =>
      'No games found. Ask the host to share their QR code.';

  @override
  String get scanConnectionQr => 'Scan connection QR';

  @override
  String get manualConnection => 'Connect manually';

  @override
  String get connectionUrlHint => 'ws://192.168.1.5:8765?game=...&pin=...';

  @override
  String get connect => 'Connect';

  @override
  String get liveSpectatorTitle => 'Live scores';

  @override
  String get liveConnectionConnecting => 'Connecting…';

  @override
  String liveConnectionConnected(String host) {
    return 'Connected to $host';
  }

  @override
  String get liveConnectionConnectedOnly => 'Connected';

  @override
  String get liveConnectionReconnecting => 'Reconnecting…';

  @override
  String get liveConnectionWrongPin =>
      'Wrong PIN. Check the code from the host.';

  @override
  String get liveConnectionVersionMismatch =>
      'App version does not match the host. Update both devices to the same FS Score Card version.';

  @override
  String get liveSyncAppVersionUnknown =>
      'Cannot start live sharing until the app version is known. Restart the app and try again.';

  @override
  String get liveConnectionCannotReachHost =>
      'Cannot reach host. Use the same Wi-Fi and try again.';

  @override
  String get liveConnectionHostClosed => 'Host stopped sharing.';

  @override
  String get liveConnectionFailed => 'Connection failed.';

  @override
  String get leaveLiveView => 'Leave';
}
