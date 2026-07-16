---
name: run-fs-game-score
description: Build, run, drive, and screenshot the fs_score_card Flutter app. Use when asked to start the app, launch it, run its integration flow, take a screenshot of its UI, or confirm a change works in the real running app (not just tests).
---

`fs_score_card` (FreemanS Score Card) is a multi-platform Flutter app. The
reliable programmatic way to launch it and capture screenshots on this machine
is `flutter drive` against a **Chrome web** target: `chromedriver` + a smoke
flow that walks splash → score table and writes PNGs. The two harness pieces:

- **Flow (drive target):** [integration_test/run_skill_smoke_test.dart](../../../integration_test/run_skill_smoke_test.dart) — mounts the real `Phase10App` widget tree, drives splash → score table, calls `takeScreenshot`.
- **Host driver:** [.agents/skills/run-fs-game-score/drive_screenshots.dart](drive_screenshots.dart) — the `flutter drive` `--driver` script that writes each screenshot to `build/driver-screenshots/`.

All paths below are relative to the repo root. **Always use `fvm flutter` /
`fvm dart`, never bare `flutter` / `dart`** (see AGENTS.md — FVM pins Flutter
3.44.0; a mismatched system Flutter corrupts the build cache).

## Prerequisites

macOS host with FVM already set up (this repo pins Flutter 3.44.0 via `.fvmrc`).
Screenshots go through `chromedriver`, whose **major version must match your
installed Chrome** (Chrome 150 → chromedriver 150 here):

```bash
brew install --cask chromedriver
# brew's chromedriver is Gatekeeper-quarantined; clear it or it won't launch:
xattr -d com.apple.quarantine "$(readlink -f /opt/homebrew/bin/chromedriver)"
chromedriver --version   # must print, and major must match Chrome
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --version
```

## Setup

```bash
fvm flutter pub get
```

## Run (agent path)

Start `chromedriver` in the background, then drive the app. Screenshots land in
`build/driver-screenshots/`.

```bash
chromedriver --port=4444 >/tmp/chromedriver.log 2>&1 &
# confirm it's up:
curl -s http://localhost:4444/status | grep -q '"ready"' && echo "chromedriver ready"

fvm flutter drive \
  --driver=.agents/skills/run-fs-game-score/drive_screenshots.dart \
  --target=integration_test/run_skill_smoke_test.dart \
  -d web-server --browser-name=chrome --driver-port=4444
```

Success looks like (exit code 0):

```
driver-screenshot: build/driver-screenshots/01-splash.png (27890 bytes)
driver-screenshot: build/driver-screenshots/02-score-table.png (34179 bytes)
All tests passed.
```

Artifacts:

| file                                          | what it shows                               |
| --------------------------------------------- | ------------------------------------------- |
| `build/driver-screenshots/01-splash.png`      | Splash / new-game config screen             |
| `build/driver-screenshots/02-score-table.png` | Score table (default 8 players × 14 rounds) |

Then `Read` the PNGs to confirm the UI actually rendered — don't trust the exit
code alone. To screenshot a different flow, edit the drive target
([integration_test/run_skill_smoke_test.dart](../../../integration_test/run_skill_smoke_test.dart)):
add taps/entries and more `binding.takeScreenshot('NN-name')` calls, then re-run
the same command.

## Run (human path)

For an interactive window on a real device (not for screenshots — see Gotchas):

```bash
fvm flutter run -d macos    # native macOS window; press q to quit
fvm flutter run -d chrome   # opens Chrome; Ctrl-C to quit
```

`fvm flutter devices` lists what's attached (macOS, Chrome, and any wired/wireless iOS devices).

## Test

```bash
fvm flutter test                     # unit + widget tests (fast, headless, no chromedriver)
fvm flutter analyze                  # must be clean; project uses very_good_analysis
```

The project's full on-device integration suite is separate from this skill's
smoke flow and uses the same `flutter drive` mechanism:

```bash
fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d web-server --browser-name=chrome --driver-port=4444
```

## Gotchas

- **The drive target must live under `integration_test/`.** That's why the smoke
  flow is at `integration_test/run_skill_smoke_test.dart`, not inside this skill
  dir. Put it elsewhere and the native `integration_test` plugin never registers
  → `MissingPluginException: No implementation found for method captureScreenshot`.
- **macOS desktop can't take integration_test screenshots** in this version —
  `takeScreenshot` on `-d macos` throws the same `captureScreenshot`
  `MissingPluginException`. Screenshots require the **web** target. (macOS is
  fine for the human-path `flutter run`.)
- **Don't call `main.bootstrapApp()` from the drive target on web.** On web it
  runs `SemanticsBinding.instance.ensureSemantics()` and never disposes the
  handle; flutter_test's end-of-test check then fails the drive with
  _"A SemanticsHandle was active at the end of the test"_ — **after** the
  screenshots are already written, so it looks like a spurious failure. The
  smoke flow instead pumps the same `UncontrolledProviderScope(container,
Phase10App())` tree directly (full UI fidelity, clean teardown).
- **`flutter run -d macos` under a non-interactive/agent shell** prints
  `Failed to foreground app; open returned 1` and the window never comes
  forward — so OS-level `screencapture` gets nothing. Use the web drive path for
  screenshots.
- **`build/` is gitignored**, so `build/driver-screenshots/*.png` are scratch
  artifacts — read them, don't expect to commit them.

## Troubleshooting

- **`chromedriver --version` prints nothing / won't launch**: Gatekeeper
  quarantine. Run the `xattr -d com.apple.quarantine …` line from Prerequisites.
- **`session not created: This version of ChromeDriver only supports Chrome
version N`**: chromedriver major ≠ Chrome major. `brew upgrade --cask
chromedriver` (and re-clear quarantine), or install the matching build.
- **`integration_test plugin was not detected` / `captureScreenshot`
  MissingPluginException**: the `--target` isn't under `integration_test/`, or
  you targeted `-d macos`. Use the web target under `integration_test/`.
- **Drive hangs at `Waiting for connection from debug service`**: `chromedriver`
  isn't running on 4444. Start it (Run section) and re-check
  `curl -s http://localhost:4444/status`.
