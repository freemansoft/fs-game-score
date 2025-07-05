class Phases {
  final List<int?> completedPhases;
  final List<bool> enabledRounds;

  Phases(int numPhases)
    : completedPhases = List.filled(numPhases, null),
      enabledRounds = List.filled(numPhases, true); // default enabled

  void setPhase(int round, int? phase) {
    if (round >= 0 && round < completedPhases.length && enabledRounds[round]) {
      if (phase != null && phase < 0) {
        completedPhases[round] = null;
      } else {
        completedPhases[round] = phase;
      }
    }
  }

  int? getPhase(int round) {
    if (round >= 0 && round < completedPhases.length) {
      return completedPhases[round];
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

  List<int> completedPhasesList() {
    // Return a list of completed phase numbers (non-null, non-zero)
    return completedPhases
        .where((p) => p != null && p > 0)
        .cast<int>()
        .toList();
  }
}
