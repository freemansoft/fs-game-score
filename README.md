# fs_game_score

I wanted a scoring app for game night around the same time I needed a reason to push to actually use an LLM to do the heavy lifting for app development.  This project is the result.

This is a generic game scoring app created almost completely using VSCode's copilot agent mode with virtually zero hand coding.  There was a **lot** of AI agent prompts using copilot.

Lessons learned.

1. It helps if you know what libraries you want to use. That lets you direct the copilot to the most up to date or best practice libraries.  I knew I wanted to use Riverpod 3.x and that I needed somethign beyond the default Flutter table. I prompted to add the libraries I wanted and then built on top of that because the pubspec.yaml was in context for my prompts. Copilot only knows the code it nows and there is more _older_ code out there than code using newer libraries.
2. The agent tends to generate long functions or methods when building the UI layout. I wanted smaller discrete components so I either prompted to build the components or prompted to extract the code from the scoring table or other layouts into their own components.
3. I had to provide guidance for model objects especially if I wanted scope management or had cases where I wanted to retain state for various pieces of data.  There as a fair amount of trial and error when adding things like the "new game" panel to make sure things didn't get completely erased when I added the column locking controls or reset player names.
4. The Riverpod code was finicky because the notifiers scope or data objects didn't handle the corner cases.  Describing the broken nature was enough for Copilot to fix the problem about 50% of the time.
5. I wanted the code to be testable and for the widgets to be findable by `ID`. I prompted to get IDs added everywhere. Most of my widgets were wrappers for the actual field or text that the component represented.  This created tension between where we wanted a `key` to be bound too.  Some of the components were generated passing in a `key`.  Some were generated supporting a `FieldKey` that was actually set on the wrapped component. I ended up standardizing on a key for the custom component.  This meant the actual text or field had to be found in test by searching for descendants of the ID I knew. The alternative was to pass in two keys or only support the `field key`
6. There were a lot of iterations around state management trying to get the lifespan correct for various Riverpod notifiers and `ref.watch` `ref.read` operations.
7. I had to do some fiddling to get the `Semantics` I wanted.  There were a couple cases where providing the same prompt twice in a row solved my problem.  There first one did most of the work and the 2nd one fixed the broken part.
8. Integration tests: Long droplist are not fully visible when pressed on if the number of options is too long. Copilot never offered to scroll to find the item I wanted. Getting the CoPilot to scroll to find the items I was looking for was painful.  It never did generate exactly the code I would have wanted. The code at this time is a bit of a hack where it scrolls by some big amount to force the other end to become visible.
9. Integration tests: Copilot mostly got the field keys right when using finders `byKey`. Sometimes it completely lost the plot when trying to iterate fixes hallucenating key names especially fi they were generated.
10. Integration tests: My components had keys.  The actual component we needed to enter data in or validate against was some wrapped component. I had trouble prompting for a solution. The good news is that working with that type of component was a lot easier to prompt for as part of the test once we had a project example. Then it was almost automatic.

## This app

Implements a scorecard for an arbitrary number of players and game _rounds_

Two scorecard types are supported

1. Basic scorecard with individual round scores and player total scores
2. Phase capture plus individual round scores and player total scores _plus_ dropdowns that let you pick a completed phase.  Hovering over the player's total score will show you which phases have been captured (the set of phase dropdown selections)

Notes

1. Player's names can be edited in place in the scoring table.
2. Round scores can be edited in place in the appropriate columns.  Scores will be totaled under the player's name.
3. The "New Game" icon will clear the board scores and optionally the player names for times you want to change the order
4. The "Home" or "Change Scoreboard Type" icon will let you return to the start screen that lets you change the number of players and the data entry types (score & phase)

## Looking to run the working scoring app?

### Option 1

1. Clone this repo.
2. Open the whole repo in VSCode
3. Select the run view on the left hand side
4. Select fs_game_score in the run drop down menu
5. Press the green run button
6. The application will run on an emulator or connected device.

### Option 2

1. Clone this repo.
2. Open the `fs_game_score` directory in VSCode.
3. Run the Flutter application using the debug button or by pressing `F5`
4. The application will run on an emulator or connected device.

## Integration tests

Integration tests can't be run against browsers.  Web based integration tests are not supported (2025/07)

The integration tests were generated by copilot and are copilot updated.  You can run them with

```bash
flutter test integration_test/splash_screen_test.dart
flutter test integration_test/score_table_test.dart
```

You can run all of the integration tests in a single command when targeting mobile platforms.

```bash
flutter test integration_test/*_test.dart
```

1. MacOS - can only run tests individually
2. Windows - not tested
3. Linux - not tested
4. Android - Yes
5. iOS - Yes
6. Web - integration test not supported

## Notes

1. Java 21 installations will get an error because this is using gradle 8.10.2 which matches Java 23.
2. I'm on Java 21 matches against gradle 8.5
3. This android build requires at least gradle 8.7.
4. If you go to plugin version 8.8 to work with gradle 8.10.2 you get an ndk version error
5. So we left the "Could not create task generateLockfiles error.

| Java | Gradle (min) | Android Plugin |
| ---- | ------------ | -------------- |
| 21   | 8.4          | 8.3            |
| ??   | 8.6          | 8.4            |
| ??   | 8.7          | 8.5            |
| 22   | 8.7          | 8.6            |
| ??   | 8.9          | 8.7            |
| 23   | 8.10.2       | 8.8            |

1. <https://docs.gradle.org/current/userguide/compatibility.html>
2. <https://developer.android.com/build/releases/gradle-plugin>

## Icons

Android and IOS icons generated using the [appicon.co App Icon Generator](https://www.appicon.co/)
