import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/locale_provider.dart';
import 'package:flutter_app/services/notifications_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  List<String> languages = ['English', 'Türkçe', 'German', 'French'];
  String selectedLanguage = 'English';
  bool switchControl = true;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selected_locale');
    final notificationEnabled = prefs.getBool('notifications_enabled') ?? true;

    setState(() => switchControl = notificationEnabled);

    if (savedLang != null) {
      selectedLanguage = _mapLocaleToLang(savedLang);
      ref.read(localeProvider.notifier).setLocale(Locale(savedLang));
    }
  }

  String _mapLocaleToLang(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'de':
        return 'German';
      case 'fr':
        return 'French';
      default:
        return 'English';
    }
  }

  String _mapLangToLocaleCode(String lang) {
    switch (lang) {
      case 'Türkçe':
        return 'tr';
      case 'German':
        return 'de';
      case 'French':
        return 'fr';
      default:
        return 'en';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authProvider);
    final d = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    selectedLanguage = _mapLocaleToLang(locale?.languageCode ?? 'en');

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final user = ref.read(authProvider.notifier).userInfo;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage("pictures/Blue Gradient Background Poster.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: screenWidth < 600 ? screenWidth * 0.95 : 600,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     Stack(
  alignment: Alignment.center,
  children: [
    Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
        color: Colors.grey.shade800,
        onPressed: () => context.go('/home'),
      ),
    ),
    Center(
      child: Text(
        d.settings,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
          letterSpacing: 0.5,
        ),
      ),
    ),
  ],
),

      const SizedBox(height: 12),
      Center(
        child: Column(
          children: [
            Image.asset('pictures/appicon_1.png', height: 64),
            const SizedBox(height: 12),
            Text(
              "Listen once. Focus on the meeting. Understand always.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),

                        const SizedBox(height: 24),
                        if (isLoggedIn) ...[
                          GestureDetector(
                            onTap: () => context.push('/userinfo'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: user?['pic_url'] != null
                                        ? NetworkImage(user!['pic_url'])
                                        : const AssetImage(
                                                'pictures/avatar.png')
                                            as ImageProvider,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${user?['first_name'] ?? ''} ${user?['last_name'] ?? ''}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        user?['email'] ?? '',
                                        style: TextStyle(
                                            color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            const Icon(Icons.language),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButton<String>(
                                value: selectedLanguage,
                                isExpanded: true,
                                underline: const SizedBox.shrink(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                borderRadius: BorderRadius.circular(8),
                                dropdownColor: Colors.white,
                                items: languages.map((lang) {
                                  return DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  );
                                }).toList(),
                                onChanged: (value) async {
                                  setState(() => selectedLanguage = value!);
                                  final langCode = _mapLangToLocaleCode(value!);
                                  await ref
                                      .read(localeProvider.notifier)
                                      .setLocale(Locale(langCode));
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'selected_locale', langCode);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.notifications),
                            const SizedBox(width: 12),
                            Text(d.notifications),
                            const Spacer(),
                            CupertinoSwitch(
                              value: switchControl,
                              onChanged: (val) async {
                                setState(() => switchControl = val);
                                await NotificationService.toggle(val);
                              },
                              activeColor: const Color(0xFF2563EB),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        if (isLoggedIn)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await ref.read(authProvider.notifier).logout();
                                context.go('/');
                              },
                              icon: const Icon(Icons.logout),
                              label: Text(d.logout),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
