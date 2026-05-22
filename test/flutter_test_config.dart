import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Runs before each test file in `test/`.
///
/// Sets empty mock [SharedPreferences] so repository code sees no persisted
/// game when tests construct repos directly or via providers.
///
/// Widget tests that mount `ProviderScope` with repository-dependent widgets
/// should also override `sharedPreferencesProvider` with the same mock instance:
///
/// ```dart
/// SharedPreferences.setMockInitialValues({});
/// final prefs = await SharedPreferences.getInstance();
/// await tester.pumpWidget(
///   ProviderScope(
///     overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
///     child: const MyApp(),
///   ),
/// );
/// ```
///
/// See `docs/State-Management.md` for Riverpod testing guidelines.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  SharedPreferences.setMockInitialValues({});

  await testMain();
}
