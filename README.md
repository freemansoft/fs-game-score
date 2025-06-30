# fs_game_score

This is a generic game scoring app created with virtually zero hand coding but a **lot** of AI agent prompts using copilot

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
