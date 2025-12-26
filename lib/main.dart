import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:fs_score_card/app.dart';

// https://github.com/flutter/flutter/issues/175606#issuecomment-3453392532
// Error introduced with iPad IOS 26.1 due to iPad window handling

// Top level global
bool _zeroOffsetPointerGuardInstalled = false;

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _installZeroOffsetPointerGuard();
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  runApp(const Phase10AppBuilder());
}
