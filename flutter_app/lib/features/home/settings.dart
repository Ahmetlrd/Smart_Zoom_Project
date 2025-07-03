import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/utility.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/locale_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  List<String> languages = ['English', 'Türkçe', 'German', 'French'];
  String selectedLanguage = "English";
  bool switchControl = true;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authProvider);
    final d = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    selectedLanguage = _selectedLanguageFromLocale(locale);

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final iconSize = screenWidth * 0.10;
    final fontSize = screenWidth * 0.045;
    final horizontalPadding = screenWidth * 0.08;
    final dropdownWidth = screenWidth * 0.4;
    final buttonWidth = screenWidth * 0.6;
    final spacing = screenHeight * 0.03;

    final imageUrl = ref.read(authProvider.notifier).userInfo?['pic_url'];

    return Scaffold(
      appBar: Utility.buildAppBar(context),
      backgroundColor: const Color(0xFFF7F7FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            InkWell(
              onTap: () => isLoggedIn
                  ? context.push('/userinfo')
                  : context.go('/'),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                  },
                                )
                              : Image.asset(
                                  'pictures/avatar.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                        ),
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              d!.moreinfo,
                              style: TextStyle(
                                fontSize: 16,
                                color: isLoggedIn ? Colors.blueAccent : Colors.grey,
                                decoration: isLoggedIn ? TextDecoration.underline : TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing * 1.5),

            // Language Selection
            Text(d.language,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.language, size: 28),
                const SizedBox(width: 16),
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
                      setState(() => selectedLanguage = value!);

                      if (value == "Türkçe") {
                        await ref.read(localeProvider.notifier).setLocale(const Locale('tr'));
                      } else if (value == "English") {
                        await ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                      } else if (value == "German") {
                        await ref.read(localeProvider.notifier).setLocale(const Locale('de'));
                      } else if (value == "French") {
                        await ref.read(localeProvider.notifier).setLocale(const Locale('fr'));
                      }
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: spacing * 2),

            // Notification Toggle
            Text(d.notifications,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.notifications, size: 28),
                const SizedBox(width: 16),
                Switch(
                  value: switchControl,
                  onChanged: (val) {
                    setState(() => switchControl = val);
                  },
                ),
              ],
            ),

            SizedBox(height: spacing * 2),

            // Logout
            if (isLoggedIn)
              Center(
                child: SizedBox(
                  width: buttonWidth,
                  height: screenHeight * 0.07,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      context.go('/');
                    },
                    label: Text(
                      d.logout,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _selectedLanguageFromLocale(Locale? locale) {
    if (locale == null) return 'English';
    if (locale.languageCode == 'tr') return 'Türkçe';
    if (locale.languageCode == 'en') return 'English';
    if (locale.languageCode == 'de') return 'German';
    if (locale.languageCode == 'fr') return 'French';
    return 'English';
  }
}