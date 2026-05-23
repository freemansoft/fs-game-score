import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'FreemanS Score Card'**
  String get appTitle;

  /// Button to start new game and transition from splash screen to score table
  ///
  /// In en, this message translates to:
  /// **'Start new game'**
  String get continueButton;

  /// Label for number of players dropdown
  ///
  /// In en, this message translates to:
  /// **'Number of Players:'**
  String get numberOfPlayers;

  /// Tooltip for number of players field
  ///
  /// In en, this message translates to:
  /// **'Select the number of players for the game'**
  String get numberOfPlayersTooltip;

  /// Label for maximum rounds dropdown
  ///
  /// In en, this message translates to:
  /// **'Maximum Rounds:'**
  String get maximumRounds;

  /// Tooltip for maximum rounds field
  ///
  /// In en, this message translates to:
  /// **'Set the maximum number of rounds for the game'**
  String get maximumRoundsTooltip;

  /// Label for sheet style dropdown
  ///
  /// In en, this message translates to:
  /// **'Sheet Style:'**
  String get sheetStyle;

  /// Tooltip for sheet style field
  ///
  /// In en, this message translates to:
  /// **'Choose the score sheet style: basic or with phases'**
  String get sheetStyleTooltip;

  /// Label for game mode dropdown
  ///
  /// In en, this message translates to:
  /// **'Game Mode:'**
  String get gameMode;

  /// Standard game mode option
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get gameModeStandard;

  /// Phase 10 game mode option
  ///
  /// In en, this message translates to:
  /// **'Phase 10'**
  String get gameModePhase10;

  /// French Driving game mode option
  ///
  /// In en, this message translates to:
  /// **'French Driving'**
  String get gameModeFrenchDriving;

  /// Skyjo game mode option
  ///
  /// In en, this message translates to:
  /// **'Skyjo'**
  String get gameModeSkyjo;

  /// Option for basic sheet style
  ///
  /// In en, this message translates to:
  /// **'Basic Sheet'**
  String get basicSheet;

  /// Option for sheet style with phases
  ///
  /// In en, this message translates to:
  /// **'Include Phases'**
  String get includePhases;

  /// Label for score filter dropdown
  ///
  /// In en, this message translates to:
  /// **'Score Filter:'**
  String get scoreFilter;

  /// Tooltip for score filter field
  ///
  /// In en, this message translates to:
  /// **'Limit score input values (e.g., any score or those ending in 5 or 0)'**
  String get scoreFilterTooltip;

  /// Option for any score filter
  ///
  /// In en, this message translates to:
  /// **'Any Score'**
  String get anyScore;

  /// Option for score filter that requires scores to end in 0 or 5
  ///
  /// In en, this message translates to:
  /// **'Must end in 0 or 5'**
  String get mustEndIn0Or5;

  /// Label for end game score field
  ///
  /// In en, this message translates to:
  /// **'End Score'**
  String get endScore;

  /// Tooltip for end game score field
  ///
  /// In en, this message translates to:
  /// **'Enable game to end when a player reaches this score'**
  String get endScoreTooltip;

  /// Hint text for end game score input field
  ///
  /// In en, this message translates to:
  /// **'Game ending score'**
  String get gameEndingScore;

  /// Copyright text
  ///
  /// In en, this message translates to:
  /// **'Copyright (C) 2025 Joe Freeman'**
  String get copyright;

  /// Version text with placeholder
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String version(String version);

  /// App bar title for score table screen
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get scores;

  /// Column header text for player and total
  ///
  /// In en, this message translates to:
  /// **'Player\nTotal'**
  String get playerTotal;

  /// Tooltip for lock column button
  ///
  /// In en, this message translates to:
  /// **'Lock column'**
  String get lockColumn;

  /// Tooltip for unlock column button
  ///
  /// In en, this message translates to:
  /// **'Unlock column'**
  String get unlockColumn;

  /// Label for name field in player game modal
  ///
  /// In en, this message translates to:
  /// **'Name:'**
  String get name;

  /// Label for phases by round section
  ///
  /// In en, this message translates to:
  /// **'Phases by Round:'**
  String get phasesByRound;

  /// Text shown when no phases are completed
  ///
  /// In en, this message translates to:
  /// **'No phases completed'**
  String get noPhasesCompleted;

  /// Text showing round and phase
  ///
  /// In en, this message translates to:
  /// **'Round {roundNumber}: Phase {phaseNumber}'**
  String roundPhase(int roundNumber, int phaseNumber);

  /// Label for score field
  ///
  /// In en, this message translates to:
  /// **'Score:'**
  String get score;

  /// Hint text for score input field
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreHint;

  /// Label for phase dropdown
  ///
  /// In en, this message translates to:
  /// **'Phase:'**
  String get phase;

  /// Tooltip for phase dropdown
  ///
  /// In en, this message translates to:
  /// **'Select completed phase(s)'**
  String get selectCompletedPhases;

  /// Option for no phase selected
  ///
  /// In en, this message translates to:
  /// **'No Phase'**
  String get noPhase;

  /// Phase option text
  ///
  /// In en, this message translates to:
  /// **'Phase {phaseNumber}'**
  String phaseNumber(int phaseNumber);

  /// Title for player round modal
  ///
  /// In en, this message translates to:
  /// **'Player {playerNumber} - Round {roundNumber}'**
  String playerRoundModalTitle(int playerNumber, int roundNumber);

  /// Error message when score doesn't match filter
  ///
  /// In en, this message translates to:
  /// **'Invalid Score for this round'**
  String get invalidScoreForRound;

  /// Title for new game dialog
  ///
  /// In en, this message translates to:
  /// **'Start New Game?'**
  String get startNewGame;

  /// Message in new game dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start a new game? The score card will be erased.'**
  String get startNewGameMessage;

  /// Checkbox label for clearing player names
  ///
  /// In en, this message translates to:
  /// **'Clear the player names'**
  String get clearPlayerNames;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// New game button text
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// Snackbar message when game is reset
  ///
  /// In en, this message translates to:
  /// **'Game reset!'**
  String get gameReset;

  /// Tooltip for new game button
  ///
  /// In en, this message translates to:
  /// **'New Game - Using same scorecard type'**
  String get newGameSameTypeTooltip;

  /// Title for change scorecard type dialog
  ///
  /// In en, this message translates to:
  /// **'Change Scorecard Type'**
  String get changeScorecardType;

  /// Message in change scorecard type dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change the scorecard type? The scorecard will be cleared.'**
  String get changeScorecardTypeMessage;

  /// Button text to change scorecard
  ///
  /// In en, this message translates to:
  /// **'Change Scorecard'**
  String get changeScorecard;

  /// Tooltip for change scorecard type button
  ///
  /// In en, this message translates to:
  /// **'New Game - Change Scorecard Type'**
  String get newGameChangeScorecardType;

  /// Tooltip for share button
  ///
  /// In en, this message translates to:
  /// **'Share Scores'**
  String get shareScores;

  /// Message when there are no scores to share
  ///
  /// In en, this message translates to:
  /// **'No scores to share'**
  String get noScoresToShare;

  /// Miles travelled
  ///
  /// In en, this message translates to:
  /// **'Miles'**
  String get miles;

  /// Safeties played
  ///
  /// In en, this message translates to:
  /// **'Safeties'**
  String get safeties;

  /// Coup fourre played
  ///
  /// In en, this message translates to:
  /// **'Coup Fourré'**
  String get coupFourre;

  /// Delayed action played
  ///
  /// In en, this message translates to:
  /// **'Delayed Action'**
  String get delayedAction;

  /// Safe trip played
  ///
  /// In en, this message translates to:
  /// **'Safe Trip'**
  String get safeTrip;

  /// Bonus for completing the trip before opponents play any distance cards
  ///
  /// In en, this message translates to:
  /// **'Shut Out'**
  String get shutOut;

  /// Tooltip for miles field
  ///
  /// In en, this message translates to:
  /// **'Each team scores as many points as the total number of miles that it has traveled.'**
  String get milesTooltip;

  /// Tooltip for safeties section
  ///
  /// In en, this message translates to:
  /// **'100 points for each Safety Card played.'**
  String get safetiesTooltip;

  /// Tooltip for Coup Fourre section
  ///
  /// In en, this message translates to:
  /// **'300 points in addition to the 100 points for the Safety Card.'**
  String get coupFourreTooltip;

  /// Tooltip for Delayed Action bonus
  ///
  /// In en, this message translates to:
  /// **'If trip is completed after all cards have been played from the draw pile.'**
  String get delayedActionTooltip;

  /// Tooltip for Safe Trip bonus
  ///
  /// In en, this message translates to:
  /// **'If trip is completed without playing any 200 Mile Cards.'**
  String get safeTripTooltip;

  /// Tooltip for Shut Out bonus
  ///
  /// In en, this message translates to:
  /// **'Completing trip of 1000 miles before opponents have played any Distance Cards.'**
  String get shutOutTooltip;

  /// Trademark disclaimer shown in the about dialog
  ///
  /// In en, this message translates to:
  /// **'All product and company names are trademarks™ or registered® trademarks of their respective holders. Use of them does not imply any affiliation with or endorsement by them. FreemanS Score Card is an independent application and is not sponsored or approved by any third-party trademark owner.'**
  String get trademarkDisclaimer;

  /// Tooltip and semantic label for host live score sharing
  ///
  /// In en, this message translates to:
  /// **'Share live view'**
  String get shareLive;

  /// Button to join a live game as spectator
  ///
  /// In en, this message translates to:
  /// **'Join live game'**
  String get joinLiveGame;

  /// Tooltip on splash Join live game button
  ///
  /// In en, this message translates to:
  /// **'Both devices must be on the same Wi-Fi network.'**
  String get joinLiveGameTooltip;

  /// Title for live host dialog
  ///
  /// In en, this message translates to:
  /// **'Live sharing'**
  String get liveSharingTitle;

  /// Instructions on host live dialog
  ///
  /// In en, this message translates to:
  /// **'Players on the same Wi-Fi can scan this code or pick this game from [Join live game].'**
  String get liveSharingInstructions;

  /// PIN shown for live session
  ///
  /// In en, this message translates to:
  /// **'PIN: {pin}'**
  String connectionPin(String pin);

  /// Copy ws connection URL to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy connection link'**
  String get copyConnectionUrl;

  /// Snackbar after copying connection URL
  ///
  /// In en, this message translates to:
  /// **'Connection link copied'**
  String get connectionUrlCopied;

  /// Stop hosting live session
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get stopLiveSharing;

  /// Hint when live sync is not supported on this platform
  ///
  /// In en, this message translates to:
  /// **'Live sharing is available on Android and iOS when everyone is on the same Wi-Fi.'**
  String get liveSharingUnavailable;

  /// Title for join live game screen
  ///
  /// In en, this message translates to:
  /// **'Join live game'**
  String get joinLiveGameTitle;

  /// Section header for mDNS discovered hosts
  ///
  /// In en, this message translates to:
  /// **'Games on this network'**
  String get discoveredHosts;

  /// Empty state for mDNS browse
  ///
  /// In en, this message translates to:
  /// **'No games found. Ask the host to share their QR code.'**
  String get noHostsFound;

  /// Button to scan host QR
  ///
  /// In en, this message translates to:
  /// **'Scan connection QR'**
  String get scanConnectionQr;

  /// Expand manual ws URL entry
  ///
  /// In en, this message translates to:
  /// **'Connect manually'**
  String get manualConnection;

  /// Hint for manual connection URL field
  ///
  /// In en, this message translates to:
  /// **'ws://192.168.1.5:8765?game=...&pin=...'**
  String get connectionUrlHint;

  /// Connect to live host button
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// App bar title for spectator view
  ///
  /// In en, this message translates to:
  /// **'Live scores'**
  String get liveSpectatorTitle;

  /// Spectator banner while connecting
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get liveConnectionConnecting;

  /// Spectator banner when connected to a host target
  ///
  /// In en, this message translates to:
  /// **'Connected to {host}'**
  String liveConnectionConnected(String host);

  /// Spectator banner when connected but no game id or IP is available
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get liveConnectionConnectedOnly;

  /// Spectator banner while reconnecting
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get liveConnectionReconnecting;

  /// Spectator banner for wrong PIN
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Check the code from the host.'**
  String get liveConnectionWrongPin;

  /// Spectator banner when app version differs from host
  ///
  /// In en, this message translates to:
  /// **'App version does not match the host. Update both devices to the same FS Score Card version.'**
  String get liveConnectionVersionMismatch;

  /// Error when host cannot determine app version for live sync
  ///
  /// In en, this message translates to:
  /// **'Cannot start live sharing until the app version is known. Restart the app and try again.'**
  String get liveSyncAppVersionUnknown;

  /// Spectator banner when connection fails
  ///
  /// In en, this message translates to:
  /// **'Cannot reach host. Use the same Wi-Fi and try again.'**
  String get liveConnectionCannotReachHost;

  /// Spectator banner when host closes session
  ///
  /// In en, this message translates to:
  /// **'Host stopped sharing.'**
  String get liveConnectionHostClosed;

  /// Spectator banner generic failure
  ///
  /// In en, this message translates to:
  /// **'Connection failed.'**
  String get liveConnectionFailed;

  /// Leave spectator live view
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveLiveView;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
