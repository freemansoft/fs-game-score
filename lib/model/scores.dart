class Scores {
  final List<int?> roundScores;
  final List<bool> enabledRounds;

  Scores(int numRounds)
    : roundScores = List.filled(numRounds, null),
      enabledRounds = List.filled(numRounds, true); // default enabled

  int get total => roundScores.whereType<int>().fold(0, (a, b) => a + b);

  void setScore(int round, int? score) {
    if (round >= 0 && round < roundScores.length && enabledRounds[round]) {
      roundScores[round] = score;
    }
  }

  int? getScore(int round) {
    if (round >= 0 && round < roundScores.length) {
      return roundScores[round];
    }
    return null;
  }

  // Enable/disable methods
  void setEnabled(int round, bool enabled) {
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
