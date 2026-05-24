#
# This Powershell script is for Windows only
# It was copied from build-distributable.sh
#

# wish there was a good way to alias flutter and dart with fvm

Write-Host "Building all release targets avaialble on a Windows Build system..."

Write-Host "Cleaning previous build artifacts..."
flutter clean

Write-Host "Building Android APK..."
flutter build apk --target-platform android-arm64

Write-Host "Building Web for distribution on freemansoft.com..."
flutter build web --base-href=/freemans-score-card/

Write-Host "Building Windows..."
flutter build windows

Write-Host "Installing MSIX creator tool (Flutter Pub)..."
flutter pub run msix:create

Write-Host "Creating MSIX (Dart Run)..."
dart run msix:create
