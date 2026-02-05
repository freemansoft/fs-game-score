class Scores {
  Scores(int numRounds) : roundScores = List.filled(numRounds, null);

  /// Creates a Scores instance from a JSON list
  Scores.fromJson(List<dynamic> json)
    : roundScores = json.map((e) => e as int?).toList();

  final List<int?> roundScores;

  int get total => roundScores.whereType<int>().fold(0, (a, b) => a + b);

  void setScore(int round, int? score) {
    if (round >= 0 && round < roundScores.length) {
      roundScores[round] = score;
    }
  }

  /// returns null if no score set so we can tell rounds played vs score of 0
  int? getScore(int round) {
    if (round >= 0 && round < roundScores.length) {
      return roundScores[round];
    }
    return null;
  }

  /// Converts scores to a JSON-serializable list
  List<int?> toJson() => roundScores;
}
