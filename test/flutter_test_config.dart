import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Not convinced this is executed if you execute a single test directly
/// in the ide
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  SharedPreferences.setMockInitialValues({});

  // Repositories are now created via Riverpod providers that receive
  // SharedPreferences through DI, so there is no singleton state to clear.
  // The mock initial values above ensure a clean slate for each test.

  await testMain();
}
