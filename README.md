# fs_score_card

The application Implements a scorecard for an arbitrary number of players and game _rounds_.  It has been tested on Android, IOS, Chrome, macOS, and Windows 11.
Two scorecard types are supported

1. Basic scorecard with individual round scores and player total scores
2. Phase capture plus individual round scores and player total scores _plus_ dropdowns that let you pick a completed phase. Hovering over the player's total score will show you which phases have been captured (the set of phase dropdown selections)

Preferences

1. The game configuration is saved to SharedPreferneces when a game is started
2. The game configuration is loaded as the default when showing the spalsh screen to start a new game

Notes

1. Player's names can be edited by clicking on the name cell in the scoring table. The name can be changed in the modal editing panel that appears.
2. Round scores can be edited by clicking on a score cell in the scoring table. The round score can be changed in the modal editing panel that ppears.
    1. The aggregated player scores will be totaled under the player's name.
3. The "New Game" iconin the app bar. will clear the board scores and optionally the player names for times you want to change the order
4. The "Home" or "Change Score Card Type" icon in the app bar will let you return to the start screen that lets you change the number of players and the data entry types (score & phase)

## Known Issues

- Restarting the same game config does not change the gameId. This is a "feature"
- Reloading the web app wipes out the current game because state is not stored
- When debugging with the IDE, the LocalStorage is not persisted across sessions. This is a "feature" of the fact that the web session is on a different port every time it is run.
- Unable to get macOS integration tests to run as GitHub Actions due to code signing requirement.
- Unable to get iOS integration tests to run reliably as GitHub Actions. Cause to be determined.

## Looking to run the working scoring app?

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
4. Select the run view on the left hand side
5. Select fs_score_card in the run drop down menu
6. Press the green run button
7. The application will run on an emulator, simulator, macos, windows, web or connected device.

## Internationalization

Make sure to gegenerate the dart localization files after making any changes to the `arb` files. The command `flutter gen-l10n` has already been run.

`flutter pub get` or do a build.

## Build and Test

You can test this locally using

- The IDE and the Android simulator on Mac or PC
- The IDE and the iOS emulator on Mac
- The IDE and a hardware connected Android device on a Mac or PC
- The IDE and a hardware connected iOS device on a Mac
- macOS app on a Mac
- windows fat app on PC
- A Web App on Mac or PC

### Android builds

#### Android test builds - side loading

1. (Android) Create an apk and downloaded it to a device
   1. Build the android arm64 package. Including the `android-arm64` makes it a single target binary and drops the size from 23MB to 8MB
      1. `flutter build apk --target-platform android-arm64`
      2. The parameter `android-arm64` makes it a single target binary and drops the size from 23MB to 8MB. There aren't any interesting x86 android devices anyway.
   2. Share `build/app/outputs/apk/release/fs_score_card-v<release>-release.apk` to devices. This can be done by emailing or by pushing the apk to a shared storage
      1. You can share the generic named apk from `build/outputs/flutter-apk/app-release.apk` There should be an associated `sha` file there.

Android build notes:
Android apks end up bult in two places. [Stack Overflow](https://stackoverflow.com/questions/62910148/flutter-what-is-the-difference-between-the-apk-release-directory-and-flutter-ap)

- `build/app/outputs/apk` Including app name and version in the `apk` filename.
  - `build/app/outputs/apk/releasefs_score_card-v<version>-release.apk`
  - `build/app/outputs/apk/debug/fs_score_card-v<version>-debug.apk`
- `build/app/outputs/flutter-apk` Generic apk without the app name and version in the `apk` filename. These include sha1 files.
  - `build/app/outputs/flutter-apk/apk-release.apk`
  - `build/app/outputs/flutter-apk/app-debug.ap`

#### Google Play Store (tentative)

- Onboarding
  - Enable the in your workspace[google play store service](https://admin.google.com/ac/managedsettings/805142757380)
  - [Create releases in the Google Play store console](https://play.google.com/console/)
  - Onboard to the store, pay $25, verify identity
  - Connect to <https://play.google.com/console> and verify your account
  - Install the Google Play console app on your android device and authenticate
  - Set up the signing keys
- Build the app bundle with `flutter build appbundle --release`
  - That doesn't work because it has to be signed.
  - ...

### iOS Builds

#### iOS Test builds

You can test this locally using the IDE and the iOS simulator or hardware connected ios device on a Mac.

Standalone testing is driven through [Apple store connect](https://appstoreconnect.apple.com/)

1. open the `ios` folder in xcode if you need to. I didn't need xcode for iOS builds the way I did for MacOS.
2. `flutter build ipa` or `flutter build ipa --release`
3. Do the store thing - upload the ipa via Apple **Transporter** app and do all the configuration in testflight and the store

Alternatively - use the xcode archive route like we do for macOS

1. `flutter build ipa --release` to build the ios app and copy info from `pubspec.yaml` into the xcode iOS files
2. Open the `ios` project in XCode. This opens the iOS target of the Flutter project
3. `Product > Archive`
4. `Validate App` --> `Validate`
5. `Distribute App` --> `App Store Connect`

Validate the version number and build ID on the splash screen. It should match the value in `pubpspec.yaml`. The version number is set in `pubspec.yaml`.

### MacOS builds

#### MacOS test builds

You can test this locally using the IDE on a Mac

MacOS builds are separate from iOS builds and must be uploaded to the store separately. Follow <https://docs.flutter.dev/deployment/macos>

1. `flutter build macos --release` to build the project and copy the `pubspec.yaml` into the xcode macOS files
2. Open the `macOS` directory in XCode. This opens the MacOS target of the Flutter project.
    1. XCode `Product > Archive` it will build an archive
    2. A new XCode window will pop up
    3. XCode `Validate App` --> `Validate`
    4. XCode `Distribute App` --> `App Store Connect`

Validate the version number and build ID on the splash screen. It should match the value in `pubpspec.yaml`. The version number is set in `pubspec.yaml`.

To release macOS after TestFlight. This works for iOS also

1. Open AppStoreConnect web site
2. Navigagte to App `FreemanS Score Card`
3. Click on the `+` sign next to `macOS App` and create the new release
4. Scroll down and add the `Build` you wish to this release.
5. Update images, text and other data and then submit for review

### Web test builds

#### Web build distribution

You can test this locally using the IDE and a web browser like Chrome

1. Create a distributable web package that can be distributed for people to web test locally
   1. Build the package `flutter build web` or `flutter build web --release`
   2. create a zip file of `build/web`
   3. Share the zip. They can unzip it and put the contents of the `web` folder in the web server docroot. The `web` folder should not be part of the path.

#### Web site build when web site is rootted in a subdirectory, not in a root directory

Change this to match your deployment. These notes exist so I remember the process!

The following works for hosting this app on my `github.io` pages. I host this app on my [github.io pages](https://freemansoft.github.io/freemans-score-card).

1. Build the web app with `flutter build web --base-href=/freemans-score-card/`
2. Copy the contents of `build/web` **excluding the canvaskit directory** to a local clone of <https://github.com/freemansoft/freemansoft.github.io>
   1. We are going to use the Google CDN CanvasKit and don't need to take up space in our repo with the binary
3. You can test the site locally by running `python -m http.server 8000` from a terminal prompt in the root of the github.io repo and navigating to <http://localhost:8000/freemans-score-card/>
4. Commit the files and push them to GitHub.
5. Test with GitHub pages <https://freemansoft.github.io/freemans-score-card>

### Windows Builds

#### Windows test builds

You can test this locally using the IDE on a Windows machine.

1. Build the image on a windows machine with `flutter build windows`
1. Double click on the `exe` in `build\\windows\x64\runner\Release\fs_score_card.exe`
1. You **cannot** copy just the exe somewhere and expect it to work

#### Build an installer package

An `msix` section has already been added to customize the `msi` installer creator output <https://pub.dev/packages/msix>

1. Build the image on a windows machine with `flutter build windows`
1. Use the `msix` package to create a windows installer
   1. `flutter pub run msix:create`
   1. `dart run msix:create` this will offer to install a self signed `pfx`
1. Copy the created `msix` file located in `build\windows\x64\runner\Release\fs_score_card.msix` to the target location where it can be installed from.

#### Windows store builds

_to be documented_ Windows standalone app packaged builds.

- see docs <https://docs.flutter.dev/deployment/windows>

## Integration tests

Integration tests can't be run against browsers. Web based integration tests are not supported (2025/07)

The integration tests were generated by copilot and are copilot updated. You can run them with

```bash
flutter test integration_test/app_test.dart
```

| Platform | Support                        | GitHub Action Status                      |
| -------- | ------------------------------ | ----------------------------------------- |
| MacOS    | yes                            | Disabled due to code signing requirements |
| Windows  | yes                            | Enabled - cheapest because no emulator    |
| Linux    | not tested                     | Not tested                                |
| Android  | yes                            | Not yet implemented                       |
| iOS      | yes                            | Disabled due to expense                   |
| Web      | integration test not supported | Does not exist                            |

[GitHub actions](https://github.com/freemansoft/fs-game-score/actions) run integration tests on various platforms when repo receives `push` to GitHub.
Files are located in [github workflows](./.github/workflows)

## Android Notes

1. Java 21 installations will get an error because this is using gradle 8.10.2 which matches Java 23.
2. I'm on Java 21 matches against gradle 8.5
3. This android build requires at least gradle 8.7.
4. If you go to plugin version 8.8 to work with gradle 8.10.2 you get an ndk version error
5. So we left the "Could not create task generateLockfiles error.

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

## Icons

Android and IOS icons generated using the [appicon.co App Icon Generator](https://www.appicon.co/). The resulting icon is in `/assets/logos` All icons are derived from this 1024x1024 image.

Use [flutter_launcher_icons](https://github.com/fluttercommunity/flutter_launcher_icons) to create change the icons for all the targets. `flutter_launcher_icons` configuration is in `pubspec.yaml`

```bash
dart run flutter_launcher_icons
```

## Creating a release tag

- Create a tag, update the pubspec.yaml update the CHANGELOG to add the new release
  - `bash tag-push.sh --version <major.minor.patch> --build-id <build-number> --force`
- Edit the CHANGELOG.md updating the new section to include the changes you want
- Commit the changelog and the pubspec.yaml and push the tags, changelog and pubspec.yaml to the remote server
  - `bash tag-push.sh --version <major.minor.patch> --build-id <build-number> --force --push`

## Tag management hints

In case you need to manually update release tags

- Create a local tag `git tag 1.1.0+1`
- Delete a local tag `git tag -d 1.1.0+1`
- Push tags to remote `git push origin --tags`
- Delete a remote tag `git push origin --delete 1.1.0+1`
  - Deleting a remote tag will **not** work if there is a release tied to the tag

## Recommended IDE Extensions

### Cursor Extensions

*. Dart
*. Flutter
*. mardownlint
*. Prettier (legacy) - Code formatter

### VS Code Extensions

*. AI Tookit for Visual Studio Code
*. Dart
*. Flutter
*. Flutter coverage
*. mardownlint
*. Markdown All in One
*. Makdown Preview Mermaid Support
*. Prettier
