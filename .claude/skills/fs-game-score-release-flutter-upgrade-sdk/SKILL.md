---
name: fs-game-score-release-flutter-upgrade-sdk
description: >
  Procedure for upgrading the Flutter and Dart SDK versions across the monorepo.
  Covers FVM config, GitHub actions, pubspec.yaml constraints, and changelogs.
---

# Flutter SDK Upgrade Protocol

Follow this procedure when upgrading the Flutter and Dart SDK versions used in this repository. Ensuring all configurations, packages, and CI pipelines stay in sync is critical for monorepo health.

**Related skills:** `fs-game-score-release-engineer`
([SKILL.md](../fs-game-score-release-engineer/SKILL.md)) — version tagging,
CHANGELOG bumps, and distributable builds once the SDK upgrade lands.

## 1. Upgrade FVM (Flutter Version Management)

FVM is the source of truth for the local development environment. `fvm flutter --version` will automatically update the fvm managed local flutter to the correct version if it is not already installed.

You can manually update flutter versions by running:

- Run `fvm install <new-flutter-version>` (e.g., `fvm install 3.44.0`) in the root of the repository if the new target version of flutter is not already installed.
- Run `fvm use <new-flutter-version>` (e.g., `fvm use 3.44.0`) in the root of the repository.
- Verify that **`.fvmrc`** — the tracked source of truth — now reads `{ "flutter": "<new-flutter-version>" }`, and commit it. (`.fvm/fvm_config.json` is a legacy, gitignored file `fvm use` also writes; `.fvmrc` is the one that must be committed.)

## 2. Update CI/CD Workflows

The GitHub Actions workflows must use the exact same Flutter version as FVM to prevent CI drifts.

- Search `.github/workflows/` for `subosito/flutter-action` (this repo uses platform integration workflows, e.g. `android_integration_test.yaml`, `ios_integration_test.yaml`, `macos_integration_test.yaml`, `windows_integration_test.yaml`).
- Update every `flutter-version:` parameter to match the new FVM version exactly.

## 3. Update Package `pubspec.yaml` Files

All packages in the monorepo should share the same minimum Dart/Flutter SDK requirements.

- Locate all `pubspec.yaml` files across the repository.
- Update the `environment:` constraints to match the new minimum Dart SDK (and optionally Flutter SDK) corresponding to the new Flutter version.

  ```yaml
  environment:
    sdk: ^<new-dart-version>
  ```

## 4. Update Changelogs

Document the SDK bump so consumers of the packages are aware of the new minimum requirements.

- Add a bullet point to the `CHANGELOG.md` file for every updated package under the `Unreleased` or upcoming version heading.
- Example: `- Require Dart SDK <new-dart-version> and Flutter <new-flutter-version>`

## 5. Update Version Mentions in Skills and Docs

Some skills pin the Flutter version in prose (e.g. `run-fs-game-score` states the
`.fvmrc`-pinned version so agents don't corrupt the build cache with a mismatched
system Flutter). Stale mentions silently mislead future sessions.

- Grep `.agents/skills/` (canonical location; `.claude/skills` is a symlink to it)
  for the **old** Flutter version and update every hit to the new version.
- Do the same for `AGENTS.md` and `README.md` if they name the version.

## 6. Verify the Upgrade

Ensure that the new SDK version does not break existing code or cause new linting errors.

- Ensure dependencies are resolved (using `fvm flutter pub get` or `upgrade` at the workspace root).
- Run `fvm flutter analyze` to catch any new static analysis errors or deprecations introduced by the newer SDK.
- Run `fvm flutter test` to ensure all tests continue to pass.
- Fix any deprecations or breaking changes introduced by the new Flutter/Dart version before committing.
