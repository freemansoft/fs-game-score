class FrenchDrivingRoundAttributes {
  FrenchDrivingRoundAttributes({
    this.miles = 0,
    List<bool>? safetyCards,
    List<bool>? coupFourre,
    this.delayedAction = false,
    this.safeTrip = false,
    this.shutOut = false,
  }) : safetyCards = safetyCards ?? List.filled(4, false),
       coupFourre = coupFourre ?? List.filled(4, false);

  FrenchDrivingRoundAttributes.fromJson(Map<String, dynamic> json)
    : miles = (json['miles'] as num?)?.toInt() ?? 0,
      safetyCards =
          (json['safetyCards'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          List.filled(4, false),
      coupFourre =
          (json['coupFourre'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          List.filled(4, false),
      delayedAction = (json['delayedAction'] as bool?) ?? false,
      safeTrip = (json['safeTrip'] as bool?) ?? false,
      shutOut = (json['shutOut'] as bool?) ?? false;

  final int miles;
  final List<bool> safetyCards;
  final List<bool> coupFourre;
  final bool delayedAction;
  final bool safeTrip;
  final bool shutOut;

  int calculateScore() {
    int score = miles;

    // Safety cards: 100 points each
    for (final safety in safetyCards) {
      if (safety) score += 100;
    }

    // Safety card bonus: 300 points if all 4 are played
    if (safetyCards.every((s) => s)) {
      score += 300;
    }

    // Coup Fourré: 300 points each (in addition to the 100 for safety)
    for (final coup in coupFourre) {
      if (coup) score += 300;
    }

    // Trip completion bonuses
    // Note: The miles check might need adjustment if we want to confirm trip completion explicitly,
    // but typically delayedAction/safeTrip/shutOut imply trip completion or at least are bonuses related to it.
    // Based on rules, Delayed Action, Safe Trip, Shut Out bonuses are for completing trip.
    // However, the rule says "Bonus for completing trip of 1000 miles" is 400.
    // The current attributes don't strictly enforce "completed trip" boolean, but usually that's implied by high miles or user checkbox.
    // Let's assume for now 1000 miles means completed, or add an explicit checkbox?
    // Rules say: "The score is totaled at the end of each hand, whether or not a trip of 1000 miles was completed".
    // AND "Bonus for completing trip of 1000 miles: 400".
    // So if miles == 1000, we add 400? Or should we have an explicit flag?
    // Given the UI requirement "check box for delayed action", "check box for safe trip", "check box for shut out",
    // and usually these bonuses apply only if you won (completed trip).
    // Let's assume for now if miles == 1000 we add 400, OR we might need an explicit "Trip Completed" flag if game allows < 1000 win?
    // Standard rules: Race to 1000.
    // If miles == 1000, add 400.
    if (miles >= 1000) {
      score += 400;
    }

    if (delayedAction) score += 300;
    if (safeTrip) score += 300;
    if (shutOut) score += 500;

    return score;
  }

  Map<String, dynamic> toJson() => {
    'miles': miles,
    'safetyCards': safetyCards,
    'coupFourre': coupFourre,
    'delayedAction': delayedAction,
    'safeTrip': safeTrip,
    'shutOut': shutOut,
  };

  FrenchDrivingRoundAttributes copyWith({
    int? miles,
    List<bool>? safetyCards,
    List<bool>? coupFourre,
    bool? delayedAction,
    bool? safeTrip,
    bool? shutOut,
  }) {
    return FrenchDrivingRoundAttributes(
      miles: miles ?? this.miles,
      safetyCards: safetyCards ?? List.from(this.safetyCards),
      coupFourre: coupFourre ?? List.from(this.coupFourre),
      delayedAction: delayedAction ?? this.delayedAction,
      safeTrip: safeTrip ?? this.safeTrip,
      shutOut: shutOut ?? this.shutOut,
    );
  }
}
