---
name: fs-game-score-release-engineer
description: >
  Version tagging, pubspec/CHANGELOG bumps, distributable builds, and store release
  notes for fs-game-score. Use when cutting a release, running tag-push.sh, or
  preparing CHANGELOG sections.
---

# FS Score Card — Release engineer

Always use **`fvm`** for Flutter/Dart commands per [AGENTS.md](/AGENTS.md).

For **Flutter/Dart SDK upgrades** (FVM, CI workflows, pubspec constraints), use
**`release-flutter-upgrade-sdk`**
([SKILL.md](../release-flutter-upgrade-sdk/SKILL.md)).

Scripts at repository root: [tag-push.sh](/tag-push.sh),
[build-distributable.sh](/build-distributable.sh),
[build-distributable.ps1](/build-distributable.ps1).

Store assets: [app_store/](/app_store/) (per-platform READMEs).

---

## Release tagging

Releases must be tagged and those tags pushed to Git.

The `+<build_id>` suffix in `pubspec.yaml` is **auto-calculated** from
`git rev-list --count HEAD` on the **current branch** when you run the script
(no `--build-id` flag). Run `tag-push.sh` from the branch you intend to release
(usually `main`).

`tag-push.sh` is a **zsh** script and uses BSD `sed -i ''` — run it on macOS
(or ensure compatible `sed`).

### `tag-push.sh` options

| Flag                            | Purpose                                             |
| ------------------------------- | --------------------------------------------------- |
| `--version <major.minor.patch>` | Required semver (e.g. `2.0.0`)                      |
| `--push`                        | Push commit and tag to remote                       |
| `--force`                       | Overwrite existing tag / pubspec version if present |
| `--help`                        | Show usage                                          |

The script updates `pubspec.yaml`, inserts a `CHANGELOG.md` section when missing,
commits `chore: bump version to <version>+<build_id>` when there are staged
changes, and creates tag `<version>+<build_id>`. With `--push`, it runs `git push`
and **force-pushes the tag** (`git push --force origin <tag>`).

### Local only

```bash
bash ./tag-push.sh --version 2.0.0
```

- Updates `pubspec.yaml` (`<version>+<build_id>`)
- Adds a stub `## [version]` / `### Added` section to `CHANGELOG.md` if missing
- Commits and tags locally
- Does **not** push to remote

### Local and push to remote

```bash
bash ./tag-push.sh --version 2.0.0 --push
```

- Same as local, then pushes branch and tag to `origin`

### Move an existing tag after changes

```bash
bash ./tag-push.sh --version 2.0.0 --force --push
```

- Force-updates the annotated tag to the current commit
- Overwrites pubspec if the exact `version+build_id` already exists (with `--force`)
- Pushes branch and force-pushes the tag

Edit `CHANGELOG.md` with real release notes before or after running the script.
If the version section already exists, the script leaves it unchanged.

---

## Before tagging

1. Ensure `CHANGELOG.md` has an accurate section for the release version (the script
   adds a stub `### Added` section only when the `## [version]` heading is missing).
2. Run tests and analysis: `fvm flutter test`, `fvm flutter analyze`.
3. Confirm the user wants `--push` before pushing tags to remote.

---

## Creating distributable artifacts

Release packages are built on the **host OS** that owns each target toolchain.
See also [README.md — Build and Test](/README.md).

| Host OS | Shell      | Script                                                      | Targets built                                                  |
| ------- | ---------- | ----------------------------------------------------------- | -------------------------------------------------------------- |
| macOS   | bash / zsh | [build-distributable.sh](/build-distributable.sh)   | Android APK, Web, iOS IPA, macOS                               |
| Windows | PowerShell | [build-distributable.ps1](/build-distributable.ps1) | Android APK, Web, Windows, MSIX                                |
| Windows | Git Bash   | [build-distributable.sh](/build-distributable.sh)   | **Unreliable** — script header notes Git Bash is not supported |

`build-distributable.sh` uses `fvm` aliases on macOS. `build-distributable.ps1`
calls `flutter` / `dart` directly — prefer running from an FVM-enabled shell or
prefix commands with `fvm` manually.

Linux is **not** a supported release host in [README.md](/README.md)
(Linux row: not tested). Do not rely on `build-distributable.sh` on Linux for
production releases.

Web builds use `--base-href=/freemans-score-card/`.

---

## Deployment targets

| Platform            | Target                                                                                       | Notes                                       |
| ------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------- |
| Android             | [GitHub releases](https://github.com/freemansoft/fs-game-score/releases)                     | Play Store not used; APK from release build |
| iOS (iPhone / iPad) | [App Store](https://apps.apple.com/us/app/freemans-score-card/id6755344139)                  | Single IPA via `flutter build ipa` on macOS |
| macOS               | [Mac App Store](https://apps.apple.com/us/app/freemans-score-card/id6755344139?platform=mac) | Built on macOS                              |
| Web                 | [freemansoft.com](https://freemansoft.com/freemans-score-card/)                              | Deploy `build/web`                          |
| Windows             | [GitHub releases](https://github.com/freemansoft/fs-game-score/releases)                     | MS Store not used                           |

Create a **GitHub Release** for each pushed version tag. Attaching the Android APK
and Windows MSIX/exe is manual (no publish script).

---

## Apple App Store screenshots

App Store Connect requires screenshots per form factor, light and dark where
applicable. See [App Store Screen Shot Recommendations](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) Reference sizes and simulators down below. Screen shots can be taken on the Mac with `File -> Save Screen` in the simulator menu

Simulators can't run in release mode so disable the debug mode banner when running in development mode `debugShowCheckedModeBanner: false` in [main.dart](/lib/main.dart)

### Image sizes

#### iPad (13" display)

- 2064 × 2752 (portrait), 2752 × 2064 (landscape)
- 2048 × 2732 (portrait), 2732 × 2048 (landscape)

#### iPhone (6.5" display)

- 1284 × 2778 (portrait), 2778 × 1284 (landscape)
- 1242 × 2688 (portrait), 2688 × 1242 (landscape)

#### macOS

- 1280 × 800 (landscape)

### Simulators / devices (see `app_store/*/README.md`)

| Platform | Devices                                              |
| -------- | ---------------------------------------------------- |
| iPad     | iPad Air 13"                                         |
| iPhone   | iPhone 14 Plus, iPhone 13 Pro Max, iPhone 12 Pro Max |
| macOS    | Browser window at 1280 × 800                         |

---

## Publishing artifacts

There are **no** automated publish scripts. After building:

- Upload store builds via App Store Connect / Transporter (Apple)
- Attach Android APK and Windows packages to GitHub Releases
- Deploy web output to freemansoft.com hosting
