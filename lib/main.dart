import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:fs_score_card/app.dart';

void main() {
  if (kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    SemanticsBinding.instance.ensureSemantics();
  }
  runApp(const Phase10AppBuilder());
}
