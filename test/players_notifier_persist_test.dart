import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_score_card/data/players_repository.dart';
import 'package:fs_score_card/model/players.dart';
import 'package:fs_score_card/provider/game_provider.dart';
import 'package:fs_score_card/provider/players_provider.dart';
import 'package:fs_score_card/provider/prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingPlayersRepository extends PlayersRepository {
  _RecordingPlayersRepository(super._prefs);

  int saveCount = 0;
  Completer<void>? saveGate;

  @override
  Future<void> savePlayers(Players players) async {
    saveCount++;
    if (saveGate != null) {
      await saveGate!.future;
    }
    await super.savePlayers(players);
  }
}

void main() {
  group('PlayersNotifier coalesced persist', () {
    late SharedPreferences prefs;
    late _RecordingPlayersRepository recordingRepository;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      recordingRepository = _RecordingPlayersRepository(prefs);
      container =
          ProviderContainer(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(prefs),
                playersRepositoryProvider.overrideWithValue(
                  recordingRepository,
                ),
              ],
            )
            ..read(gameNotifierProvider)
            ..read(playersNotifierProvider);
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> drainPersist() async {
      await pumpEventQueue();
      await pumpEventQueue();
    }

    test('persists latest state after burst of score edits', () async {
      container.read(playersNotifierProvider.notifier)
        ..updateScore(0, 0, 10)
        ..updateScore(0, 1, 20)
        ..updateScore(1, 0, 30);
      await drainPersist();

      expect(recordingRepository.saveCount, greaterThan(0));
      final loaded = recordingRepository.loadPlayers();
      expect(loaded, isNotNull);
      expect(loaded!.players[0].scores.roundScores[0], 10);
      expect(loaded.players[0].scores.roundScores[1], 20);
      expect(loaded.players[1].scores.roundScores[0], 30);
    });

    test(
      'prepareForSplashEntry clears prefs and blocks follow-up saves',
      () async {
        final notifier = container.read(playersNotifierProvider.notifier)
          ..updateScore(0, 0, 42);
        await drainPersist();
        expect(recordingRepository.loadPlayers(), isNotNull);

        await notifier.prepareForSplashEntry();
        await drainPersist();

        expect(recordingRepository.loadPlayers(), isNull);
      },
    );

    test(
      'prepareForSplashEntry during in-flight save still clears prefs',
      () async {
        final notifier = container.read(playersNotifierProvider.notifier);
        recordingRepository.saveGate = Completer<void>();

        notifier.updateScore(0, 0, 99);
        await pumpEventQueue();

        final splashFuture = notifier.prepareForSplashEntry();
        recordingRepository.saveGate!.complete();
        await splashFuture;
        await drainPersist();

        expect(recordingRepository.loadPlayers(), isNull);
      },
    );
  });
}
