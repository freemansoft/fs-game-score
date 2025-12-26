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

  /// Button to continue from splash screen to score table
  ///
  /// In en, this message translates to:
  /// **'Continue'**
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
