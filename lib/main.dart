import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:fs_score_card/app.dart';

// https://github.com/flutter/flutter/issues/175606#issuecomment-3453392532
// Error introduced with IOS 26.1
class FilteringFlutterBinding extends WidgetsFlutterBinding {
  @override
  void handlePointerEvent(PointerEvent event) {
    if (event.position == Offset.zero) {
      return;
    }
    super.handlePointerEvent(event);
  }
}

void main() {
  FilteringFlutterBinding();
  if (kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    SemanticsBinding.instance.ensureSemantics();
  }
  runApp(const Phase10AppBuilder());
}
