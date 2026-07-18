# FreemanS Score Card - fs_score_card

The application implements a scorecard for an arbitrary number of players and game _rounds_. It has been tested on Android, iOS, Chrome, macOS, and Windows 11.

- [Using the app](#using-the-app)
- [Scoreboards and game types](#scoreboards-and-game-types)
- [State retention](#state-retention)
- [Developer notes](#developer-notes)

## Using the app

### Splash screen

Configure the game before play:

- **Number of players** and **maximum rounds**
- **Game mode** (see [Scoreboards and game types](#scoreboards-and-game-types))
- **Score filter** (optional; Phase 10 and French Driving auto-set scores ending in 0 or 5)
- **End game score** (optional target total; Skyjo and French Driving set suggested defaults when selected)

**Start new game** saves the configuration and opens the score table. If you left a game in progress, the app may open the score table directly on launch instead of the splash screen.

**Join live game** (Android and iOS only, same Wi-Fi as the host) opens a read-only live view of a game hosted on another phone or tablet. You can pick a discovered host, scan the host’s connection QR code, or enter a connection URL manually (debug builds). The host and spectator must use the same app version and PIN shown by the host.

Web, macOS, and Windows can score locally and **share scores** as CSV; live host/join is mobile-only today.

### Score table

- **Player names** — tap a name cell to edit in a modal panel.
- **Round scores** — tap a score cell to edit in a modal panel. Totals update in the **Total** column.
- **Round locks** — rounds can be locked to prevent accidental edits (where supported by the game mode).

### App bar (score table)

| Control                   | Action                                                                                                                             |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| **New Game**              | Clears round scores; optionally clears player names while keeping the same game configuration.                                     |
| **Change Scorecard Type** | Returns to the splash screen to change players, rounds, or game mode. Current player progress is cleared.                          |
| **Share live**            | Android/iOS only. Hosts a view-only live session on the local network (QR code, PIN, copyable URL). Spectators cannot edit scores. |
| **Share Scores**          | Exports the current scores as CSV (all platforms).                                                                                 |

### Live sharing (Android and iOS)

**Share live** lets one device **host** the score table while others **watch** on the same Wi-Fi. The host is the only device that can edit scores; spectators see updates as the host plays. Nothing is sent to a FreemanS server—devices talk directly on your local network.

**Requirements** for usage

- Host and spectators: **Android or iOS** (web, macOS, and Windows cannot host or join live sessions today).
- Everyone on the **same Wi-Fi** (or local network). Guest networks with client isolation may block connections.
- **Same app version** on host and spectators (shown on the splash screen).
- **6-digit PIN** from the host’s share dialog (plus QR code or copyable connection URL).

**Host (scorekeeper)** Role

1. Open the score table and tap **Share live** in the app bar.
2. Give spectators the **QR code**, **connection URL**, and **PIN**.
3. Keep scoring as usual—changes appear on connected spectators within a few seconds.
4. Tap **Stop sharing**, start a **New Game**, or leave the score table to end the session.

**Spectator (viewer)** Role

1. On the splash screen, tap **Join live game**.
2. Connect by picking a game from the list, **scanning the host’s QR code**, or (in debug builds) pasting the connection URL.
3. Enter the PIN when prompted. The score table opens **read-only** with a connection banner.
4. Tap **Leave** on the spectator screen to disconnect. Live scores are **not saved** on the spectator device.

For CSV export on any platform, use **Share Scores** instead of live sharing.

See [docs/Game-Sync.md](docs/Game-Sync.md) for technical details.

## Scoreboards and game types

Game mode is chosen on the splash screen. The score table layout and round editor change with the mode. You can switch modes later via **Change Scorecard Type** or start over with **New Game** on the score table.

| Mode                | Summary                                                                                                                                                                                                                                         |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **General scoring** | Standard round scores and running totals. Round scores are non-negative. Optional end-game target highlights players who reach that total.                                                                                                      |
| **Skyjo**           | Like general scoring, with **negative round scores** allowed. Selecting Skyjo enables end-game score and suggests **100** points.                                                                                                               |
| **Phase 10**        | Round scores plus **phase completed** per round. Scores typically end in **0 or 5** (score filter applied automatically). Tap a player’s total to see completed phases.                                                                         |
| **French Driving**  | Round score is **calculated** from miles, safety cards, Coup Fourré, and trip bonuses—not typed directly. Selecting French Driving enables end-game score and suggests **5000** points. The miles field is focused when the round editor opens. |
| **Golf**            | Card-game Golf scoring, where the **lowest total wins**. Offers **9 or 18 rounds** (default 18); the current leader (lowest total) is marked in the score table.                                                                                |
| **Hearts**          | **Lowest total wins.** Selecting Hearts suggests a **loser threshold of 100**—a player crossing it ends the game. The current leader (lowest total) is marked in the score table.                                                               |

All modes support editing player names, per-round entry (or French Driving attributes), and optional **end game score** highlighting on the splash screen. In the low-score-wins modes (Golf, Hearts) the current leader—the player with the **lowest** total—is marked in the score table.

More detail: [docs/Game-Modes.md](docs/Game-Modes.md).

## State retention

The app stores game data locally with **SharedPreferences** (browser **localStorage** on web). There is no cloud sync; live spectator views are not saved to disk.

| What                   | When it is saved                                                                                      | Prefs key       |
| ---------------------- | ----------------------------------------------------------------------------------------------------- | --------------- |
| **Game configuration** | When you tap **Start new game** on the splash screen (players, rounds, mode, filters, end-game score) | `game_state`    |
| **Initial roster**     | Immediately after **Start new game**, before the score table opens (empty scores, default names)      | `players_state` |
| **Scores during play** | Automatically while you edit the score table (coalesced saves—one write in flight, latest state wins) | `players_state` |

### Resume after restart

On launch, if both a valid **game configuration** and **player state** are on disk and they match (same number of players and rounds), the app opens the **score table** and restores your game. Otherwise it shows the **splash screen** with the last saved configuration as defaults.

This supports accidental browser reloads, app suspension on mobile, and closing the app mid-game.

### Clearing state

| Action                                       | Game configuration (`game_state`) | Player progress (`players_state`)   |
| -------------------------------------------- | --------------------------------- | ----------------------------------- |
| **Start new game** (splash)                  | Replaced with new settings        | Replaced with a fresh roster        |
| **New Game** (score table app bar)           | Unchanged                         | Scores cleared; names optional      |
| **Change Scorecard Type** (return to splash) | Kept as splash defaults           | Cleared when splash loads           |
| **Join live game** (spectator)               | Unchanged on your device          | Not written; view is in memory only |

Entering the splash screen clears in-memory and persisted player progress so the next **Start new game** begins with a clean roster. Returning from the score table waits for that clear to finish before navigation.

There is no separate “clear all data” control—starting a new game or changing scorecard type resets player state; configuration persists until you change it on the splash screen.

More detail: [docs/State-Management.md](docs/State-Management.md).

## Developer notes

### Known Issues

- Restarting the same game config does not change the gameId. This is a "feature"
- When debugging the web app with the IDE, the LocalStorage is not persisted across sessions. This is a "feature" of the fact that the web session is on a different port every time it is run.
- Unable to get macOS integration tests to run as GitHub Actions due to code signing requirement.
- Unable to get iOS integration tests to run reliably as GitHub Actions. Cause to be determined.

### Looking to run the working scoring app?

Links to latest versions are here <https://freemansoft.github.io/>

Or build your own copy...

1. Clone this repo.
2. Open the whole repo in VSCode
3. This project uses `fvm` to set the correct flutter version. Install `fvm`.
   1. Mac You can run the script `install-fvm.sh` to install the tools and the correct version of fvm from scratch
   1. Windows See [fvm installation guide](https://fvm.app/documentation/getting-started/installation)
   1. Use in an elevated command powershell prompt to install `fvm`. Needs to be done only once
      1. `choco install fvm`
      1. `choco upgrade fvm`
   1. From a command prompt in vscode/cursor after installing `fvm`
      1. `fvm install 3.38.5` or whatever the version you need is
      1. `fvm use 3.38.5`
4. Select the run view on the left-hand side
5. Select fs_score_card in the run drop-down menu
6. Press the green run button
7. The application will run on an emulator, simulator, macos, windows, web or connected device.

Your machine may require that you replace any `flutter` commands with `fvm flutter` and `dart` with `fvm dart` to use the correct version of Flutter as managed by `fvm`.

### Internationalization

Make sure to regenerate the dart localization files after making any changes to the internationalization `arb` files using the command `flutter gen-l10n`. The command `flutter gen-l10n` has already been run the current version of the code. Run it again if you add internationalized strings

~~Other options include running `flutter pub get` or doing a build.~~

### Build and Test

Riverpod architecture, provider layers, and testing conventions are documented in [docs/State-Management.md](docs/State-Management.md). LAN live score sharing (`gameSyncHostProvider`, `gameSyncSpectatorProvider`, handshake, PIN/app version validation) is documented in [docs/Game-Sync.md](docs/Game-Sync.md).

You can test this locally using the run view in VSCode or using the command line.

Release builds can be created from the command line individually for each platform or via the `build-distributable.sh` and `build-distributable.ps1` scripts.

#### Run View in VSCode

- The IDE and the Android simulator on Mac or PC
- The IDE and the iOS emulator on Mac
- The IDE and a hardware connected Android device on a Mac or PC
- The IDE and a hardware connected iOS device on a Mac
- macOS app on a Mac
- windows fat app on PC
- A Web App on Mac or PC

#### Android builds

##### Android test builds - side loading

1. (Android) Create an APK and download it to a device
   1. Build the android arm64 package. Including the `android-arm64` makes it a single target binary and drops the size from 23MB to 8MB
      1. `flutter build apk --target-platform android-arm64`
      2. The parameter `android-arm64` makes it a single target binary and drops the size from 23MB to 8MB. There aren't any interesting x86 android devices anyway.
   2. Share `build/app/outputs/apk/release/fs_score_card-v<release>-release.apk` to devices. This can be done by emailing or by pushing the apk to a shared storage
      1. This is the version copied to new [releases on GitHub](https://github.com/freemansoft/fs-game-score/releases)
      2. You can share the generic named apk from `build/outputs/flutter-apk/app-release.apk` There should be an associated `sha` file there.

Android build notes:
Android APKs end up built in two places. [Stack Overflow](https://stackoverflow.com/questions/62910148/flutter-what-is-the-difference-between-the-apk-release-directory-and-flutter-ap)

- `build/app/outputs/apk` Including app name and version in the `apk` filename.
  - `build/app/outputs/apk/release/fs_score_card-v<version>-release.apk`
  - `build/app/outputs/apk/debug/fs_score_card-v<version>-debug.apk`
- `build/app/outputs/flutter-apk` Generic apk without the app name and version in the `apk` filename. These include sha1 files.
  - `build/app/outputs/flutter-apk/apk-release.apk`
  - `build/app/outputs/flutter-apk/app-debug.ap`

##### Google Play Store (tentative)

- Onboarding
  - Enable Google Play in your workspace [Google Play service](https://admin.google.com/ac/managedsettings/805142757380)
  - [Create releases in the Google Play store console](https://play.google.com/console/)
  - Onboard to the store, pay $25, verify identity
  - Connect to <https://play.google.com/console> and verify your account
  - Install the Google Play console app on your android device and authenticate
  - Set up the signing keys
- Build the app bundle with `flutter build appbundle --release`
  - That doesn't work because it has to be signed.
  - ...

#### iOS Builds

##### iOS Test builds

You can test this locally using the IDE and the iOS simulator or hardware connected ios device on a Mac.

Standalone testing is driven through [Apple store connect](https://appstoreconnect.apple.com/)

1. open the `ios` folder in xcode if you need to. I didn't need xcode for iOS builds the way I did for MacOS.
2. `flutter build ipa` or `flutter build ipa --release`
3. Do the store thing - upload the ipa via Apple **Transporter** app and do all the configuration in testflight and the store

Alternatively - use the xcode archive route like we do for macOS

1. `flutter build ipa --release` to build the ios app and copy info from [pubspec.yaml](/pubspec.yaml) into the xcode iOS files
2. Open the `ios` project in XCode. This opens the iOS target of the Flutter project
3. `Product > Archive`
4. `Validate App` --> `Validate`
5. `Distribute App` --> `App Store Connect`

Validate the version number and build ID on the splash screen. It should match the value in [pubspec.yaml](/pubspec.yaml). The version number for all platforms is set in [pubspec.yaml](/pubspec.yaml).

#### MacOS builds

##### MacOS test builds

You can test this locally using the IDE on a Mac

MacOS builds are separate from iOS builds and must be uploaded to the store separately. Follow <https://docs.flutter.dev/deployment/macos>

1. `flutter build macos --release` to build the project and copy the [pubspec.yaml](/pubspec.yaml)
2. Open the `macOS` directory in XCode. This opens the MacOS target of the Flutter project.
   1. XCode `Product > Archive` it will build an archive
   2. A new XCode window will pop up
   3. XCode `Validate App` --> `Validate`
   4. XCode `Distribute App` --> `App Store Connect`

Validate the version number and build ID on the splash screen. It should match the value in [pubspec.yaml](/pubspec.yaml). The version number for all platforms is set in [pubspec.yaml](/pubspec.yaml).

To release macOS after TestFlight. This works for iOS also

1. Open AppStoreConnect web site
2. Navigate to App `FreemanS Score Card`
3. Click on the `+` sign next to `macOS App` and create the new release
4. Scroll down and add the `Build` you wish to this release.
5. Update images, text and other data and then submit for review

#### Web test builds

##### Web build distribution - standalone web app

You can test this locally using the IDE and a web browser like Chrome

1. Create a distributable web package that can be distributed for people to web test locally
   1. Build the package `flutter build web` or `flutter build web --release`
   2. create a zip file of `build/web`
   3. Share the zip. They can unzip it and put the contents of the `web` folder in the web server docroot. The `web` folder should not be part of the path.

##### Web build distribution — when web sites are rooted in a non-root subdirectory

Change this to match your deployment. These notes exist so I remember the process!

The following works for hosting this app on my `github.io` pages. I host this app on my [github.io pages](https://freemansoft.github.io/freemans-score-card).

1. Build the web app with `flutter build web --base-href=/freemans-score-card/`
2. Copy the contents of `build/web` **excluding the canvaskit directory** to a local clone of <https://github.com/freemansoft/freemansoft.github.io>
   1. We are going to use the Google CDN CanvasKit and don't need to take up space in our repo with the binary
3. You can test the site locally by running a local web server `python -m http.server 8000` from a terminal prompt in the root of the github.io repo and navigating to <http://localhost:8000/freemans-score-card/>
4. Commit the files and push them to GitHub.
5. Test with GitHub pages <https://freemansoft.github.io/freemans-score-card>

#### Windows Builds

##### Windows test builds

You can test this locally using the IDE on a Windows machine.

1. Build the image on a windows machine with `flutter build windows`
1. Double click on the `exe` in `build\\windows\x64\runner\Release\fs_score_card.exe`
1. You **cannot** copy just the exe somewhere and expect it to work

##### Build an installer package

An `msix` section has already been added to customize the `msi` installer creator output <https://pub.dev/packages/msix>

1. Build the image on a windows machine with `flutter build windows`
1. Use the `msix` package to create a windows installer
   1. `flutter pub run msix:create`
   1. `dart run msix:create` — this will offer to install a self-signed `pfx` certificate the first time it runs. Allow this.
1. Copy the created `msix` file located in `build\windows\x64\runner\Release\fs_score_card.msix` to the target location where it can be installed from.

##### Windows store builds

_to be documented_ Windows standalone app packaged builds.

- see docs <https://docs.flutter.dev/deployment/windows>

### Integration tests

Integration tests can't be run against browsers. Web based integration tests are not supported (2025/07)

The integration tests were generated by copilot and are copilot updated. You can run them with

```bash
flutter test integration_test/app_test.dart
```

| Platform | Support                        | GitHub Action Status                                |
| -------- | ------------------------------ | --------------------------------------------------- |
| MacOS    | yes                            | Deployed. Disabled due to code signing requirements |
| Windows  | yes                            | Deployed. Enabled - cheapest because no emulator    |
| Linux    | not tested                     | No. Not tested                                      |
| Android  | yes                            | Deployed. Enabled                                   |
| iOS      | yes                            | Deployed. Disabled due to expense                   |
| Web      | integration test not supported | No. Web integration test not supported              |

[GitHub Actions](https://github.com/freemansoft/fs-game-score/actions) run integration tests on various platforms when the repo receives a `push` to GitHub.
Files are located in [GitHub workflows](./.github/workflows).

### Android Notes

1. Java 21 installations will get an error because this is using gradle 8.10.2 which matches Java 23.
2. I'm on Java 21 matches against gradle 8.5
3. This android build requires at least gradle 8.7.
4. If you go to plugin version 8.8 to work with gradle 8.10.2 you get an ndk version error
5. So we left the "Could not create task generateLockfiles" error.

| Java | Gradle (min) | Android Plugin | API Level | Android Studio Version |
| ---- | ------------ | -------------- | --------- | ---------------------- |
| 21   | 8.4          | 8.3            | 34        | .                      |
| ??   | 8.6          | 8.4            | 34        | .                      |
| ??   | 8.7          | 8.5            | 34        | .                      |
| 22   | 8.7          | 8.6            | 34        | .                      |
| ??   | 8.9          | 8.7            | 34        | .                      |
| 23   | 8.10         | 8.8            | 35        | .                      |
| ??   | 8.11         | 8.9            | 35        | .                      |
| ??   | 8.11         | 8.10           | 35        | .                      |
| ??   | 8.13         | 8.11           | 35        | .                      |
| ??   | 8.13         | 8.12           | 35        | .                      |
| ??   | ?            | ?              | 36        | Android Studio 2025    |

1. <https://docs.gradle.org/current/userguide/compatibility.html>
2. <https://developer.android.com/build/releases/gradle-plugin>
3. <https://developer.android.com/build/releases/past-releases>

### Application Icons

The application icon was creatd using [appicon.co App Icon Generator](https://www.appicon.co/). The resulting icon is in [flutter-phone-score.png](/assets/logos/flutter-phone-score.png). All Android and iOS icons are derived from this 1024×1024 image.

This single icon was resized and mapped to all applicaton icons using [flutter_launcher_icons](https://github.com/fluttercommunity/flutter_launcher_icons) for all target platforms. `flutter_launcher_icons` configuration is in [pubspec.yaml](/pubspec.yaml).

```bash
dart run flutter_launcher_icons
```

### Creating a release tag

[tag-push.sh](/tag-push.sh) auto generates the <build_id> portion of the version number from the GitHub MAIN branch commit count

- Create a local tag, update the [pubspec.yaml](/pubspec.yaml) update the [CHANGELOG.md](/CHANGELOG.md) to add the new release
  - `bash tag-push.sh --version <major.minor.patch>`
- Force move a local tag, update the [pubspec.yaml](/pubspec.yaml) update the [CHANGELOG.md](/CHANGELOG.md) to add the new release
  - `bash tag-push.sh --version <major.minor.patch> --force`
- Edit the [CHANGELOG.md](/CHANGELOG.md) updating the new section to include the changes you want
- Commit the [CHANGELOG.md](/CHANGELOG.md) and the [pubspec.yaml](/pubspec.yaml) and push the tags, [CHANGELOG.md](/CHANGELOG.md) and [pubspec.yaml](/pubspec.yaml) to the remote server
  - `bash tag-push.sh --version <major.minor.patch> --force --push`

### Tag management hints

In case you need to manually update release tags

- Create a local tag `git tag 1.1.0+1`
- Delete a local tag `git tag -d 1.1.0+1`
- Push tags to remote `git push origin --tags`
- Delete a remote tag `git push origin --delete 1.1.0+1`
  - Deleting a remote tag will **not** work if there is a release tied to the tag

### Recommended IDE Extensions

#### Cursor Extensions

_. Dart
_. Flutter
_. markdownlint
_. Prettier (legacy) - Code formatter

#### VS Code Extensions

_. AI Toolkit for Visual Studio Code
_. Dart
_. Flutter
_. Flutter coverage
_. markdownlint
_. Markdown All in One
_. Markdown Preview Mermaid Support
_. Prettier

#### Antigravity Extensions

_. Dart
_. Flutter
_. markdownlint
_. Prettier (legacy) - Code formatter

### LLM Agent Support and Rules

#### LLM Agent Support

AI coding tools share a single rules layout:

- **[AGENTS.md](AGENTS.md)** — project rules for Cursor, GitHub Copilot, and Antigravity (keep under 12,000 characters for Antigravity)
- **[`.agents/skills/`](.agents/skills/)** — upstream [Dart](https://github.com/dart-lang/skills) and [Flutter](https://github.com/flutter/skills) skills, plus project skills (`fs-game-score-*`)

Cursor and Antigravity auto-discover skills from `.agents/skills/` when each skill has a valid `SKILL.md` with YAML frontmatter. Copilot reads `AGENTS.md`; project skills are referenced there for deeper workflows (live sync, testing, widget keys).

Removed redundant copies: `.cursor/rules/`, `.agents/rules/`, `.github/copilot-instructions.md`, and `.github/instructions/copilot.instructions.md`.

#### Superpowers support

This workspace auto configures superpowers in the workspace for `cursor` and `claude`.

| Tool              | Project-level plugin declaration | Config file                                                                           |
| ----------------- | -------------------------------- | ------------------------------------------------------------------------------------- |
| Claude Code       | ✅ Yes                           | .claude/settings.json → enabledPlugins                                                |
| Cursor            | ✅ Yes                           | .cursor/settings.json → plugins                                                       |
| GitHub Copilot    | ❌ No                            | No project-scoped config exists                                                       |
| Antigravity (agy) | ❌ No                            | No project-scoped config exists; all plugin state lives in ~/.gemini/antigravity-cli/ |
