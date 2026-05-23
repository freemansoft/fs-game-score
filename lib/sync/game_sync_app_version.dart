import 'package:fs_score_card/main.dart' show appVersion;
import 'package:fs_score_card/model/game.dart';

/// App build version required for live sync (package_info / splash Continue).
///
/// Prefers the global app version from bootstrap; falls back to persisted
/// game configuration version when the global is unavailable (e.g. tests).
String? resolveLiveSyncAppVersion(Game game) {
  final fromPackage = appVersion;
  if (fromPackage != null && fromPackage.isNotEmpty) {
    return fromPackage;
  }
  final fromConfig = game.configuration.version;
  if (fromConfig != null && fromConfig.isNotEmpty) {
    return fromConfig;
  }
  return null;
}
