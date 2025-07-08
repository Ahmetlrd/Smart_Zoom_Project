import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod provider that holds and manages the current Locale of the app
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

/// A class that handles loading and updating the current locale.
/// Uses Riverpod's StateNotifier to notify the app of locale changes.
class LocaleNotifier extends StateNotifier<Locale?> {
  /// Constructor initializes with null and loads saved locale
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  /// Loads saved language code from shared preferences (persistent storage)
  /// If not found, uses the device's default locale
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('languageCode');

    if (langCode != null) {
      // Use the saved locale
      state = Locale(langCode);
    } else {
      // No saved value, fallback to device's default locale
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      state = deviceLocale;
    }
  }

  /// Sets a new locale both in state (Riverpod) and shared preferences
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    state = locale;
  }
}
