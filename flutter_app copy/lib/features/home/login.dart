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

    _loadSavedLanguageOrSystem();

    Future.delayed(Duration.zero, () async {
      // Step 1: Try refreshing access token using stored refresh token
      final refreshToken = await readRefreshToken();
      final savedToken = await readAccessToken();

      if (savedToken != null) {
        final isValid = await ZoomService.isAccessTokenValid(savedToken);

        if (isValid) {
          ref.read(authProvider.notifier).loginWithToken(savedToken);
          context.go('/home');
          return;
        }
      }

      if (refreshToken != null) {
        final newAccessToken =
            await AuthService.refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await saveAccessToken(newAccessToken);
          ref.read(authProvider.notifier).loginWithToken(newAccessToken);
          context.go('/home');
          return;
        }
      }

      // Step 2: If both access and refresh failed, do nothing, stay on login page
    });

    // Step 3: Listen for OAuth callback with token info (from Zoom login redirect)
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      _appLinks = AppLinks();
      _sub = _appLinks.uriLinkStream.listen((Uri? uri) async {
        if (uri != null && uri.scheme == "zoomai") {
          final jwtToken = uri.queryParameters['token'];
          final zoomAccessToken = uri.queryParameters['access_token'];
          final zoomRefreshToken = uri.queryParameters['refresh_token'];

          print("JWT: $jwtToken");
          print("Zoom Access Token: $zoomAccessToken");
          print("Zoom Refresh Token: $zoomRefreshToken");

          if (jwtToken != null &&
              zoomAccessToken != null &&
              zoomRefreshToken != null) {
            // Save tokens to secure storage for local use
            await saveJwtToken(jwtToken);
            await saveAccessToken(zoomAccessToken);
            await saveRefreshToken(zoomRefreshToken);

            // Ensure Firebase user is authenticated (anonymous sign-in if needed)
            final firebaseUser = FirebaseAuth.instance.currentUser;
            if (firebaseUser == null) {
              try {
                await FirebaseAuth.instance.signInAnonymously();
                print("Signed in anonymously to Firebase");
              } catch (e) {
                print("Failed to sign in anonymously: $e");
              }
            }

            // Retrieve user info from Zoom to get user email
            final userInfo =
                await ZoomService.fetchUserInfoWithToken(zoomAccessToken);
            final userEmail = userInfo?['email'];
            final timezone = userInfo?['timezone'] ?? 'UTC';
            final hostId = userInfo?['id'];
            if (userEmail != null) {
              await FirestoreService().saveTokens(
                userEmail: userEmail,
                accessToken: zoomAccessToken,
                refreshToken: zoomRefreshToken,
                accessExpiry: DateTime.now().add(Duration(hours: 1)),
                refreshExpiry: DateTime.now().add(Duration(days: 30)),
                timezone: timezone,
                hostId: hostId,
              );
              print("Firestore token saved for user: $userEmail");
            } else {
              print("Error: Could not retrieve user email from Zoom.");
            }

            if (userEmail != null) {
              // 🔁 FCM token al
              if (Platform.isIOS || Platform.isMacOS) {
                final apnsToken =
                    await FirebaseMessaging.instance.getAPNSToken();
                if (apnsToken == null) {
                  print("⏳ APNS token henüz hazır değil.");
                  // Token hazır olana kadar işlem yapma veya retry ekleyebilirsin
                  return;
                }
              }
              final fcmToken = await FirebaseMessaging.instance.getToken();

              // 🔁 FCM token'ı backend'e gönder
              await NotificationService.sendPlatformToBackend(userEmail);

              // 🔐 Tüm tokenları Firestore'a kaydet
              await FirestoreService().saveTokens(
                userEmail: userEmail,
                accessToken: zoomAccessToken,
                refreshToken: zoomRefreshToken,
                accessExpiry: DateTime.now().add(Duration(hours: 1)),
                refreshExpiry: DateTime.now().add(Duration(days: 30)),
                fcmToken: fcmToken,
              );

              print("Firestore token saved for user: $userEmail");

              // ⏫ AuthProvider güncelle
              ref.read(authProvider.notifier).loginWithToken(zoomAccessToken);

              // 🏠 Ana sayfaya yönlendir
              if (!mounted) return;
              context.go('/home');
            } else {
              print("Error: Could not retrieve user email from Zoom.");
            }
          }
        }
      });
    }
  }

  Future<void> _loadSavedLanguageOrSystem() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selected_locale');
    if (savedLang != null) {
      selectedLanguage = _mapLocaleToLang(savedLang);
      ref.read(localeProvider.notifier).setLocale(Locale(savedLang));
    } else {
      final locale = Platform.localeName.split('_').first;
      selectedLanguage = _mapLocaleToLang(locale);
      ref.read(localeProvider.notifier).setLocale(Locale(locale));
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

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _launchZoomLogin() async {
    const zoomLoginUrl = 'http://75.101.195.165:8000/auth/login';
    if (await canLaunchUrl(Uri.parse(zoomLoginUrl))) {
      await launchUrl(Uri.parse(zoomLoginUrl),
          mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    final locale = ref.watch(localeProvider);
    selectedLanguage = _mapLocaleToLang(locale?.languageCode ?? 'en');

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: size.height,
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
                  width: screenWidth < 600 ? screenWidth * 0.9 : 500,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Pulse(
                        duration: Duration(seconds: 2),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1))
                            ],
                          ),
                          child: Image.asset('pictures/appicon_1.png',
                              height: 100),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeIn(
                        duration: Duration(milliseconds: 800),
                        child: Text(
                          "Listen once. Focus on the meeting. Understand always.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text(d.login,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
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
                              underline: SizedBox.shrink(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              borderRadius: BorderRadius.circular(8),
                              dropdownColor: Colors.white,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              items: languages
                                  .map((lang) => DropdownMenuItem(
                                        value: lang,
                                        child: Text(lang,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500)),
                                      ))
                                  .toList(),
                              onChanged: (value) async {
                                setState(() => selectedLanguage = value!);
                                final prefs =
                                    await SharedPreferences.getInstance();
                                String code = 'en';
                                if (value == "Türkçe")
                                  code = 'tr';
                                else if (value == "German")
                                  code = 'de';
                                else if (value == "French") code = 'fr';
                                await prefs.setString('selected_locale', code);
                                await ref
                                    .read(localeProvider.notifier)
                                    .setLocale(Locale(code));
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
                            onChanged: (val) {
                              setState(() => switchControl = val);
                            },
                            activeColor: Color(0xFF2563EB),
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
}
