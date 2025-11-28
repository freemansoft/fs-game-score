import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = NotifierProvider<ThemeNotifier, bool>(
  () => ThemeNotifier(),
);

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }

  void setTheme(bool isDark) {
    state = isDark;
  }
}
