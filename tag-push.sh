#!/bin/zsh
# tag-push.sh
# Usage: ./tag-push.sh --version <semver> [--commit-and-push]

set -e

function usage() {
  echo "Usage: $0 --version <major.minor.patch> [options]"
  echo
  echo "Options:"
  echo "  --version <major.minor.patch>   Set the version (required, semantic versioning)"
  echo "  --build-id <number>             Optional build id appended to version (default: 1)"
  echo "  --push                          Push committed changes and tag to remote"
  echo "  --force                         Force tag creation, overwrite existing tag if present"
  echo "  --help                          Show this help message and exit"
  exit 1
}

# Parse arguments

VERSION=""
PUSH=false
FORCE=false
BUILD_ID=1

while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      shift
      VERSION="$1"
      ;;
    --build-id)
      shift
      BUILD_ID="$1"
      ;;
    --push)
      PUSH=true
      ;;
    --force)
      FORCE=true
      ;;
    --help)
      usage
      ;;
    *)
      usage
      ;;
  esac
  shift
done

if [[ -z "$VERSION" ]]; then
  echo "Error: --version is required."
  usage
fi

# Validate semantic versioning: major.minor.patch
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in semantic versioning format: major.minor.patch"
  usage
  exit 2
fi
# Validate BUILD_ID is numeric and > 0
if ! [[ $BUILD_ID =~ ^[0-9]+$ ]]; then
  echo "Error: --build-id must be a positive integer. Received: $BUILD_ID"
  usage
  exit 2
fi

VERSION_BUILD="$VERSION+$BUILD_ID"
tag_name="$VERSION_BUILD"

# Check if tag already exists (unless --force)
if ! $FORCE; then
  if git tag --list | grep -q "^$tag_name$"; then
    echo "Error: Tag $tag_name already exists. Aborting."
    exit 3
  fi
fi

# Check if version is already in pubspec.yaml (unless --force)
if ! $FORCE; then
  if grep -q "^version: $VERSION_BUILD" pubspec.yaml; then
    echo "Error: pubspec.yaml already contains version $VERSION_BUILD. Aborting."
    exit 4
  fi
fi

# Update pubspec.yaml version
if grep -q '^version:' pubspec.yaml; then
  sed -i ''  "s/^version: *.*/version: $VERSION_BUILD/" pubspec.yaml
else
  echo "version: $VERSION_BUILD" >> pubspec.yaml
fi

echo "Updated pubspec.yaml to version $VERSION_BUILD"

# Update CHANGELOG.md with new version section if not present
CHANGELOG_FILE="CHANGELOG.md"
TODAY=$(date +%Y-%m-%d)
NEW_SECTION="## [$VERSION] - $TODAY\n\n### Added\n\n"

if ! grep -q "^## \[$VERSION\]" "$CHANGELOG_FILE"; then
  awk -v new_section="$NEW_SECTION" 'NR==1{print; next} /^## / && !done {print new_section; done=1} {print}' "$CHANGELOG_FILE" > "$CHANGELOG_FILE.tmp" && mv "$CHANGELOG_FILE.tmp" "$CHANGELOG_FILE"
  echo "Added new section to CHANGELOG.md for version $VERSION."
else
  echo "CHANGELOG.md already contains section for version $VERSION."
fi

git add pubspec.yaml "$CHANGELOG_FILE"


# Only commit if there are staged changes
if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "chore: bump version to $VERSION_BUILD" pubspec.yaml "$CHANGELOG_FILE"
fi

# Tag after commit
if $FORCE; then
  git tag -fa "$tag_name" -m "force update tag $tag_name"
  echo "Force-tagged repository with $tag_name"
else
  git tag "$tag_name"
  echo "Tagged repository with $tag_name"
fi

# Only push if --push is set
if $PUSH; then
  git push
  git push --force origin "$tag_name"
  echo "Committed and pushed changes and tag to remote."
else
  echo "Changes committed and tagged locally. Use --push to push to remote."
fi
