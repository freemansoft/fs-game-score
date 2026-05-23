/// User-visible host target for live sync connection banners and snapshots.
///
/// Prefers a short [gameId] prefix; falls back to [hostIp] when the game id
/// is unavailable. Never returns device hostnames such as `localhost`.
String liveSyncConnectionLabel({
  required String gameId,
  String? hostIp,
}) {
  final shortGameId = _shortGameId(gameId);
  if (shortGameId.isNotEmpty) {
    return shortGameId;
  }
  if (hostIp != null && isLanIPv4(hostIp)) {
    return hostIp;
  }
  return '';
}

/// Resolves the banner target from spectator state.
String? resolveLiveConnectionBannerTarget({
  String? gameId,
  String? hostDeviceName,
  String? connectedHostIp,
}) {
  if (gameId != null && gameId.isNotEmpty) {
    final shortGameId = _shortGameId(gameId);
    if (shortGameId.isNotEmpty) {
      return shortGameId;
    }
  }
  if (connectedHostIp != null && isLanIPv4(connectedHostIp)) {
    return connectedHostIp;
  }
  if (hostDeviceName != null &&
      isLanIPv4(hostDeviceName) &&
      !isLocalHostLabel(hostDeviceName)) {
    return hostDeviceName;
  }
  return null;
}

String _shortGameId(String gameId) {
  final trimmed = gameId.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  return trimmed.length > 8 ? trimmed.substring(0, 8) : trimmed;
}

/// True when [value] is an IPv4 address suitable for LAN display.
bool isLanIPv4(String value) {
  final parts = value.trim().split('.');
  if (parts.length != 4) {
    return false;
  }
  for (final part in parts) {
    final n = int.tryParse(part);
    if (n == null || n < 0 || n > 255) {
      return false;
    }
  }
  return true;
}

/// True for localhost-style names that should not be shown to spectators.
bool isLocalHostLabel(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized == 'localhost' ||
      normalized == '127.0.0.1' ||
      normalized == '::1';
}
