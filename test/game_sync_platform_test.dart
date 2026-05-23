import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/sync/game_sync_platform.dart';

void main() {
  test('mobile VM tests report join capability when not web', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(canHostLiveSync, isTrue);
    expect(canJoinLiveSync, isTrue);
    debugDefaultTargetPlatformOverride = null;
  });
}
