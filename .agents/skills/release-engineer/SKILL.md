---
name: release-engineer
description: >
  Version tagging, pubspec/CHANGELOG bumps, and git tag push for fs-game-score releases.
  Use when cutting a release, running tag-push.sh, or preparing CHANGELOG sections.
---

# FS Score Card — Release engineer

Always use **`fvm`** for Flutter/Dart commands per [AGENTS.md](/AGENTS.md).

For **Flutter/Dart SDK upgrades** (FVM, CI workflows, pubspec constraints), use the
**`release-flutter-upgrade-sdk`** skill
([SKILL.md](../release-flutter-upgrade-sdk/SKILL.md)).

Script: [tag-push.sh](/tag-push.sh) at the repository root.

---

## Release tagging

Releases must be tagged and those tags pushed to Git.

The `+<build_id>` suffix in `pubspec.yaml` is **auto-calculated** from
`git rev-list --count HEAD` (no `--build-id` flag).

### `tag-push.sh` script

| Flag                            | Purpose                                             |
| ------------------------------- | --------------------------------------------------- |
| `--version <major.minor.patch>` | Required semver (e.g. `2.0.0`)                      |
| `--push`                        | Push commit and tag to remote                       |
| `--force`                       | Overwrite existing tag / pubspec version if present |

The script updates `pubspec.yaml`, prepends a `CHANGELOG.md` section when missing,
commits `chore: bump version to <version>+<build_id>`, and creates tag
`<version>+<build_id>`.

### Local only tagging

Set the version locally and edit local files:

```bash
bash ./tag-push.sh --version 2.0.0
```

- Updates pubspec.yaml version number plus the build ID for main from GitHub
- Updates CHANGELOG.md
- Tags local repository to the version in pubspec.yaml
- Does not push to remote

### Local tagging and push code and tag to remote

```bash
bash ./tag-push.sh --version 2.0.0 --push
```

- Updates pubspec.yaml version number plus the build ID for main from GitHub
- Updates CHANGELOG.md
- Tags local repository to the version in pubspec.yaml
- Pushes changes to remote
- Pushes tag to the remote

## Moving an exisiting tag after making changes

Tags the current location and force pushes that tag

```bash
bash ./tag-push.sh --version 2.0.0 --force --push
```

- Updates pubspec.yaml version number plus the build ID for main from GitHub
- Updates CHANGELOG.md
- Tags local repository to the version in pubspec.yaml moving the tag if it already exists
- Pushes changes to remote
- Pushes tag to the remote

---

## Before tagging

1. Ensure `CHANGELOG.md` has an accurate section for the release version (the script
   adds a stub `### Added` section if missing).
2. Run tests and analysis: `fvm flutter test`, `fvm flutter analyze`.
3. Confirm the user wants `--push` before pushing tags to remote.

## Creating Distributable Artifacts

Release packages can be built on different platforms.

| Build Platform | Shell              | Script                                               | Release Artifacts                         |
| -------------- | ------------------ | ---------------------------------------------------- | ----------------------------------------- |
| Windows        | Powershell         | [/build-distributable.ps1](/build-distributable.ps1) | Android, Web and Windows                  |
| Windows        | Cygwin or Git Bash | [/build-distributable.sh](/build-distributable.sh)   | Android, Web and Windows                  |
| Mac            | bash or zsh        | [/build-distributable.sh](/build-distributable.sh)   | Android, iOS iPhone, iOS iPad, MacOS, Web |
| Linux          | bash or zsh        | [/build-distributable.sh](/build-distributable.sh)   | Android, Web                              |

### Deployment Targets and Distribution Paths

| Platform   | Target                                                                                                   | Notes                       |
| ---------- | -------------------------------------------------------------------------------------------------------- | --------------------------- |
| Android    | [Github releases](https://github.com/freemansoft/fs-game-score/releases)                                 | Play Store not supported    |
| iOS iPhone | [Apple iOS iPhone App Store](https://apps.apple.com/us/app/freemans-score-card/id6755344139)             | .                           |
| iOS iPad   | [Apple iOS iPad App Store](https://apps.apple.com/us/app/freemans-score-card/id6755344139?platform=ipad) | .                           |
| macOS      | [Apple Mac App Store](https://apps.apple.com/us/app/freemans-score-card/id6755344139?platform=mac)       | .                           |
| Web        | [freemansoft.com](https://freemansoft.com/freemans-score-card/)                                          | .                           |
| Windows    | [Github releases](https://github.com/freemansoft/fs-game-score/releases)                                 | Windows store not supported |

GitHub releases is the release area for the source repo. A new Release is created on GitHub for every release tag.

## Publishing Artifacts

There are no tools or scripts currently for publishing artifacts
