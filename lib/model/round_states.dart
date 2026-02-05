class RoundStates {
  RoundStates(int numRounds) : enabledRounds = List.filled(numRounds, true);

  /// Creates a RoundStates instance from a JSON list
  RoundStates.fromJson(List<dynamic> json)
    : enabledRounds = json.map((e) => e as bool).toList();

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

  /// Converts round states to a JSON-serializable list
  List<bool> toJson() => enabledRounds;
}
