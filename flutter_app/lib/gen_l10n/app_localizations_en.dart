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
  String get save => 'Save and Finish';

  @override
  String get nosummaryyet => 'No meeting summary created yet.';

  @override
  String get firstnotification => 'app opened first time test notification';

  @override
  String get testnotification => 'Notification permission works!';

  @override
  String get wannasave => 'Do you want to save?';

  @override
  String get savetofirestore => 'You will save this summary. Continue?';

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
  String get wannapsummarize => 'Start recording to get a summary.';

  @override
  String get summaryready => 'Zoom summary is ready!';

  @override
  String get newmeetingsummarized =>
      'New meeting has been automatically summarized.';

  @override
  String get settings => 'Settings';

  @override
  String get loginonzoom => 'Please log in with your Zoom account.';

  @override
  String get needzoomfile => 'Zoom Folder Required';

  @override
  String get needzoomfileexp =>
      'Please select the Zoom folder. This folder should contain .m4a files.';

  @override
  String get choosefile => 'Choose Folder';

  @override
  String get couldnotlogin => 'Login failed.';

  @override
  String get searchformeeting => 'Search meeting title...';

  @override
  String get deletemeeting => 'Delete meeting';

  @override
  String get areyousuretodeletemeeting =>
      'Are you sure you want to delete this meeting record?';

  @override
  String get selectameeting => 'Select a meeting.';

  @override
  String get generating => 'Generating...';

  @override
  String promptsecond(Object transcript, Object summary, Object userRequest) {
    return 'Using the following Zoom meeting transcripts, create a new, meaningful summary.\n\nThere are multiple transcript segments from different audio files. Treat them as a single conversation.\n\n1. Analyze the transcript and generate a clear and meaningful title, no more than 5 words. Return it only in this format:\nTitle: Your Title Here (without quotes)\n\n2. Below the title, write a professional, information-focused summary. This summary should include:\n- The meeting\'s purpose and main agenda\n- Who spoke (include names if available)\n- Topics, issues, and ideas discussed\n- Decisions made and conclusions\n- Action items (who, when, what)\n- Notable statements or highlights\n\nIf some parts are short or missing, summarize only what\'s given. Do not invent or repeat information.\n\nPREVIOUS GPT SUMMARY:\n$summary\n\nUSER\'S NEW REQUEST:\n\"$userRequest\"\n\nTRANSCRIPT:\n$transcript';
  }

  @override
  String promptfirst(Object text) {
    return 'Your task has two parts:\n\n1. **Generate a meeting title**: Analyze the transcript below and generate a concise, meaningful title of no more than 5 words. Return it in this exact format:\nTitle: Your Title Here\n\n2. **Generate a meeting summary**: The transcript below consists of segments from multiple audio recordings of a Zoom meeting. Each line or paragraph may represent a different part of the discussion. Your task is to combine these parts into a coherent and clear summary.\n\nThe summary should allow the reader to understand the meeting\'s key content without having attended. Write in a professional, academic tone using clear, simple English.\n\nYour summary must address:\n- The meeting\'s purpose and main agenda\n- Speaker(s) involved (mention names if available)\n- Key points, discussions, issues, and ideas\n- Decisions made and conclusions reached\n- Action items (who will do what and when)\n- Noteworthy statements or highlights\n\nSome parts may be short or incomplete. Do not mention missing info—summarize only what\'s present.\n\n> Note: Although the transcript may be split into segments, treat them as one continuous meeting.\n\nTRANSCRIPT:\n$text';
  }

  @override
  String get userinfo => 'User Information';

  @override
  String get notification_preparing_title => 'Summary is being prepared';

  @override
  String get notification_preparing_body =>
      'Audio files received, analysis is starting...';

  @override
  String get notification_ready_title => 'Zoom Summary Ready!';

  @override
  String get notification_ready_body =>
      'New meeting has been automatically summarized.';
}
