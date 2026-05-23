import 'package:flutter/foundation.dart';

/// Whether this target can host a live LAN sync session (v1: Android/iOS only).
bool get canHostLiveSync {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

/// Whether this target can join a live LAN sync session as spectator.
bool get canJoinLiveSync {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

/// Whether mDNS browse/register is available on this target.
bool get canDiscoverViaMdns => canJoinLiveSync;
