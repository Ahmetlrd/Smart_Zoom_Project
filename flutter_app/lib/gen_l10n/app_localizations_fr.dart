// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get login => 'Se connecter avec Zoom';

  @override
  String get welcometext => 'BIENVENUE DANS L\'APPLICATION';

  @override
  String get language => 'Langue :';

  @override
  String get notifications => 'Notifications :';

  @override
  String get meetinglist => 'Liste des réunions';

  @override
  String get meetingdetails => 'Détails de la réunion';

  @override
  String get nlpsummary => 'Résumé NLP';

  @override
  String get saved => 'Résumés enregistrés';

  @override
  String get logout => 'Déconnexion';

  @override
  String get participants => ' Participants :';

  @override
  String get transcription => ' Transcription';

  @override
  String get summary => ' Résumé (IA)';

  @override
  String get notes => ' Notes';

  @override
  String get moreinfo => 'plus d\'infos';

  @override
  String get email => 'Email';

  @override
  String get accounttype => 'Type de compte: ';

  @override
  String get pleaselogin => 'Veuillez vous connecter';

  @override
  String get close => 'Fermer';

  @override
  String get delete => 'Supprimer';

  @override
  String get update => 'Mettre à jour';

  @override
  String get save => 'Enregistrer';

  @override
  String get nosummaryyet => 'Aucun résumé de réunion n\'a encore été créé.';

  @override
  String get firstnotification =>
      'l\'application a été ouverte pour la première fois - notification de test';

  @override
  String get testnotification => 'L\'autorisation de notification fonctionne !';

  @override
  String get wannasave => 'Voulez-vous enregistrer ?';

  @override
  String get savetofirestore =>
      'Ce résumé sera enregistré dans Firestore. Continuer ?';

  @override
  String get savedsuccesfully => 'Résumé enregistré avec succès.';

  @override
  String get writeprompt => 'Écrivez votre demande à ajouter au résumé...';

  @override
  String get abouttodelete => 'Vous êtes sur le point de supprimer le résumé';

  @override
  String get areyousuretodelete =>
      'Cette action est irréversible. Êtes-vous sûr de vouloir supprimer ce résumé ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get summarydeleted => 'Résumé supprimé.';

  @override
  String get wannadeletemeeting => 'Voulez-vous supprimer la réunion ?';

  @override
  String get areyousuretocont =>
      'Cette action est irréversible. Voulez-vous continuer ?';

  @override
  String get meetingdeleted => 'Réunion supprimée.';

  @override
  String get nosummaryfound => 'Aucun résumé trouvé.';

  @override
  String get notranscriptfound => 'Aucune transcription trouvée.';

  @override
  String get nomeetingfound => 'Aucun enregistrement de réunion trouvé.';

  @override
  String get joinedmeeting => 'Vous avez rejoint la réunion';

  @override
  String get wannapsummarize =>
      'N’oubliez pas de lancer l’enregistrement pour recevoir un résumé à la fin de la réunion.';

  @override
  String get summaryready => 'Le résumé Zoom est prêt !';

  @override
  String get newmeetingsummarized =>
      'La nouvelle réunion a été résumée automatiquement.';
}
