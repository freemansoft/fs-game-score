class RoundStates {
  RoundStates(int numRounds) : enabledRounds = List.filled(numRounds, true);
  final List<bool> enabledRounds; // default enabled

  void setEnabled({required int round, required bool enabled}) {
    if (round >= 0 && round < enabledRounds.length) {
      enabledRounds[round] = enabled;
    }
  }

  bool isEnabled(int round) {
    if (round >= 0 && round < enabledRounds.length) {
      return enabledRounds[round];
    }
    return true;
  }

  void enableAll() {
    for (var i = 0; i < enabledRounds.length; i++) {
      enabledRounds[i] = true;
    }
  }

  void disableAll() {
    for (var i = 0; i < enabledRounds.length; i++) {
      enabledRounds[i] = false;
    }
  }
}
