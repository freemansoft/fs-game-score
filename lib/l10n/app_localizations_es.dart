// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Tarjeta de Puntaje FreemanS';

  @override
  String get continueButton => 'Continuar';

  @override
  String get numberOfPlayers => 'Número de jugadores:';

  @override
  String get numberOfPlayersTooltip =>
      'Seleccione el número de jugadores para el juego';

  @override
  String get maximumRounds => 'Rondas máximas:';

  @override
  String get maximumRoundsTooltip =>
      'Establezca el número máximo de rondas para el juego';

  @override
  String get sheetStyle => 'Estilo de hoja:';

  @override
  String get sheetStyleTooltip =>
      'Elija el estilo de la hoja de puntuación: básico o con fases';

  @override
  String get gameMode => 'Modo de juego:';

  @override
  String get gameModeStandard => 'Estándar';

  @override
  String get gameModePhase10 => 'Fase 10';

  @override
  String get gameModeFrenchDriving => 'French Driving';

  @override
  String get basicSheet => 'Hoja Básica';

  @override
  String get includePhases => 'Incluir Fases';

  @override
  String get scoreFilter => 'Filtro de puntuación:';

  @override
  String get scoreFilterTooltip =>
      'Limitar los valores de puntuación (p. ej., cualquier puntuación o las que terminan en 5 o 0)';

  @override
  String get anyScore => 'Cualquier puntuación';

  @override
  String get mustEndIn0Or5 => 'Debe terminar en 0 o 5';

  @override
  String get endScore => 'Puntuación final';

  @override
  String get endScoreTooltip =>
      'Permitir que el juego termine cuando un jugador alcanza esta puntuación';

  @override
  String get gameEndingScore => 'Puntuación para terminar el juego';

  @override
  String get copyright => 'Derechos de autor (C) 2025 Joe Freeman';

  @override
  String version(String version) {
    return 'Versión: $version';
  }

  @override
  String get scores => 'Puntuaciones';

  @override
  String get playerTotal => 'Jugador\nTotal';

  @override
  String get lockColumn => 'Bloquear columna';

  @override
  String get unlockColumn => 'Desbloquear columna';

  @override
  String get name => 'Nombre:';

  @override
  String get phasesByRound => 'Fases por ronda:';

  @override
  String get noPhasesCompleted => 'No hay fases completadas';

  @override
  String roundPhase(int roundNumber, int phaseNumber) {
    return 'Ronda $roundNumber: Fase $phaseNumber';
  }

  @override
  String get score => 'Puntuación:';

  @override
  String get scoreHint => 'Puntuación';

  @override
  String get phase => 'Fase:';

  @override
  String get selectCompletedPhases => 'Seleccione la(s) fase(s) completada(s)';

  @override
  String get noPhase => 'Sin fase';

  @override
  String phaseNumber(int phaseNumber) {
    return 'Fase $phaseNumber';
  }

  @override
  String playerRoundModalTitle(int playerNumber, int roundNumber) {
    return 'Jugador $playerNumber - Ronda $roundNumber';
  }

  @override
  String get invalidScoreForRound => 'Puntuación inválida para esta ronda';

  @override
  String get startNewGame => '¿Iniciar nuevo juego?';

  @override
  String get startNewGameMessage =>
      '¿Está seguro de que desea iniciar un nuevo juego? La tarjeta de puntuación se borrará.';

  @override
  String get clearPlayerNames => 'Borrar los nombres de los jugadores';

  @override
  String get cancel => 'Cancelar';

  @override
  String get newGame => 'Nuevo juego';

  @override
  String get gameReset => '¡Juego reiniciado!';

  @override
  String get newGameSameTypeTooltip =>
      'Nuevo juego - Usando mismo tipo de tarjeta de puntuación';

  @override
  String get changeScorecardType => 'Cambiar tipo de tarjeta de puntuación';

  @override
  String get changeScorecardTypeMessage =>
      '¿Está seguro de que desea cambiar el tipo de tarjeta de puntuación? La tarjeta se borrará.';

  @override
  String get changeScorecard => 'Cambiar tarjeta de puntuación';

  @override
  String get newGameChangeScorecardType =>
      'Nuevo juego - Cambiar tipo de tarjeta de puntuación';

  @override
  String get shareScores => 'Compartir puntuaciones';

  @override
  String get noScoresToShare => 'No hay puntuaciones para compartir';

  @override
  String get miles => 'Millas';

  @override
  String get safeties => 'Seguridades';

  @override
  String get coupFourre => 'Coup Fourré';

  @override
  String get delayedAction => 'Acción Retrasada';

  @override
  String get safeTrip => 'Viaje Seguro';

  @override
  String get shutOut => 'Shut Out';

  @override
  String get milesTooltip =>
      'Cada equipo suma tantos puntos como el número total de millas que ha recorrido.';

  @override
  String get safetiesTooltip =>
      '100 puntos por cada tarjeta de Seguridad jugada.';

  @override
  String get coupFourreTooltip =>
      '300 puntos además de los 100 puntos por la tarjeta de Seguridad.';

  @override
  String get delayedActionTooltip =>
      'Si el viaje se completa después de que se hayan jugado todas las tarjetas de la pila de robo.';

  @override
  String get safeTripTooltip =>
      'Si el viaje se completa sin jugar tarjetas de 200 Millas.';

  @override
  String get shutOutTooltip =>
      'Completar el viaje de 1000 millas antes de que los oponentes hayan jugado tarjetas de Distancia.';
}
