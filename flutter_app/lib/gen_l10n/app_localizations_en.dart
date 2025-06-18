// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Login with Zoom';

  @override
  String get welcometext => 'WELCOME TO THE APPLICATION';

  @override
  String get language => 'Language:';

  @override
  String get notifications => 'Notifications:';

  @override
  String get meetinglist => 'Meeting List';

  @override
  String get meetingdetails => 'Meeting Details';

  @override
  String get nlpsummary => 'NLP Summary';

  @override
  String get saved => 'Saved Summaries';

  @override
  String get logout => 'Logout';

  @override
  String get participants => ' Participants: ';

  @override
  String get transcription => ' Transcription';

  @override
  String get summary => ' Summary (AI)';

  @override
  String get notes => ' Notes';

  @override
  String get moreinfo => 'More info';

  @override
  String get email => 'Email';

  @override
  String get accounttype => 'Account Type: ';

  @override
  String get pleaselogin => 'Please login';
}
