---
name: release-engineer
description: >
  Version tagging, pubspec/CHANGELOG bumps, and git tag push for fs-game-score releases.
  Use when cutting a release, running tag-push.sh, or preparing CHANGELOG sections.
---

# FS Score Card — Release engineer

Always use **`fvm`** for Flutter/Dart commands per [AGENTS.md](../../../AGENTS.md).

For **Flutter/Dart SDK upgrades** (FVM, CI workflows, pubspec constraints), use the
**`release-flutter-upgrade-sdk`** skill
([SKILL.md](../release-flutter-upgrade-sdk/SKILL.md)).

Script: [tag-push.sh](../../../tag-push.sh) at the repository root.

---

## Release tagging

Releases must be tagged and those tags pushed to Git.

The `+<build_id>` suffix in `pubspec.yaml` is **auto-calculated** from
`git rev-list --count HEAD` (no `--build-id` flag).

### `tag-push.sh` options

| Flag | Purpose |
| --- | --- |
| `--version <major.minor.patch>` | Required semver (e.g. `2.0.0`) |
| `--push` | Push commit and tag to remote |
| `--force` | Overwrite existing tag / pubspec version if present |

The script updates `pubspec.yaml`, prepends a `CHANGELOG.md` section when missing,
commits `chore: bump version to <version>+<build_id>`, and creates tag
`<version>+<build_id>`.

### Local only

Set the version locally and edit local files:

```bash
bash ./tag-push.sh --version 2.0.0
```

Example output:

```txt
Updated pubspec.yaml to version 2.0.0+255
CHANGELOG.md already contains section for version 2.0.0.
[main be9a7ff] chore: bump version to 2.0.0+255
 1 file changed, 1 insertion(+), 1 deletion(-)
Tagged repository with 2.0.0+255

Changes committed and tagged locally. Use --push to push to remote.
```

### Local and push to remote

```bash
bash ./tag-push.sh --version 2.0.0 --push
```

Example output:

```txt
Updated pubspec.yaml to version 2.0.0+256
CHANGELOG.md already contains section for version 2.0.0.
[main 5d1c5a5] chore: bump version to 2.0.0+256
 1 file changed, 1 insertion(+), 1 deletion(-)
Tagged repository with 2.0.0+256

Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
Delta compression using up to 10 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (6/6), 581 bytes | 581.00 KiB/s, done.
Total 6 (delta 4), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (4/4), completed with 2 local objects.
To https://github.com/freemansoft/fs-game-score.git
   0629ed9..5d1c5a5  main -> main
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/freemansoft/fs-game-score.git
 * [new tag]         2.0.0+256 -> 2.0.0+256
Committed and pushed changes and tag to remote.
```

## Moving a tag after making changes

Tags the current location and force pushes that tag

```bash
bash ./tag-push.sh --version 2.0.0 --force --push
```

Example output:

```bash
Updated pubspec.yaml to version 2.0.0+258
CHANGELOG.md already contains section for version 2.0.0.
[main 1faf124] chore: bump version to 2.0.0+258
 1 file changed, 1 insertion(+), 1 deletion(-)
Force-tagged repository with 2.0.0+258
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 10 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 306 bytes | 306.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To https://github.com/freemansoft/fs-game-score.git
   4ff8275..1faf124  main -> main
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 169 bytes | 169.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/freemansoft/fs-game-score.git
 * [new tag]         2.0.0+258 -> 2.0.0+258
Committed and pushed changes and tag to remote.
```

---

## Before tagging

1. Ensure `CHANGELOG.md` has an accurate section for the release version (the script
   adds a stub `### Added` section if missing).
2. Run tests and analysis: `fvm flutter test`, `fvm flutter analyze`.
3. Confirm the user wants `--push` before pushing tags to remote.
