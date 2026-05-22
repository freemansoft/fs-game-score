import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/app.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// https://github.com/flutter/flutter/issues/175606#issuecomment-3453392532
// Error introduced with iPad IOS 26.1 due to iPad window handling

// Top level global
bool _zeroOffsetPointerGuardInstalled = false;
// retrieved from package info
String? appVersion;

void _installZeroOffsetPointerGuard() {
  if (_zeroOffsetPointerGuardInstalled) return;
  GestureBinding.instance.pointerRouter.addGlobalRoute(
    _absorbZeroOffsetPointerEvent,
  );
  _zeroOffsetPointerGuardInstalled = true;
}

void _absorbZeroOffsetPointerEvent(PointerEvent event) {
  if (event.position == Offset.zero) {
    GestureBinding.instance.cancelPointer(event.pointer);
  }
}

Future<void> _loadVersion() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.buildNumber.isNotEmpty) {
      appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } else {
      appVersion = packageInfo.version;
    }
    // forgot what the fromPlatform can throw
    // ignore: avoid_catches_without_on_clauses
  } catch (_) {
    appVersion = null;
  }
}

/// Initializes bindings, loads version and prefs, then mounts the app.
///
/// Await this from integration tests so startup completes before pumping frames.
/// On slower devices, calling `main` without awaiting races `runApp` against
/// the first `pumpAndSettle`.
Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installZeroOffsetPointerGuard();
  await _loadVersion();

  // Pre-initialize SharedPreferences before mounting the provider tree.
  // This ensures synchronous access throughout the entire app lifecycle.
  final sharedPrefs = await SharedPreferences.getInstance();

  // Create the container with the SharedPreferences override so that
  // all providers in the graph can synchronously access it.
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
    ],
  );

  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const Phase10App()),
  );
}

Future<void> main() => bootstrapApp();
