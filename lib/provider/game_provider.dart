import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_game_score/model/game.dart';

class GameNotifier extends StateNotifier<Game> {
  Game stateValue() => state;
  void setVersion(String? version) {
    state = state.copyWith(version: version);
  }

  void setMaxRounds(int maxRounds) {
    state = state.copyWith(maxRounds: maxRounds);
  }

  GameNotifier() : super(const Game());

  void newGame({
    int? maxRounds,
    int? numPhases,
    int? numPlayers,
    bool? enablePhases,
  }) {
    state = Game(
      maxRounds: maxRounds ?? state.maxRounds,
      numPhases: numPhases ?? state.numPhases,
      numPlayers: numPlayers ?? state.numPlayers,
      enablePhases: enablePhases ?? state.enablePhases,
    );
  }

  void setNumPlayers(int numPlayers) {
    state = state.copyWith(numPlayers: numPlayers);
  }

  void setEnablePhases(bool enablePhases) {
    state = state.copyWith(enablePhases: enablePhases);
  }

  // Add more setters as needed
}

final gameProvider = StateNotifierProvider<GameNotifier, Game>(
  (ref) => GameNotifier(),
);
