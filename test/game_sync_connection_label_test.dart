import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/sync/game_sync_connection_label.dart';

void main() {
  group('liveSyncConnectionLabel', () {
    test('prefers short game id', () {
      expect(
        liveSyncConnectionLabel(
          gameId: 'abcdef12-3456-7890-abcd-ef1234567890',
          hostIp: '192.168.1.10',
        ),
        'abcdef12',
      );
    });

    test('uses host IP when game id is empty', () {
      expect(
        liveSyncConnectionLabel(gameId: '', hostIp: '192.168.1.10'),
        '192.168.1.10',
      );
    });
  });

  group('resolveLiveConnectionBannerTarget', () {
    test('ignores localhost host device name', () {
      expect(
        resolveLiveConnectionBannerTarget(
          gameId: 'game-uuid-1234',
          hostDeviceName: 'localhost',
          connectedHostIp: '192.168.1.5',
        ),
        'game-uui',
      );
    });

    test('uses connected host IP when game id missing', () {
      expect(
        resolveLiveConnectionBannerTarget(
          hostDeviceName: 'localhost',
          connectedHostIp: '10.0.0.42',
        ),
        '10.0.0.42',
      );
    });

    test('returns null when only localhost is available', () {
      expect(
        resolveLiveConnectionBannerTarget(hostDeviceName: 'localhost'),
        isNull,
      );
    });
  });

  group('isLocalHostLabel', () {
    test('detects localhost variants', () {
      expect(isLocalHostLabel('localhost'), isTrue);
      expect(isLocalHostLabel('127.0.0.1'), isTrue);
      expect(isLocalHostLabel('192.168.0.5'), isFalse);
    });
  });
}
