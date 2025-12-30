# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.8.0] - 2025-12-28

### Added

- Close modal panels on return key in model panel entry fields on non Android and non iOS.
- Move from Navigator to goRouter.
- Load prefs on startup blocking until loading complete if they exist.
- Player name editor highlights name when modal alert editor is made visible.
- Moved prefs code to GameRepository and added new game button test
- Added GitHub action that runs the integration tests on Windows, macOS and iOS.
  - iOS disabled because they are currently broken.
  - macOS disabled because need to bypass signing requirement

## [1.7.0] - 2025-12-25

### Added 1.7.0 +11

- Landscape SplashScreen layout changed to better support wide screens.  Two columns are now the center two of 4 columns.
- Added I10n Internationalization / Localization English first pass
- Added I10n Internalionalization / Localization Spanish first pass
- iPad iOS 26.1 fix broke integration tests because it ignored 0,0 offset taps.

## [1.6.0] - 2025-12-24

1.6.0 only exists for iOS to fix iOS 26.1 related Flutter app bar (top of window) click issue mentioned below

### Added 1.6.0 +10

- Updated Flutter to dart 3.9 or later to support built in dart mcp server <https://docs.flutter.dev/install/archivecirsp>
- Building with Flutter 3.38.5 which is current at time of update
- Migrated from standard linter to VGV linter
- Added `.cursor/rules/flutter-recommended/RULE.md` and `.github/copilot-instructions.md` based on Flutter recommended [ai rules](https://docs.flutter.dev/ai/ai-rules)
- Removed unecessary Semantics instead relying on semanticLabel were available
- Migrated to Flutter Navigation and routes
- Migrated to `fvm` for flutter version management
- Replace hard coded font size with ThemeData
- Remove classes orphaned by AI and no longer referenced.
- Added new property for game finished.  Players who have finished have their names bolded in the score sheet.
- Tap error on new game buttons in app bar on iPad only introduced with iOS 26.1 <https://github.com/flutter/flutter/issues/175606#issuecomment-3453392532>

## [1.5.0] - 2025-10-21

### Added 1.5.0

- gameId for new games - not for restarts
- moved from in-cell editing to editing in a modal panel without a close button
- round cell editing dialog changes orientation based on device orientation
- player name cell editing dialog changes orientation based on the device orientation
- recast all the field key properties to same format to simplify testing
- added cursor rules
- tests and views now share ValueKey definitions implemented as static functions in the views. Simplifies tests but loses any Key drift (should not be issue because keys are only used internally)
- tweaked name display behavior to avoid overflow - use elipses
- Light/Dark test switch only in debug mode.
- Created new them using [flex color scheme](https://rydmike.com/flexcolorscheme/themesplayground-latest/)
- Added `ITSAppUsesNonExemptEncryption` : `No` to macos and ios `info.plist` using XCode.
- Added `sharePositionOrigin` after testing on ipad 16.7. Threw exception without it.
- Added hyperlinks to Joe's LinkedIn and this GitHub repository
- Added no data collection privacy policy
- Submitted to the app store
- published to github.io as GitHub pages <https://freemansoft.github.io/freemans-score-card/>

## [1.4.0] -- 2025-09-21

### Added 1.4.0

- upgrade gradle plugin from 8.5.0 to 8.6.2 and kotlin from 1.8.22 to 2.2.0
- migrated from Riverpod 2 to Riverpod 3
- icons set using `flutter_launcher_icons` for android,ios,macos,linux,web

## [1.3.0] - 2025-08-10

### Added 1.3.0

- Score filter configuration option to restrict entry to numbers ending in 0 and 5
- Real-time validation for score entry fields

## [1.2.0] - 2025-08-09

### Added 1.2.0

- Ability to share CSV via device share functionality
- Share button in app bar with platform-specific icons (iOS share icon on macOS/iOS)
- CSV export with quoted player names for comma handling
- Share functionality with title and subject including date/time

## [1.1.0] - 2024-08-04

### Added 1.1.0

- Save/load last game configuration
- Persistent game state using SharedPreferences
- Automatic game state restoration on app restart

## [1.0.0] - 2024-12-19

### Added 1.0.0

- Initial release
- Basic score tracking functionality
- Player management
- Round-based scoring system
- Data table interface
- Game reset functionality
