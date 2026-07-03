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
  String get continueButton => 'Iniciar juego nuevo';

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
  String get gameModeFrenchDriving => 'Mille Bornes';

  @override
  String get gameModeSkyjo => 'Skyjo';

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
  String get miles => 'Kilómetros';

  @override
  String get safeties => 'Bottes';

  @override
  String get coupFourre => 'Coup Fourré';

  @override
  String get delayedAction => 'Acción retardada';

  @override
  String get safeTrip => 'Viaje seguro';

  @override
  String get shutOut => 'Capote';

  @override
  String get milesTooltip =>
      'Cada equipo suma tantos puntos como el número total de kilómetros que ha recorrido.';

  @override
  String get safetiesTooltip =>
      '100 puntos por cada botte (carta de seguridad) jugada.';

  @override
  String get coupFourreTooltip =>
      '300 puntos además de los 100 puntos por la botte.';

  @override
  String get delayedActionTooltip =>
      'Si el viaje se completa después de que se hayan jugado todas las cartas del mazo de robo.';

  @override
  String get safeTripTooltip =>
      'Si el viaje se completa sin jugar ninguna carta de 200 kilómetros.';

  @override
  String get shutOutTooltip =>
      'Completar el viaje de 1000 kilómetros antes de que los oponentes hayan jugado ninguna carta de distancia.';

  @override
  String get trademarkDisclaimer =>
      'Todos los nombres de productos y empresas son marcas comerciales™ o marcas registradas® de sus respectivos propietarios. Su uso no implica ninguna afiliación o respaldo por su parte. FreemanS Score Card es una aplicación independiente y no está patrocinada ni aprobada por ningún propietario de marca comercial externo.';

  @override
  String get shareLive => 'Compartir vista en vivo';

  @override
  String get joinLiveGame => 'Unirse a juego en vivo';

  @override
  String get joinLiveGameTooltip =>
      'Ambos dispositivos deben estar en la misma red Wi-Fi.';

  @override
  String get liveSharingTitle => 'Compartir en vivo';

  @override
  String get liveSharingInstructions =>
      'Otros jugadores en la misma Wi-Fi pueden escanear este código o elegir este juego en [Unirse a juego en vivo].';

  @override
  String connectionPin(String pin) {
    return 'PIN: $pin';
  }

  @override
  String get copyConnectionUrl => 'Copiar enlace de conexión';

  @override
  String get connectionUrlCopied => 'Enlace de conexión copiado';

  @override
  String get stopLiveSharing => 'Dejar de compartir';

  @override
  String get liveSharingUnavailable =>
      'El uso compartido en vivo está disponible en Android e iOS cuando todos están en la misma Wi-Fi.';

  @override
  String get joinLiveGameTitle => 'Unirse a juego en vivo';

  @override
  String get discoveredHosts => 'Juegos en esta red';

  @override
  String get noHostsFound =>
      'No se encontraron juegos. Pida al anfitrión que comparta su código QR.';

  @override
  String get scanConnectionQr => 'Escanear QR de conexión';

  @override
  String get manualConnection => 'Conectar manualmente';

  @override
  String get connectionUrlHint => 'ws://192.168.1.5:8765?game=...&pin=...';

  @override
  String get connect => 'Conectar';

  @override
  String get liveSpectatorTitle => 'Puntuaciones en vivo';

  @override
  String get liveConnectionConnecting => 'Conectando…';

  @override
  String liveConnectionConnected(String host) {
    return 'Conectado a $host';
  }

  @override
  String get liveConnectionConnectedOnly => 'Conectado';

  @override
  String get liveConnectionReconnecting => 'Reconectando…';

  @override
  String get liveConnectionWrongPin =>
      'PIN incorrecto. Verifique el código del anfitrión.';

  @override
  String get liveConnectionVersionMismatch =>
      'La versión principal de la app no coincide con la del anfitrión. Actualice ambos dispositivos a la misma versión principal de FS Score Card.';

  @override
  String get liveSyncAppVersionUnknown =>
      'No se puede iniciar el uso compartido en vivo hasta conocer la versión de la app. Reinicie la app e intente de nuevo.';

  @override
  String get liveConnectionCannotReachHost =>
      'No se puede contactar al anfitrión. Use la misma Wi-Fi e intente de nuevo.';

  @override
  String get liveConnectionHostClosed => 'El anfitrión dejó de compartir.';

  @override
  String get liveConnectionFailed => 'Conexión fallida.';

  @override
  String get leaveLiveView => 'Salir';

  @override
  String get leaveLiveViewLabel => 'Salir de la vista en vivo';

  @override
  String get requestNewGameSameType => 'Solicitar nuevo juego, mismo tipo';

  @override
  String get scoreTableLabel => 'Tabla de puntuación';

  @override
  String roundLabel(int roundNumber) {
    return 'Ronda $roundNumber';
  }

  @override
  String roundLockButtonLabel(int roundNumber) {
    return 'Botón de bloqueo de la ronda $roundNumber';
  }

  @override
  String joinHostLabel(String hostName) {
    return 'Unirse a $hostName';
  }

  @override
  String get shareGameScores => 'Compartir puntuaciones del juego';

  @override
  String get requestChangeScorecardType =>
      'Solicitar cambio de tipo de tarjeta de puntuación';

  @override
  String get roundScoreLabel => 'Puntuación de la ronda';

  @override
  String get milesDrivenLabel => 'Kilómetros recorridos';

  @override
  String get numberOfSafetiesLabel => 'Número de bottes';

  @override
  String get numberOfCoupFourreLabel => 'Número de coups fourrés';

  @override
  String get delayedActionBonusLabel => 'Bonificación de acción retardada';

  @override
  String get safeTripBonusLabel => 'Bonificación de viaje seguro';

  @override
  String get shutOutBonusLabel => 'Bonificación de capote';

  @override
  String get playerTotalLabel => 'Jugador y total';

  @override
  String playerNameAndTotalLabel(int playerNumber) {
    return 'Nombre y puntuación total del jugador $playerNumber';
  }

  @override
  String get playerNameLabel => 'Nombre del jugador';

  @override
  String get numberOfPlayersLabel => 'Número de jugadores';

  @override
  String get maximumRoundsLabel => 'Rondas máximas';

  @override
  String get gameModeLabel => 'Modo de juego';

  @override
  String get scoreFilterLabel => 'Filtro de puntuación';

  @override
  String get enableEndGameScoreLabel => 'Activar puntuación de fin de juego';

  @override
  String get endGameScoreLabel => 'Puntuación de fin de juego';

  @override
  String playerRoundScoreLabel(int playerNumber, int roundNumber) {
    return 'Puntuación del jugador $playerNumber en la ronda $roundNumber';
  }

  @override
  String playerGameModalLabel(int playerNumber) {
    return 'Ventana del juego del jugador $playerNumber';
  }

  @override
  String playerTotalScoreLabel(int playerNumber) {
    return 'Puntuación total del jugador $playerNumber';
  }

  @override
  String playerRoundPhaseLabel(int playerNumber, int roundNumber) {
    return 'Fase del jugador $playerNumber en la ronda $roundNumber';
  }

  @override
  String playerNameValueLabel(int playerNumber) {
    return 'Nombre del jugador $playerNumber';
  }

  @override
  String get liveConnectionQrLabel => 'Código QR de conexión en vivo';
}
