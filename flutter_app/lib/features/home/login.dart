import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/firestore_service.dart';
import 'package:flutter_app/services/notifications_service.dart';
import 'package:flutter_app/services/secure_storage_service.dart';
import 'package:flutter_app/services/zoom_service.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/locale_provider.dart';
import 'package:flutter_app/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:window_size/window_size.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  StreamSubscription? _sub;
  late final AppLinks _appLinks;
  List<String> languages = ['English', 'Türkçe', 'German', 'French'];
  String selectedLanguage = 'English';
  bool switchControl = true;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
    if (Platform.isMacOS || Platform.isWindows) {
      setWindowMinSize(const Size(800, 600));
    }

    _loadSavedLanguageAndNotificationSetting();
    _attemptAutoLogin();
    _listenForZoomRedirect();
  }

  Future<void> _loadSavedLanguageAndNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selected_locale');
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    setState(() => switchControl = enabled);

    if (savedLang != null) {
      selectedLanguage = _mapLocaleToLang(savedLang);
      ref.read(localeProvider.notifier).setLocale(Locale(savedLang));
    } else {
      final locale = Platform.localeName.split('_').first;
      selectedLanguage = _mapLocaleToLang(locale);
      ref.read(localeProvider.notifier).setLocale(Locale(locale));
    }
  }

  void _attemptAutoLogin() async {
    final refreshToken = await readRefreshToken();
    final savedToken = await readAccessToken();

    if (savedToken != null && await ZoomService.isAccessTokenValid(savedToken)) {
      ref.read(authProvider.notifier).loginWithToken(savedToken);
      context.go('/home');
      return;
    }

    if (refreshToken != null) {
      final newAccessToken = await AuthService.refreshAccessToken(refreshToken);
      if (newAccessToken != null) {
        await saveAccessToken(newAccessToken);
        ref.read(authProvider.notifier).loginWithToken(newAccessToken);
        context.go('/home');
      }
    }
  }

  void _listenForZoomRedirect() {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      _appLinks = AppLinks();
      _sub = _appLinks.uriLinkStream.listen((Uri? uri) async {
        if (uri == null || uri.scheme != "zoomai") return;

        final jwtToken = uri.queryParameters['token'];
        final accessToken = uri.queryParameters['access_token'];
        final refreshToken = uri.queryParameters['refresh_token'];

        if (jwtToken != null && accessToken != null && refreshToken != null) {
          await saveJwtToken(jwtToken);
          await saveAccessToken(accessToken);
          await saveRefreshToken(refreshToken);

          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser == null) {
            try {
              await FirebaseAuth.instance.signInAnonymously();
            } catch (e) {
              print("Firebase anonymous sign-in failed: $e");
              return;
            }
          }

          final userInfo = await ZoomService.fetchUserInfoWithToken(accessToken);
          final userEmail = userInfo?['email'];
          final timezone = userInfo?['timezone'] ?? 'UTC';
          final hostId = userInfo?['id'];

          if (userEmail != null) {
            final fcmToken = await FirebaseMessaging.instance.getToken();
            await NotificationService.sendPlatformToBackend(userEmail);

            await FirestoreService().saveTokens(
              userEmail: userEmail,
              accessToken: accessToken,
              refreshToken: refreshToken,
              accessExpiry: DateTime.now().add(Duration(hours: 1)),
              refreshExpiry: DateTime.now().add(Duration(days: 30)),
              fcmToken: fcmToken,
              timezone: timezone,
              hostId: hostId,
            );

            ref.read(authProvider.notifier).loginWithToken(accessToken);
            if (mounted) context.go('/home');
          }
        }
      });
    }
  }

  String _mapLocaleToLang(String code) {
    switch (code) {
      case 'tr': return 'Türkçe';
      case 'de': return 'German';
      case 'fr': return 'French';
      default: return 'English';
    }
  }

  void _launchZoomLogin() async {
    const zoomLoginUrl = 'http://75.101.195.165:8000/auth/login';
    if (await canLaunchUrl(Uri.parse(zoomLoginUrl))) {
      await launchUrl(Uri.parse(zoomLoginUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    selectedLanguage = _mapLocaleToLang(locale?.languageCode ?? 'en');

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("pictures/Blue Gradient Background Poster.png"),
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
                  width: screenWidth < 600 ? screenWidth * 0.9 : 500,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Pulse(
                        duration: const Duration(seconds: 2),
                        child: Image.asset('pictures/appicon_1.png', height: 100),
                      ),
                      const SizedBox(height: 24),
                      FadeIn(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          "Listen once. \nFocus on the meeting. \nUnderstand always.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Zoom hesabınız üzerinden giriş yapınız.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _launchZoomLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.login, size: 20, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(d.login,
                                  style: const TextStyle(fontSize: 16, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.language, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedLanguage,
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              borderRadius: BorderRadius.circular(8),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black, fontSize: 14),
                              items: languages
                                  .map((lang) => DropdownMenuItem(
                                        value: lang,
                                        child: Text(lang,
                                            style: const TextStyle(fontWeight: FontWeight.w500)),
                                      ))
                                  .toList(),
                              onChanged: (value) async {
                                setState(() => selectedLanguage = value!);
                                final prefs = await SharedPreferences.getInstance();
                                final code = _mapLocaleToCode(value!);
                                await prefs.setString('selected_locale', code);
                                await ref.read(localeProvider.notifier).setLocale(Locale(code));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.notifications, size: 24),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _mapLocaleToCode(String lang) {
    switch (lang) {
      case 'Türkçe': return 'tr';
      case 'German': return 'de';
      case 'French': return 'fr';
      default: return 'en';
    }
  }
}