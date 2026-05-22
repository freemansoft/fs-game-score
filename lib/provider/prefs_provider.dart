import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Root dependency-injection provider for [SharedPreferences].
///
/// Must be overridden with a real instance in `bootstrapApp` before any
/// repository or notifier provider is read. Without an override, accessing
/// this provider throws [UnimplementedError].
///
/// Repository providers (`gameRepositoryProvider`, `playersRepositoryProvider`)
/// watch this provider to construct their repositories. See
/// `docs/State-Management.md` for the full provider layer diagram.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden before use. '
    'Call bootstrapApp() which uses ProviderContainer(overrides: '
    '[sharedPreferencesProvider.overrideWithValue(prefs)]).',
  );
});
