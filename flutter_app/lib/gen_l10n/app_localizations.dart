import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('tr')
  ];

  /// Button text for Zoom login
  ///
  /// In en, this message translates to:
  /// **'Login with Zoom'**
  String get login;

  /// Welcome message displayed on app startup
  ///
  /// In en, this message translates to:
  /// **'WELCOME TO THE APPLICATION'**
  String get welcometext;

  /// Label for language selection
  ///
  /// In en, this message translates to:
  /// **'Language:'**
  String get language;

  /// Label for notification settings
  ///
  /// In en, this message translates to:
  /// **'Notifications:'**
  String get notifications;

  /// Title for the meeting list screen
  ///
  /// In en, this message translates to:
  /// **'Meeting List'**
  String get meetinglist;

  /// Title for the meeting details screen
  ///
  /// In en, this message translates to:
  /// **'Meeting Details'**
  String get meetingdetails;

  /// Title for NLP-generated summary section
  ///
  /// In en, this message translates to:
  /// **'NLP Summary'**
  String get nlpsummary;

  /// Title for saved summaries section
  ///
  /// In en, this message translates to:
  /// **'Saved Summaries'**
  String get saved;

  /// Button text for logging out
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Label for participant count
  ///
  /// In en, this message translates to:
  /// **' Participants: '**
  String get participants;

  /// Label for transcription section
  ///
  /// In en, this message translates to:
  /// **' Transcription'**
  String get transcription;

  /// Label for AI-generated summary
  ///
  /// In en, this message translates to:
  /// **' Summary (AI)'**
  String get summary;

  /// Label for notes section
  ///
  /// In en, this message translates to:
  /// **' Notes'**
  String get notes;

  /// Link text for additional information
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get moreinfo;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for account type information
  ///
  /// In en, this message translates to:
  /// **'Account Type: '**
  String get accounttype;

  /// Message prompting user to log in
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get pleaselogin;

  /// Button text to close a dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button text to delete an item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Button text to update an item
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Button text to save and finish
  ///
  /// In en, this message translates to:
  /// **'Save and Finish'**
  String get save;

  /// Message when no summary exists
  ///
  /// In en, this message translates to:
  /// **'No meeting summary created yet.'**
  String get nosummaryyet;

  /// First test notification message
  ///
  /// In en, this message translates to:
  /// **'app opened first time test notification'**
  String get firstnotification;

  /// Message confirming notification permission
  ///
  /// In en, this message translates to:
  /// **'Notification permission works!'**
  String get testnotification;

  /// Confirmation message for saving
  ///
  /// In en, this message translates to:
  /// **'Do you want to save?'**
  String get wannasave;

  /// Confirmation message for saving to Firestore
  ///
  /// In en, this message translates to:
  /// **'You will save this summary to Firestore. Continue?'**
  String get savetofirestore;

  /// Success message after saving
  ///
  /// In en, this message translates to:
  /// **'Summary saved successfully.'**
  String get savedsuccesfully;

  /// Instruction for writing a prompt
  ///
  /// In en, this message translates to:
  /// **'Write your prompt to enhance the summary...'**
  String get writeprompt;

  /// Warning message before deletion
  ///
  /// In en, this message translates to:
  /// **'You\'re about to delete the summary'**
  String get abouttodelete;

  /// Confirmation message for summary deletion
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure you want to delete the summary?'**
  String get areyousuretodelete;

  /// Button text to cancel an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Message after successful deletion
  ///
  /// In en, this message translates to:
  /// **'Summary deleted.'**
  String get summarydeleted;

  /// Confirmation message for meeting deletion
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the meeting?'**
  String get wannadeletemeeting;

  /// General confirmation message for irreversible actions
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Do you want to continue?'**
  String get areyousuretocont;

  /// Message after meeting deletion
  ///
  /// In en, this message translates to:
  /// **'Meeting deleted.'**
  String get meetingdeleted;

  /// Message when no summary is found
  ///
  /// In en, this message translates to:
  /// **'No summary found.'**
  String get nosummaryfound;

  /// Message when no transcript is found
  ///
  /// In en, this message translates to:
  /// **'No transcript found.'**
  String get notranscriptfound;

  /// Message when no meeting record is found
  ///
  /// In en, this message translates to:
  /// **'No meeting record found.'**
  String get nomeetingfound;

  /// Notification when user joins a meeting
  ///
  /// In en, this message translates to:
  /// **'You joined the meeting'**
  String get joinedmeeting;

  /// Instruction to start recording for summary
  ///
  /// In en, this message translates to:
  /// **'Start recording to get a summary.'**
  String get wannapsummarize;

  /// Notification when summary is ready
  ///
  /// In en, this message translates to:
  /// **'Zoom summary is ready!'**
  String get summaryready;

  /// Notification for auto-summarized meeting
  ///
  /// In en, this message translates to:
  /// **'New meeting has been automatically summarized.'**
  String get newmeetingsummarized;

  /// Title for settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Instruction for Zoom login
  ///
  /// In en, this message translates to:
  /// **'Please log in with your Zoom account.'**
  String get loginonzoom;

  /// Message indicating Zoom folder is needed
  ///
  /// In en, this message translates to:
  /// **'Zoom Folder Required'**
  String get needzoomfile;

  /// Explanation for Zoom folder requirement
  ///
  /// In en, this message translates to:
  /// **'Please select the Zoom folder. This folder should contain .m4a files.'**
  String get needzoomfileexp;

  /// Button text to choose a folder
  ///
  /// In en, this message translates to:
  /// **'Choose Folder'**
  String get choosefile;

  /// Message for login failure
  ///
  /// In en, this message translates to:
  /// **'Login failed.'**
  String get couldnotlogin;

  /// Placeholder for meeting search input
  ///
  /// In en, this message translates to:
  /// **'Search meeting title...'**
  String get searchformeeting;

  /// Button text to delete a meeting
  ///
  /// In en, this message translates to:
  /// **'Delete meeting'**
  String get deletemeeting;

  /// Confirmation message for meeting deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this meeting record?'**
  String get areyousuretodeletemeeting;

  /// Instruction to select a meeting
  ///
  /// In en, this message translates to:
  /// **'Select a meeting.'**
  String get selectameeting;

  /// Message during content generation
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// Second summary generation prompt sent to GPT
  ///
  /// In en, this message translates to:
  /// **'Using the following Zoom meeting transcripts, create a new, meaningful summary.\n\nThere are multiple transcript segments from different audio files. Treat them as a single conversation.\n\n1. Analyze the transcript and generate a clear and meaningful title, no more than 5 words. Return it only in this format:\nTitle: Your Title Here (without quotes)\n\n2. Below the title, write a professional, information-focused summary. This summary should include:\n- The meeting\'s purpose and main agenda\n- Who spoke (include names if available)\n- Topics, issues, and ideas discussed\n- Decisions made and conclusions\n- Action items (who, when, what)\n- Notable statements or highlights\n\nIf some parts are short or missing, summarize only what\'s given. Do not invent or repeat information.\n\nPREVIOUS GPT SUMMARY:\n{summary}\n\nUSER\'S NEW REQUEST:\n\"{userRequest}\"\n\nTRANSCRIPT:\n{transcript}'**
  String promptsecond(Object transcript, Object summary, Object userRequest);

  /// The initial prompt sent to GPT to summarize the full transcript.
  ///
  /// In en, this message translates to:
  /// **'Your task has two parts:\n\n1. **Generate a meeting title**: Analyze the transcript below and generate a concise, meaningful title of no more than 5 words. Return it in this exact format:\nTitle: Your Title Here\n\n2. **Generate a meeting summary**: The transcript below consists of segments from multiple audio recordings of a Zoom meeting. Each line or paragraph may represent a different part of the discussion. Your task is to combine these parts into a coherent and clear summary.\n\nThe summary should allow the reader to understand the meeting\'s key content without having attended. Write in a professional, academic tone using clear, simple English.\n\nYour summary must address:\n- The meeting\'s purpose and main agenda\n- Speaker(s) involved (mention names if available)\n- Key points, discussions, issues, and ideas\n- Decisions made and conclusions reached\n- Action items (who will do what and when)\n- Noteworthy statements or highlights\n\nSome parts may be short or incomplete. Do not mention missing info—summarize only what\'s present.\n\n> Note: Although the transcript may be split into segments, treat them as one continuous meeting.\n\nTRANSCRIPT:\n{text}'**
  String promptfirst(Object text);

  /// Label for user profile or identity info section.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get userinfo;

  /// No description provided for @notification_preparing_title.
  ///
  /// In en, this message translates to:
  /// **'Summary is being prepared'**
  String get notification_preparing_title;

  /// No description provided for @notification_preparing_body.
  ///
  /// In en, this message translates to:
  /// **'Audio files received, analysis is starting...'**
  String get notification_preparing_body;

  /// No description provided for @notification_ready_title.
  ///
  /// In en, this message translates to:
  /// **'Zoom Summary Ready!'**
  String get notification_ready_title;

  /// No description provided for @notification_ready_body.
  ///
  /// In en, this message translates to:
  /// **'New meeting has been automatically summarized.'**
  String get notification_ready_body;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
