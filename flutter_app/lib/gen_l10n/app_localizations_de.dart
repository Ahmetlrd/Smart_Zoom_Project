// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get login => 'Mit Zoom anmelden';

  @override
  String get welcometext => 'WILLKOMMEN IN DER ANWENDUNG';

  @override
  String get language => 'Sprache:';

  @override
  String get notifications => 'Benachrichtigungen:';

  @override
  String get meetinglist => 'Besprechungsliste';

  @override
  String get meetingdetails => 'Besprechungsdetails';

  @override
  String get nlpsummary => 'NLP Zusammenfassung';

  @override
  String get saved => 'Gespeicherte Zusammenfassungen';

  @override
  String get logout => 'Abmelden';

  @override
  String get participants => ' Teilnehmer:';

  @override
  String get transcription => ' Transkription';

  @override
  String get summary => ' Zusammenfassung (KI)';

  @override
  String get notes => ' Notizen';

  @override
  String get moreinfo => 'Weitere Informationen: ';

  @override
  String get email => 'Email';

  @override
  String get accounttype => 'Kontotyp: ';

  @override
  String get pleaselogin => 'Bitte einloggen';

  @override
  String get close => 'Schließen';

  @override
  String get delete => 'Löschen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get save => 'Speichern';

  @override
  String get nosummaryyet => 'Es wurde noch keine Zusammenfassung erstellt.';

  @override
  String get firstnotification =>
      'App zum ersten Mal geöffnet - Testbenachrichtigung';

  @override
  String get testnotification => 'Benachrichtigungsberechtigung funktioniert!';

  @override
  String get wannasave => 'Möchten Sie speichern?';

  @override
  String get savetofirestore =>
      'Diese Zusammenfassung wird in Firestore gespeichert. Fortfahren?';

  @override
  String get savedsuccesfully => 'Zusammenfassung erfolgreich gespeichert.';

  @override
  String get writeprompt =>
      'Schreiben Sie Ihre Anfrage zur Verbesserung der Zusammenfassung...';

  @override
  String get abouttodelete => 'Sie sind dabei, die Zusammenfassung zu löschen';

  @override
  String get areyousuretodelete =>
      'Diese Aktion kann nicht rückgängig gemacht werden. Sind Sie sicher, dass Sie löschen möchten?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get summarydeleted => 'Zusammenfassung gelöscht.';

  @override
  String get wannadeletemeeting => 'Möchten Sie das Meeting löschen?';

  @override
  String get areyousuretocont =>
      'Diese Aktion kann nicht rückgängig gemacht werden. Möchten Sie fortfahren?';

  @override
  String get meetingdeleted => 'Meeting wurde gelöscht.';

  @override
  String get nosummaryfound => 'Keine Zusammenfassung gefunden.';

  @override
  String get notranscriptfound => 'Kein Transkript gefunden.';

  @override
  String get nomeetingfound => 'Keine Meeting-Aufzeichnung gefunden.';

  @override
  String get joinedmeeting => 'Sie sind dem Meeting beigetreten';

  @override
  String get wannapsummarize => 'Möchten Sie eine Zusammenfassung erstellen?';

  @override
  String get summaryready => 'Zoom-Zusammenfassung ist bereit!';

  @override
  String get newmeetingsummarized =>
      'Neues Meeting wurde automatisch zusammengefasst.';
}
