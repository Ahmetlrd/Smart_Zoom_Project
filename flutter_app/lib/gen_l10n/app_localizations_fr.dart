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
  String get save => 'enregistrer et Terminer';

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

  @override
  String get settings => 'Paramètres';

  @override
  String get loginonzoom => 'Veuillez vous connecter avec votre compte Zoom.';

  @override
  String get needzoomfile => 'Dossier Zoom requis';

  @override
  String get needzoomfileexp =>
      'Veuillez sélectionner le dossier Zoom. Ce dossier doit contenir des fichiers .m4a.';

  @override
  String get choosefile => 'Choisir un dossier';

  @override
  String get couldnotlogin => 'Échec de la connexion.';

  @override
  String get searchformeeting => 'Rechercher un titre de réunion...';

  @override
  String get deletemeeting => 'Supprimer la réunion';

  @override
  String get areyousuretodeletemeeting =>
      'Êtes-vous sûr de vouloir supprimer cet enregistrement de réunion ?';

  @override
  String get selectameeting => 'Sélectionnez une réunion.';

  @override
  String get generating => 'Génération...';

  @override
  String promptsecond(Object transcript, Object summary, Object userRequest) {
    return 'Utilisez les transcriptions suivantes d\'une réunion Zoom pour générer un nouveau résumé pertinent.\n\nPlusieurs segments de transcription proviennent de différents fichiers audio. Considérez-les comme une seule conversation.\n\n1. Analysez la transcription et générez un titre clair et significatif, de 5 mots maximum. Retournez-le uniquement dans ce format :\nTitle: Votre titre ici (sans guillemets)\n\n2. Sous le titre, écrivez un résumé professionnel et centré sur l\'information. Le résumé doit inclure :\n- L’objectif et l’ordre du jour principal\n- Les intervenants (précisez les noms si disponibles)\n- Les sujets, problèmes et idées abordés\n- Les décisions prises et conclusions\n- Les actions à entreprendre (qui, quand, quoi)\n- Les citations marquantes ou points importants\n\nSi certaines parties sont courtes ou manquantes, résumez uniquement les informations fournies. N’inventez rien et n’ajoutez pas de contenu inutile.\n\nRÉSUMÉ GPT PRÉCÉDENT :\n$summary\n\nNOUVELLE DEMANDE DE L’UTILISATEUR :\n\"$userRequest\"\n\nTRANSCRIPTION :\n$transcript';
  }

  @override
  String promptfirst(Object text) {
    return 'Votre tâche comporte deux volets :\n\n1. **Générer un titre de réunion** : Analysez la transcription ci-dessous et créez un titre concis et pertinent ne dépassant pas 5 mots. Retournez-le dans ce format exact :\nTitle: Titre ici\n\n2. **Générer un résumé de réunion** : La transcription ci-dessous provient de plusieurs enregistrements audio d\'une réunion Zoom. Chaque paragraphe peut représenter une partie différente de la discussion. Assemblez ces parties en un résumé clair et cohérent.\n\nCe résumé doit permettre au lecteur de comprendre les points clés de la réunion sans y avoir assisté. Adoptez un ton professionnel et académique, en français clair et simple.\n\nLe résumé doit inclure :\n- L’objectif et l’ordre du jour principal\n- Les intervenants (noms si disponibles)\n- Les sujets importants, problèmes ou idées abordés\n- Les décisions prises et les conclusions tirées\n- Les actions à entreprendre (qui, quoi, quand)\n- Les phrases marquantes ou points saillants\n\nCertains passages peuvent être incomplets. Ne mentionnez pas les absences d’informations ; concentrez-vous sur ce qui est fourni.\n\n> Remarque : Bien que la transcription soit segmentée, elle doit être traitée comme une seule réunion.\n\nTRANSCRIPTION :\n$text';
  }

  @override
  String get userinfo => 'Informations utilisateur';
}
