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

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get update => 'Update';

  @override
  String get save => 'Save';

  @override
  String get nosummaryyet => 'No meeting summary created yet.';

  @override
  String get firstnotification => 'app opened first time test notification';

  @override
  String get testnotification => 'Notification permission works!';

  @override
  String get wannasave => 'Do you want to save?';

  @override
  String get savetofirestore =>
      'You will save this summary to Firestore. Continue?';

  @override
  String get savedsuccesfully => 'Summary saved successfully.';

  @override
  String get writeprompt => 'Write your prompt to enhance the summary...';

  @override
  String get abouttodelete => 'You\'re about to delete the summary';

  @override
  String get areyousuretodelete =>
      'This action cannot be undone. Are you sure you want to delete the summary?';

  @override
  String get cancel => 'Cancel';

  @override
  String get summarydeleted => 'Summary deleted.';

  @override
  String get wannadeletemeeting => 'Do you want to delete the meeting?';

  @override
  String get areyousuretocont =>
      'This action cannot be undone. Do you want to continue?';

  @override
  String get meetingdeleted => 'Meeting deleted.';

  @override
  String get nosummaryfound => 'No summary found.';

  @override
  String get notranscriptfound => 'No transcript found.';

  @override
  String get nomeetingfound => 'No meeting record found.';

  @override
  String get joinedmeeting => 'You joined the meeting';

  @override
  String get wannapsummarize => 'Would you like to generate a summary?';

  @override
  String get summaryready => 'Zoom summary is ready!';

  @override
  String get newmeetingsummarized =>
      'New meeting has been automatically summarized.';
}
