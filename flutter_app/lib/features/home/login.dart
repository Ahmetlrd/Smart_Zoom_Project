import 'dart:async'; // Used for managing asynchronous operations like listening to streams
import 'package:flutter/material.dart'; // Core Flutter UI toolkit
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/secure_storage_service.dart';
import 'package:go_router/go_router.dart'; // Handles navigation and routing between screens
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Provides state management using Riverpod
import 'package:app_links/app_links.dart'; // Used to listen for incoming deep links
import 'package:flutter_app/providers/auth_provider.dart'; // Custom provider that holds authentication state
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Used to open external URLs or apps
import 'utility.dart'; // Contains reusable utility functions, such as custom AppBar builder
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Automatically generated localization class
import 'package:flutter_dotenv/flutter_dotenv.dart';

// This is the login screen widget that uses Riverpod state management

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  StreamSubscription?
      _sub; // Will hold the stream listener for incoming deep links
  late final AppLinks
      _appLinks; // Handles link stream to detect redirects (e.g., Zoom callback)

  @override
  void initState() {
    super.initState();
    // Try to restore session using secure storage
    Future.delayed(Duration.zero, () async {
      // Step 1: Try refreshing access token using stored refresh token
      final refreshToken = await readRefreshToken();
      if (refreshToken != null) {
        final newAccessToken =
            await AuthService.refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          // Save new token to secure storage and login
          await saveAccessToken(newAccessToken);
          ref.read(authProvider.notifier).loginWithToken(newAccessToken);
          context.go('/home');
          return;
        }
      }

      // Step 2: If refresh didn't work, try using previously saved access token directly
      final savedToken = await readAccessToken();
      if (savedToken != null) {
        ref.read(authProvider.notifier).loginWithToken(savedToken);
        context.go('/home');
      }
    });

    // Step 3: Listen for OAuth callback with token info (from Zoom login redirect)
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((Uri? uri) async {
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
          await saveJwtToken(jwtToken);
          await saveAccessToken(zoomAccessToken);
          await saveRefreshToken(zoomRefreshToken);

          await ref.read(authProvider.notifier).loginWithToken(zoomAccessToken);
          context.go('/home');
        }
      }
    });
  }

  @override
  void dispose() {
    // Cancel the stream subscription to avoid memory leaks
    _sub?.cancel();
    super.dispose();
  }

  // Opens Zoom login page in the user's external browser (used in OAuth flow)
  void _launchZoomLogin() async {
    const zoomLoginUrl = 'http://54.204.65.114:8000/auth/login';
    if (await canLaunchUrl(Uri.parse(zoomLoginUrl))) {
      await launchUrl(Uri.parse(zoomLoginUrl),
          mode: LaunchMode.externalApplication);
    } else {
      print("URL could not open.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access localized strings (multi-language support)
    var d = AppLocalizations.of(context);

    // Get screen dimensions for responsive layout
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Calculate responsive values based on screen size
    final iconSize = screenWidth * 0.15; // Icon takes 15% of screen width
    final verticalSpacing = screenHeight * 0.03; // Spacing between elements
    final buttonPadding = screenHeight * 0.02; // Button vertical padding
    final fontSize = screenWidth * 0.045; // Text size relative to screen width

    return Scaffold(
      appBar: Utility.buildAppBar(context), // Adds a custom top app bar
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08), // Responsive horizontal padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            children: [
              // Lock icon to indicate "authentication"
              Icon(Icons.lock_outline,
                  size: iconSize,
                  color: Colors.blueAccent), // Responsive icon size
              SizedBox(height: verticalSpacing), // Responsive vertical space

              // Welcome message using localization
              Text(
                d!.welcometext,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize, // Responsive font size
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(
                  height: verticalSpacing *
                      1.5), // Additional spacing before button

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final zoomLoginUrl = dotenv.env['ZOOM_LOGIN_URL'] ?? '';
                    if (zoomLoginUrl.isEmpty) {
                      print("ZOOM_LOGIN_URL not found in .env");
                      return;
                    }

                    launchUrl(Uri.parse(zoomLoginUrl),
                        mode: LaunchMode.externalApplication);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: buttonPadding), // Responsive button padding
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    d.login,
                    style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.white), // Responsive button text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
