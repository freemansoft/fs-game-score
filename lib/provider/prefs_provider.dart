import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the [SharedPreferences] instance.
///
/// This provider is overridden at startup in `main()` with a pre-initialized
/// [SharedPreferences] instance, ensuring synchronous access throughout
/// the provider graph.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden before use. '
    'Call ProviderContainer(overrides: '
    '[sharedPreferencesProvider.overrideWithValue(prefs)]) in main().',
  );
});
