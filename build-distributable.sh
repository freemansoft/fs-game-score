#!/bin/bash

# The windows side of this does not work for git bash

# Detect OS
OS="$(uname)"
echo "Detected OS: $OS"

if [[ "$OS" == "Darwin" ]]; then
  echo "Running macOS build steps..."

  echo "Cleaning..."
  flutter clean

  echo "Building Android APK..."
  flutter build apk --target-platform android-arm64

  echo "Building Web..."
  flutter build web --base-href=/freemans-score-card/

  echo "Building iOS IPA..."
  # Note: This requires a valid provisioning profile and code signing identity.
  flutter build ipa --release

  echo "Building macOS..."
  flutter build macos --release

elif [[ "$OSTYPE" == "linux-gnu" || "$OS" =~ MINGW.* || "$OS" =~ CYGWIN.* || "$OS" =~ MSYS.* ]]; then
  # this worked for gitbash on windows 11 at 2026-02-11
  # this may fail with fvm
  echo "Running Windows build steps..."

  echo "Cleaning..."
  flutter clean

  echo "Building Android APK..."
  flutter build apk --target-platform android-arm64

  echo "Building Web..."
  flutter build web --base-href=/freemans-score-card/

  echo "Building Windows..."
  flutter build windows

  echo "Installing MSIX creator tool (Flutter Pub)..."
  flutter pub run msix:create

  echo "Creating MSIX (Dart Run)..."
  dart run msix:create

else
  echo "Unsupported OS: $OS"
  exit 1
fi

echo "Build script completed."
