import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/sync/game_sync_protocol.dart';

void main() {
  group('isValidGameSyncPin', () {
    test('accepts 6 digits', () {
      expect(isValidGameSyncPin('123456'), isTrue);
    });

    test('rejects short pin', () {
      expect(isValidGameSyncPin('12345'), isFalse);
    });
  });

  group('gameSyncAppVersionsMatch', () {
    test('accepts identical versions', () {
      expect(
        gameSyncAppVersionsMatch('1.12.0+236', '1.12.0+236'),
        isTrue,
      );
    });

    test('accepts same major with different minor or patch', () {
      expect(
        gameSyncAppVersionsMatch('1.12.0+236', '1.13.0+200'),
        isTrue,
      );
      expect(
        gameSyncAppVersionsMatch('1.12.0', '1.13.0'),
        isTrue,
      );
    });

    test('rejects different major versions', () {
      expect(
        gameSyncAppVersionsMatch('1.12.0+236', '2.12.0+200'),
        isFalse,
      );
      expect(
        gameSyncAppVersionsMatch('1.12.0', '2.12.0'),
        isFalse,
      );
    });

    test('rejects null or empty', () {
      expect(gameSyncAppVersionsMatch(null, '1.0.0'), isFalse);
      expect(gameSyncAppVersionsMatch('1.0.0', ''), isFalse);
    });
  });

  group('encode/decode messages', () {
    test('round-trips hello', () {
      const message = GameSyncMessage(
        type: GameSyncMessageType.hello,
        pin: '123456',
        spectatorName: 'Alice',
      );
      final decoded = decodeGameSyncMessage(encodeGameSyncMessage(message));
      expect(decoded.type, GameSyncMessageType.hello);
      expect(decoded.pin, '123456');
      expect(decoded.spectatorName, 'Alice');
    });

    test('round-trips snapshot', () {
      const snapshot = GameSyncSnapshot(
        protocolVersion: 1,
        gameId: 'uuid',
        revision: 2,
        configuration: {'maxRounds': 14},
        players: [
          {
            'name': 'P1',
            'scores': <int?>[0, 0, 0],
            'phases': <int?>[0, 0, 0],
            'frenchDrivingAttributes': <Map<String, dynamic>>[],
            'roundStates': <bool>[true, true, true],
            'totalScore': 0,
          },
        ],
        hostDeviceName: 'host',
      );
      const message = GameSyncMessage(
        type: GameSyncMessageType.snapshot,
        snapshot: snapshot,
      );
      final decoded = decodeGameSyncMessage(encodeGameSyncMessage(message));
      expect(decoded.snapshot?.revision, 2);
      expect(decoded.snapshot?.gameId, 'uuid');
    });
  });
}
