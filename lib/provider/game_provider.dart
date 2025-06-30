import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_game_score/model/game.dart';

class GameNotifier extends StateNotifier<Game> {
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
    state = Game(
      maxRounds: state.maxRounds,
      numPhases: state.numPhases,
      numPlayers: numPlayers,
      enablePhases: state.enablePhases,
    );
  }

  void setEnablePhases(bool enablePhases) {
    state = Game(
      maxRounds: state.maxRounds,
      numPhases: state.numPhases,
      numPlayers: state.numPlayers,
      enablePhases: enablePhases,
    );
  }

  // Add more setters as needed
}

final gameProvider = StateNotifierProvider<GameNotifier, Game>(
  (ref) => GameNotifier(),
);
