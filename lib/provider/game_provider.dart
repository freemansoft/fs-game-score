import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_score_card/model/game.dart';

class GameNotifier extends Notifier<Game> {
  @override
  Game build() => Game();

  Game stateValue() => state;

  void setVersion(String? version) {
    state = state.copyWith(version: version);
  }

  void setMaxRounds(int maxRounds) {
    state = state.copyWith(maxRounds: maxRounds);
  }

  void newGame({
    int? maxRounds,
    int? numPhases,
    int? numPlayers,
    bool? enablePhases,
    String? scoreFilter,
    String? version,
  }) {
    state = Game(
      maxRounds: maxRounds ?? state.maxRounds,
      numPhases: numPhases ?? state.numPhases,
      numPlayers: numPlayers ?? state.numPlayers,
      enablePhases: enablePhases ?? state.enablePhases,
      scoreFilter: scoreFilter ?? state.scoreFilter,
      version: version ?? state.version,
      // gameId will be automatically generated as a new UUID
    );
  }

  void setNumPlayers(int numPlayers) {
    state = state.copyWith(numPlayers: numPlayers);
  }

  void setEnablePhases(bool enablePhases) {
    state = state.copyWith(enablePhases: enablePhases);
  }

  void setScoreFilter(String scoreFilter) {
    state = state.copyWith(scoreFilter: scoreFilter);
  }

  // Add more setters as needed
}

final gameProvider = NotifierProvider<GameNotifier, Game>(() => GameNotifier());
