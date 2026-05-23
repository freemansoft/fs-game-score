import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/sync/game_sync_qr.dart';

void main() {
  test('encode and decode connection URL', () {
    const host = '192.168.1.5';
    const gameId = '550e8400-e29b-41d4-a716-446655440000';
    const pin = '123456';
    final url = encodeGameSyncConnectionUrl(
      host: host,
      port: 8765,
      gameId: gameId,
      pin: pin,
    );
    expect(url, contains('ws://192.168.1.5:8765'));
    expect(url, contains('game=$gameId'));
    expect(url, contains('pin=$pin'));

    final info = decodeGameSyncConnectionUrl(url);
    expect(info, isNotNull);
    expect(info!.host, host);
    expect(info.port, 8765);
    expect(info.gameId, gameId);
    expect(info.pin, pin);
  });

  test('decode rejects invalid URL', () {
    expect(decodeGameSyncConnectionUrl('http://example.com'), isNull);
    expect(decodeGameSyncConnectionUrl('ws://host'), isNull);
  });
}
