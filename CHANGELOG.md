# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2025-10-21

### Added

- gameId for new games - not for restarts
- moved from in-cell editing to editing in a modal panel without a close button
- round cell editing dialog changes orientation based on device orientation
- player name cell editing dialog changes orientation based on the device orientation
- recast all the field key properties to same format to simplify testing
- added cursor rules
- tests and views now share ValueKey definitions implemented as static functions in the views. Simplifies tests but loses any Key drift (should not be issue because keys are only used internally)
- tweaked name display behavior to avoid overflow - use elipses

## [1.4.0] -- 2025-09-21

### Added

- upgrade gradle plugin from 8.5.0 to 8.6.2 and kotlin from 1.8.22 to 2.2.0
- migrated from Riverpod 2 to Riverpod 3
- icons set using `flutter_launcher_icons` for android,ios,macos,linux,web

## [1.3.0] - 2025-08-10

### Added

- Score filter configuration option to restrict entry to numbers ending in 0 and 5
- Real-time validation for score entry fields

## [1.2.0] - 2025-08-09

### Added

- Ability to share CSV via device share functionality
- Share button in app bar with platform-specific icons (iOS share icon on macOS/iOS)
- CSV export with quoted player names for comma handling
- Share functionality with title and subject including date/time

## [1.1.0] - 2024-08-04

### Added

- Save/load last game configuration
- Persistent game state using SharedPreferences
- Automatic game state restoration on app restart

## [1.0.0] - 2024-12-19

### Added

- Initial release
- Basic score tracking functionality
- Player management
- Round-based scoring system
- Data table interface
- Game reset functionality
