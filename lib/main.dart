import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:fs_score_card/app.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  } catch (_) {
    appVersion = null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installZeroOffsetPointerGuard();
  await _loadVersion();

  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  runApp(const Phase10AppBuilder());
}
