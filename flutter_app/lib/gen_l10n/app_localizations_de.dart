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
  String get moreinfo => 'Weitere Informationen:';

  @override
  String get email => 'Email';

  @override
  String get accounttype => 'Kontotyp:';

  @override
  String get pleaselogin => 'Bitte einloggen';

  @override
  String get close => 'Schließen';

  @override
  String get delete => 'Löschen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get save => 'Speichern und Beenden';

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
      'Diese Zusammenfassung wird gespeichert. Fortfahren?';

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
  String get wannapsummarize =>
      'Zum Mitschnitt starten, um eine Zusammenfassung zu erhalten.';

  @override
  String get summaryready => 'Zoom-Zusammenfassung ist bereit!';

  @override
  String get newmeetingsummarized =>
      'Neues Meeting wurde automatisch zusammengefasst.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get loginonzoom => 'Bitte melden Sie sich mit Ihrem Zoom-Konto an.';

  @override
  String get needzoomfile => 'Zoom-Ordner erforderlich';

  @override
  String get needzoomfileexp =>
      'Bitte wählen Sie den Zoom-Ordner aus. Dieser Ordner sollte .m4a-Dateien enthalten.';

  @override
  String get choosefile => 'Ordner auswählen';

  @override
  String get couldnotlogin => 'Anmeldung fehlgeschlagen.';

  @override
  String get searchformeeting => 'Meeting-Titel suchen...';

  @override
  String get deletemeeting => 'Meeting löschen';

  @override
  String get areyousuretodeletemeeting =>
      'Sind Sie sicher, dass Sie diesen Meeting-Datensatz löschen möchten?';

  @override
  String get selectameeting => 'Wählen Sie ein Meeting aus.';

  @override
  String get generating => 'Wird generiert...';

  @override
  String promptsecond(Object transcript, Object summary, Object userRequest) {
    return 'Erstelle eine neue, aussagekräftige Zusammenfassung anhand der folgenden Zoom-Meeting-Transkripte.\n\nEs liegen mehrere Transkriptteile aus verschiedenen Audioaufnahmen vor. Betrachte sie als ein einziges Gespräch.\n\n1. Analysiere das Transkript und erstelle einen klaren, aussagekräftigen Titel mit maximal 5 Wörtern. Gib den Titel nur in folgendem Format zurück:\nTitle: Dein Titel hier (ohne Anführungszeichen)\n\n2. Schreibe unter dem Titel eine professionelle, informationsorientierte Zusammenfassung, die folgende Punkte abdeckt:\n- Zweck und Hauptthema des Meetings\n- Wer gesprochen hat (Namen, falls verfügbar)\n- Diskutierte Themen, Probleme, Ideen\n- Getroffene Entscheidungen und Ergebnisse\n- To-dos (wer, wann, was)\n- Bemerkenswerte Aussagen oder Highlights\n\nWenn Teile fehlen oder kurz sind, fasse nur das vorhandene Material zusammen. Keine Informationen erfinden oder wiederholen.\n\nVORHERIGE GPT-ZUSAMMENFASSUNG:\n$summary\n\nNEUE ANFRAGE DES BENUTZERS:\n\"$userRequest\"\n\nTRANSKRIPT:\n$transcript';
  }

  @override
  String promptfirst(Object text) {
    return 'Deine Aufgabe besteht aus zwei Teilen:\n\n1. **Erzeuge einen Besprechungstitel**: Analysiere das untenstehende Transkript und generiere einen prägnanten, aussagekräftigen Titel mit maximal 5 Wörtern. Gib ihn in folgendem Format zurück:\nTitle: Titel hier\n\n2. **Erzeuge eine Zusammenfassung**: Das folgende Transkript besteht aus Segmenten mehrerer Audioaufnahmen eines Zoom-Meetings. Jeder Absatz kann einen anderen Gesprächsabschnitt darstellen. Kombiniere diese Inhalte zu einer zusammenhängenden und verständlichen Zusammenfassung.\n\nDie Zusammenfassung soll es dem Leser ermöglichen, die wichtigsten Inhalte des Treffens zu verstehen, auch ohne daran teilgenommen zu haben. Verwende einen professionellen, sachlichen Ton in klarem und einfachem Deutsch.\n\nDeine Zusammenfassung soll folgende Punkte enthalten:\n- Ziel und Hauptagenda der Besprechung\n- Beteiligte Sprecher (Namen angeben, falls vorhanden)\n- Besprochene Themen, Probleme, Ideen\n- Getroffene Entscheidungen und Ergebnisse\n- Maßnahmen (wer macht was bis wann)\n- Wichtige Aussagen oder Betonungen\n\nEinige Passagen können kurz oder unvollständig sein. Erwähne fehlende Informationen nicht, fasse nur das Gegebene zusammen.\n\n> Hinweis: Auch wenn das Transkript segmentiert ist, soll es als ein einziges Meeting behandelt werden.\n\nTRANSKRIPT:\n$text';
  }

  @override
  String get userinfo => 'Benutzerinformationen';

  @override
  String get notification_preparing_title => 'Zusammenfassung wird erstellt';

  @override
  String get notification_preparing_body =>
      'Audiodateien empfangen, Analyse beginnt...';

  @override
  String get notification_ready_title => 'Zoom-Zusammenfassung fertig!';

  @override
  String get notification_ready_body =>
      'Neues Meeting wurde automatisch zusammengefasst.';
}
