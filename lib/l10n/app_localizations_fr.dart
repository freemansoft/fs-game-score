// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Carte de score FreemanS';

  @override
  String get continueButton => 'Commencer une nouvelle partie';

  @override
  String get numberOfPlayers => 'Nombre de joueurs :';

  @override
  String get numberOfPlayersTooltip =>
      'Sélectionnez le nombre de joueurs pour la partie';

  @override
  String get maximumRounds => 'Nombre maximal de manches :';

  @override
  String get maximumRoundsTooltip =>
      'Définissez le nombre maximal de manches pour la partie';

  @override
  String get sheetStyle => 'Style de feuille :';

  @override
  String get sheetStyleTooltip =>
      'Choisissez le style de la feuille de score : basique ou avec phases';

  @override
  String get gameMode => 'Mode de jeu :';

  @override
  String get gameModeStandard => 'Standard';

  @override
  String get gameModePhase10 => 'Phase 10';

  @override
  String get gameModeFrenchDriving => 'Mille Bornes';

  @override
  String get gameModeSkyjo => 'Skyjo';

  @override
  String get gameModeGolf => 'Golf';

  @override
  String get gameModeHearts => 'Cœurs';

  @override
  String get gameModeRummy => 'Rummy';

  @override
  String get gameModeUno => 'Uno';

  @override
  String get gameModeFarkle => 'Farkle';

  @override
  String get gameModeRummikub => 'Rummikub';

  @override
  String get gameModeOhHell => 'Oh Hell';

  @override
  String get gameModeWizard => 'Wizard';

  @override
  String get bidLabel => 'Annonce';

  @override
  String get tricksTakenLabel => 'Plis réalisés';

  @override
  String get bidTricksZeroBidNote =>
      'Annoncer 0 et réaliser 0 pli marque 0 point pour l\'instant — une limitation connue.';

  @override
  String playerLeaderLabel(int playerNumber) {
    return 'Le joueur $playerNumber est en tête';
  }

  @override
  String get basicSheet => 'Feuille basique';

  @override
  String get includePhases => 'Inclure les phases';

  @override
  String get scoreFilter => 'Filtre de score :';

  @override
  String get scoreFilterTooltip =>
      'Limitez les valeurs de score saisies (par ex. n\'importe quel score ou ceux se terminant par 5 ou 0)';

  @override
  String get anyScore => 'N\'importe quel score';

  @override
  String get mustEndIn0Or5 => 'Doit se terminer par 0 ou 5';

  @override
  String get endScore => 'Score final';

  @override
  String get endScoreTooltip =>
      'Permettre à la partie de se terminer lorsqu\'un joueur atteint ce score';

  @override
  String get gameEndingScore => 'Score de fin de partie';

  @override
  String get copyright => 'Copyright (C) 2025 Joe Freeman';

  @override
  String version(String version) {
    return 'Version : $version';
  }

  @override
  String get scores => 'Scores';

  @override
  String get playerTotal => 'Joueur\nTotal';

  @override
  String get lockColumn => 'Verrouiller la colonne';

  @override
  String get unlockColumn => 'Déverrouiller la colonne';

  @override
  String get name => 'Nom :';

  @override
  String get phasesByRound => 'Phases par manche :';

  @override
  String get noPhasesCompleted => 'Aucune phase terminée';

  @override
  String roundPhase(int roundNumber, int phaseNumber) {
    return 'Manche $roundNumber : Phase $phaseNumber';
  }

  @override
  String get score => 'Score :';

  @override
  String get scoreHint => 'Score';

  @override
  String get phase => 'Phase :';

  @override
  String get selectCompletedPhases => 'Sélectionnez la ou les phases terminées';

  @override
  String get noPhase => 'Aucune phase';

  @override
  String phaseNumber(int phaseNumber) {
    return 'Phase $phaseNumber';
  }

  @override
  String playerRoundModalTitle(int playerNumber, int roundNumber) {
    return 'Joueur $playerNumber - Manche $roundNumber';
  }

  @override
  String get invalidScoreForRound => 'Score invalide pour cette manche';

  @override
  String get startNewGame => 'Commencer une nouvelle partie ?';

  @override
  String get startNewGameMessage =>
      'Êtes-vous sûr de vouloir commencer une nouvelle partie ? La carte de score sera effacée.';

  @override
  String get clearPlayerNames => 'Effacer les noms des joueurs';

  @override
  String get cancel => 'Annuler';

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String get gameReset => 'Partie réinitialisée !';

  @override
  String get newGameSameTypeTooltip =>
      'Nouvelle partie - Même type de carte de score';

  @override
  String get changeScorecardType => 'Changer le type de carte de score';

  @override
  String get changeScorecardTypeMessage =>
      'Êtes-vous sûr de vouloir changer le type de carte de score ? La carte de score sera effacée.';

  @override
  String get changeScorecard => 'Changer la carte de score';

  @override
  String get newGameChangeScorecardType =>
      'Nouvelle partie - Changer le type de carte de score';

  @override
  String get shareScores => 'Partager les scores';

  @override
  String get noScoresToShare => 'Aucun score à partager';

  @override
  String get miles => 'Bornes';

  @override
  String get safeties => 'Bottes';

  @override
  String get coupFourre => 'Coup fourré';

  @override
  String get delayedAction => 'Couronnement';

  @override
  String get safeTrip => 'Voyage sans les 200';

  @override
  String get shutOut => 'Capot';

  @override
  String get milesTooltip =>
      'Chaque équipe marque autant de points que le nombre total de bornes qu\'elle a parcourues.';

  @override
  String get safetiesTooltip => '100 points pour chaque botte jouée.';

  @override
  String get coupFourreTooltip =>
      '300 points en plus des 100 points de la botte.';

  @override
  String get delayedActionTooltip =>
      'Si le voyage est terminé après que toutes les cartes de la pioche ont été jouées.';

  @override
  String get safeTripTooltip =>
      'Si le voyage est terminé sans jouer de carte 200 bornes.';

  @override
  String get shutOutTooltip =>
      'Terminer un voyage de 1000 bornes avant que les adversaires n\'aient joué de carte de distance.';

  @override
  String get trademarkDisclaimer =>
      'Tous les noms de produits et de sociétés sont des marques commerciales™ ou des marques déposées® de leurs détenteurs respectifs. Leur utilisation n\'implique aucune affiliation ni approbation de leur part. FreemanS Score Card est une application indépendante et n\'est ni parrainée ni approuvée par un tiers détenteur de marque.';

  @override
  String get shareLive => 'Partager la vue en direct';

  @override
  String get joinLiveGame => 'Rejoindre une partie en direct';

  @override
  String get joinLiveGameTooltip =>
      'Les deux appareils doivent être sur le même réseau Wi-Fi.';

  @override
  String get liveSharingTitle => 'Partage en direct';

  @override
  String get liveSharingInstructions =>
      'Les joueurs sur le même Wi-Fi peuvent scanner ce code ou choisir cette partie depuis [Rejoindre une partie en direct].';

  @override
  String connectionPin(String pin) {
    return 'NIP : $pin';
  }

  @override
  String get copyConnectionUrl => 'Copier le lien de connexion';

  @override
  String get connectionUrlCopied => 'Lien de connexion copié';

  @override
  String get stopLiveSharing => 'Arrêter le partage';

  @override
  String get liveSharingUnavailable =>
      'Le partage en direct est disponible sur Android et iOS lorsque tout le monde est sur le même Wi-Fi.';

  @override
  String get joinLiveGameTitle => 'Rejoindre une partie en direct';

  @override
  String get discoveredHosts => 'Parties sur ce réseau';

  @override
  String get noHostsFound =>
      'Aucune partie trouvée. Demandez à l\'hôte de partager son code QR.';

  @override
  String get scanConnectionQr => 'Scanner le QR de connexion';

  @override
  String get manualConnection => 'Se connecter manuellement';

  @override
  String get connectionUrlHint => 'ws://192.168.1.5:8765?game=...&pin=...';

  @override
  String get connect => 'Se connecter';

  @override
  String get liveSpectatorTitle => 'Scores en direct';

  @override
  String get liveConnectionConnecting => 'Connexion…';

  @override
  String liveConnectionConnected(String host) {
    return 'Connecté à $host';
  }

  @override
  String get liveConnectionConnectedOnly => 'Connecté';

  @override
  String get liveConnectionReconnecting => 'Reconnexion…';

  @override
  String get liveConnectionWrongPin =>
      'NIP incorrect. Vérifiez le code fourni par l\'hôte.';

  @override
  String get liveConnectionVersionMismatch =>
      'La version majeure de l\'application ne correspond pas à celle de l\'hôte. Mettez à jour les deux appareils vers la même version majeure de FS Score Card.';

  @override
  String get liveSyncAppVersionUnknown =>
      'Impossible de démarrer le partage en direct tant que la version de l\'application est inconnue. Redémarrez l\'application et réessayez.';

  @override
  String get liveConnectionCannotReachHost =>
      'Impossible de joindre l\'hôte. Utilisez le même Wi-Fi et réessayez.';

  @override
  String get liveConnectionHostClosed => 'L\'hôte a arrêté le partage.';

  @override
  String get liveConnectionFailed => 'Échec de la connexion.';

  @override
  String get leaveLiveView => 'Quitter';

  @override
  String get leaveLiveViewLabel => 'Quitter la vue en direct';

  @override
  String get requestNewGameSameType =>
      'Demander une nouvelle partie, même type';

  @override
  String get scoreTableLabel => 'Tableau des scores';

  @override
  String roundLabel(int roundNumber) {
    return 'Manche $roundNumber';
  }

  @override
  String roundLockButtonLabel(int roundNumber) {
    return 'Bouton de verrouillage de la manche $roundNumber';
  }

  @override
  String joinHostLabel(String hostName) {
    return 'Rejoindre $hostName';
  }

  @override
  String get shareGameScores => 'Partager les scores de la partie';

  @override
  String get requestChangeScorecardType =>
      'Demander le changement de type de carte de score';

  @override
  String get roundScoreLabel => 'Score de la manche';

  @override
  String get milesDrivenLabel => 'Bornes parcourues';

  @override
  String get numberOfSafetiesLabel => 'Nombre de bottes';

  @override
  String get numberOfCoupFourreLabel => 'Nombre de coups fourrés';

  @override
  String get delayedActionBonusLabel => 'Bonus de couronnement';

  @override
  String get safeTripBonusLabel => 'Bonus voyage sans les 200';

  @override
  String get shutOutBonusLabel => 'Bonus de capot';

  @override
  String get playerTotalLabel => 'Joueur et total';

  @override
  String playerNameAndTotalLabel(int playerNumber) {
    return 'Nom et score total du joueur $playerNumber';
  }

  @override
  String get playerNameLabel => 'Nom du joueur';

  @override
  String get numberOfPlayersLabel => 'Nombre de joueurs';

  @override
  String get maximumRoundsLabel => 'Manches maximales';

  @override
  String get gameModeLabel => 'Mode de jeu';

  @override
  String get scoreFilterLabel => 'Filtre de score';

  @override
  String get enableEndGameScoreLabel => 'Activer le score de fin de partie';

  @override
  String get endGameScoreLabel => 'Score de fin de partie';

  @override
  String playerRoundScoreLabel(int playerNumber, int roundNumber) {
    return 'Score du joueur $playerNumber à la manche $roundNumber';
  }

  @override
  String playerGameModalLabel(int playerNumber) {
    return 'Fenêtre de jeu du joueur $playerNumber';
  }

  @override
  String playerRoundModalLabel(int playerNumber, int roundNumber) {
    return 'Fenêtre du joueur $playerNumber à la manche $roundNumber';
  }

  @override
  String playerRoundPhaseSelectorLabel(int playerNumber, int roundNumber) {
    return 'Sélecteur de phase du joueur $playerNumber à la manche $roundNumber';
  }

  @override
  String playerTotalScoreLabel(int playerNumber) {
    return 'Score total du joueur $playerNumber';
  }

  @override
  String playerRoundPhaseLabel(int playerNumber, int roundNumber) {
    return 'Phase du joueur $playerNumber à la manche $roundNumber';
  }

  @override
  String playerNameValueLabel(int playerNumber) {
    return 'Nom du joueur $playerNumber';
  }

  @override
  String get liveConnectionQrLabel => 'QR code de connexion en direct';
}
