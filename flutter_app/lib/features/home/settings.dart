import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:flutter_app/features/home/utility.dart'; // Custom utility functions (e.g., AppBar)
import 'package:flutter_app/providers/auth_provider.dart'; // Authentication state management
import 'package:flutter_app/providers/locale_provider.dart'; // Language/locale management
import 'package:flutter_riverpod/flutter_riverpod.dart'; // State management with Riverpod
import 'package:go_router/go_router.dart'; // Navigation with GoRouter
import 'package:shared_preferences/shared_preferences.dart'; // Persistent local storage
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization support

// Settings page where users can change language, notification preferences, and log out
class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  // Language options displayed in the dropdown
  List<String> languages = ['English', 'Türkçe', 'German', 'French'];
  String selectedLanguage = "English";

  // State for notifications switch
  bool switchControl = true;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authProvider); // Check if user is logged in
    final d = AppLocalizations.of(context); // Localized strings
    final locale = ref.watch(localeProvider); // Currently selected locale

    // Update dropdown selection based on current locale
    selectedLanguage = _selectedLanguageFromLocale(locale);

    // Responsive ölçüler hesaplanıyor
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final iconSize = screenWidth * 0.12;
    final fontSize = screenWidth * 0.045;
    final horizontalPadding = screenWidth * 0.1;
    final dropdownWidth = screenWidth * 0.3;
    final buttonWidth = screenWidth * 0.5;
    final spacing = screenHeight * 0.02;

    return Scaffold(
      appBar: Utility.buildAppBar(context), // Custom AppBar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //User info
            InkWell(
              onTap: () {
                if (isLoggedIn) {
                  context.push('/userinfo');
                } else {
                  context.go('/');
                }
              },
              child: Row(
                children: [
                  const SizedBox(width: 24), // Left padding
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white10,
                    backgroundImage: isLoggedIn &&
                            ref
                                    .read(authProvider.notifier)
                                    .userInfo?['pic_url'] !=
                                null
                        ? NetworkImage(ref
                            .read(authProvider.notifier)
                            .userInfo!['pic_url'])
                        : const AssetImage('pictures/avatar.png')
                            as ImageProvider,
                    child: !isLoggedIn ||
                            ref
                                    .read(authProvider.notifier)
                                    .userInfo?['pic_url'] ==
                                null
                        ? null
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn
                              ? "${ref.read(authProvider.notifier).userInfo?['first_name'] ?? ''} ${ref.read(authProvider.notifier).userInfo?['last_name'] ?? ''}"
                              : d!.pleaselogin,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          d!.moreinfo,
                          style: TextStyle(
                            fontSize: 16,
                            color: isLoggedIn ? const Color.fromARGB(255, 4, 124, 223) : Colors.grey,
                            decoration: isLoggedIn
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Language dropdown
            Row(
              children: [
                SizedBox(width: horizontalPadding),
                Icon(Icons.language, size: iconSize),
                SizedBox(width: screenWidth * 0.05),
                Text(d!.language, style: TextStyle(fontSize: fontSize,fontWeight: FontWeight.bold)),
                SizedBox(width: screenWidth * 0.05),
                SizedBox(
                  width: dropdownWidth,
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    isExpanded: true,
                    items: languages
                        .map((lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ))
                        .toList(),
                    onChanged: (value) async {
                      setState(() {
                        selectedLanguage = value!;
                      });

                      // Update the app locale using Riverpod
                      if (value == "Türkçe") {
                        await ref
                            .read(localeProvider.notifier)
                            .setLocale(const Locale('tr'));
                      } else if (value == "English") {
                        await ref
                            .read(localeProvider.notifier)
                            .setLocale(const Locale('en'));
                      } else if (value == "German") {
                        await ref
                            .read(localeProvider.notifier)
                            .setLocale(const Locale('de'));
                      } else if (value == "French") {
                        await ref
                            .read(localeProvider.notifier)
                            .setLocale(const Locale('fr'));
                      }
                    },
                  ),
                ),
              ],
            ),

            // Notifications toggle
            Row(
              children: [
                SizedBox(width: horizontalPadding),
                Icon(Icons.notifications, size: iconSize),
                SizedBox(width: screenWidth * 0.05),
                SizedBox(
                  width: screenWidth * 0.5,
                  child: Text(d.notifications,
                      style: TextStyle(fontSize: fontSize,fontWeight: FontWeight.bold)),
                ),
                Switch(
                  value: switchControl,
                  onChanged: (val) {
                    setState(() {
                      switchControl = val;
                    });
                  },
                ),
              ],
            ),

            // Logout button if user is logged in
            if (isLoggedIn)
              SizedBox(
                width: buttonWidth,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    context.go('/');
                  },
                  child: Text(d.logout, style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold)),
                ),
              ),
            SizedBox(height: spacing),
          ],
        ),
      ),
    );
  }

  // Convert Locale to a readable language string for dropdown
  String _selectedLanguageFromLocale(Locale? locale) {
    if (locale == null) return 'English';
    if (locale.languageCode == 'tr') return 'Türkçe';
    if (locale.languageCode == 'en') return 'English';
    if (locale.languageCode == 'de') return 'German';
    if (locale.languageCode == 'fr') return 'French';
    return 'English'; // fallback if unknown
  }
}
