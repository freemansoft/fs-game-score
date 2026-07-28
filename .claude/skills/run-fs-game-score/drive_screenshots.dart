import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// `flutter drive` host-side driver that writes screenshots to disk.
///
/// The default `integrationDriver()` (from `integration_test_driver.dart`) has
/// no `onScreenshot` hook and drops screenshot bytes on the floor. This variant
/// uses `integration_test_driver_extended.dart` and persists every
/// `binding.takeScreenshot(name)` call made by the drive target into
/// `build/driver-screenshots/<name>.png`, so an agent (or human) can actually
/// look at the running app afterwards.
///
/// Usage (from repo root), with `chromedriver --port=4444` already running:
///   fvm flutter drive \
///     --driver=.agents/skills/run-fs-game-score/drive_screenshots.dart \
///     --target=integration_test/run_skill_smoke_test.dart \
///     -d web-server --browser-name=chrome --driver-port=4444
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final dir = Directory('build/driver-screenshots');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final file = File('${dir.path}/$name.png')..writeAsBytesSync(bytes);
      // Surface where the screenshot landed in the drive output.
      // ignore: avoid_print
      print('driver-screenshot: ${file.path} (${bytes.length} bytes)');
      return true;
    },
  );
}
