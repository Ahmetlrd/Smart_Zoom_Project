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

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login with Zoom'**
  String get login;

  /// No description provided for @welcometext.
  ///
  /// In en, this message translates to:
  /// **'WELCOME TO THE APPLICATION'**
  String get welcometext;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language:'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications:'**
  String get notifications;

  /// No description provided for @meetinglist.
  ///
  /// In en, this message translates to:
  /// **'Meeting List'**
  String get meetinglist;

  /// No description provided for @meetingdetails.
  ///
  /// In en, this message translates to:
  /// **'Meeting Details'**
  String get meetingdetails;

  /// No description provided for @nlpsummary.
  ///
  /// In en, this message translates to:
  /// **'NLP Summary'**
  String get nlpsummary;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved Summaries'**
  String get saved;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **' Participants: '**
  String get participants;

  /// No description provided for @transcription.
  ///
  /// In en, this message translates to:
  /// **' Transcription'**
  String get transcription;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **' Summary (AI)'**
  String get summary;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **' Notes'**
  String get notes;

  /// No description provided for @moreinfo.
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get moreinfo;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @accounttype.
  ///
  /// In en, this message translates to:
  /// **'Account Type: '**
  String get accounttype;

  /// No description provided for @pleaselogin.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get pleaselogin;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save and Finish'**
  String get save;

  /// No description provided for @nosummaryyet.
  ///
  /// In en, this message translates to:
  /// **'No meeting summary created yet.'**
  String get nosummaryyet;

  /// No description provided for @firstnotification.
  ///
  /// In en, this message translates to:
  /// **'app opened first time test notification'**
  String get firstnotification;

  /// No description provided for @testnotification.
  ///
  /// In en, this message translates to:
  /// **'Notification permission works!'**
  String get testnotification;

  /// No description provided for @wannasave.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save?'**
  String get wannasave;

  /// No description provided for @savetofirestore.
  ///
  /// In en, this message translates to:
  /// **'You will save this summary to Firestore. Continue?'**
  String get savetofirestore;

  /// No description provided for @savedsuccesfully.
  ///
  /// In en, this message translates to:
  /// **'Summary saved successfully.'**
  String get savedsuccesfully;

  /// No description provided for @writeprompt.
  ///
  /// In en, this message translates to:
  /// **'Write your prompt to enhance the summary...'**
  String get writeprompt;

  /// No description provided for @abouttodelete.
  ///
  /// In en, this message translates to:
  /// **'You\'re about to delete the summary'**
  String get abouttodelete;

  /// No description provided for @areyousuretodelete.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure you want to delete the summary?'**
  String get areyousuretodelete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @summarydeleted.
  ///
  /// In en, this message translates to:
  /// **'Summary deleted.'**
  String get summarydeleted;

  /// No description provided for @wannadeletemeeting.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the meeting?'**
  String get wannadeletemeeting;

  /// No description provided for @areyousuretocont.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Do you want to continue?'**
  String get areyousuretocont;

  /// No description provided for @meetingdeleted.
  ///
  /// In en, this message translates to:
  /// **'Meeting deleted.'**
  String get meetingdeleted;

  /// No description provided for @nosummaryfound.
  ///
  /// In en, this message translates to:
  /// **'No summary found.'**
  String get nosummaryfound;

  /// No description provided for @notranscriptfound.
  ///
  /// In en, this message translates to:
  /// **'No transcript found.'**
  String get notranscriptfound;

  /// No description provided for @nomeetingfound.
  ///
  /// In en, this message translates to:
  /// **'No meeting record found.'**
  String get nomeetingfound;

  /// No description provided for @joinedmeeting.
  ///
  /// In en, this message translates to:
  /// **'You joined the meeting'**
  String get joinedmeeting;

  /// No description provided for @wannapsummarize.
  ///
  /// In en, this message translates to:
  /// **'Start recording to get a summary.'**
  String get wannapsummarize;

  /// No description provided for @summaryready.
  ///
  /// In en, this message translates to:
  /// **'Zoom summary is ready!'**
  String get summaryready;

  /// No description provided for @newmeetingsummarized.
  ///
  /// In en, this message translates to:
  /// **'New meeting has been automatically summarized.'**
  String get newmeetingsummarized;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;
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
