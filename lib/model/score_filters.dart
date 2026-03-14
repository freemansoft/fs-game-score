/// Centralized regex filter constants for score validation.
///
/// These patterns are used by score fields and configuration to validate
/// user input against game-specific scoring rules.
class ScoreFilters {
  ScoreFilters._();

  /// No filtering — any score is accepted.
  static const String none = '';

  /// Scores must end in 0 or 5 (used by Phase 10 and French Driving miles).
  static const String endsWith0or5 = r'^[0-9]*[05]$';

  /// Allows positive or negative digits, including just a minus sign.
  static const String signedDigits = r'^-?\d*';
}
