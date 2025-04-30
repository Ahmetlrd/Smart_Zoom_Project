import 'dart:async'; // Used for managing asynchronous operations like listening to streams
import 'package:flutter/material.dart'; // Core Flutter UI toolkit
import 'package:go_router/go_router.dart'; // Handles navigation and routing between screens
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Provides state management using Riverpod
import 'package:app_links/app_links.dart'; // Used to listen for incoming deep links
import 'package:flutter_app/providers/auth_provider.dart'; // Custom provider that holds authentication state
import 'package:url_launcher/url_launcher.dart'; // Used to open external URLs or apps
import 'utility.dart'; // Contains reusable utility functions, such as custom AppBar builder
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Automatically generated localization class

// This is the login screen widget that uses Riverpod state management
class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState(); // Creates the mutable state for this widget
}

// This class holds the logic and UI for the Login screen
class _LoginState extends ConsumerState<Login> {
  StreamSubscription? _sub; // Will hold the stream listener for incoming deep links
  late final AppLinks _appLinks; // Handles link stream to detect redirects (e.g., Zoom callback)

  @override
  void initState() {
    super.initState();

    // Initializes AppLinks and listens for incoming links
    _appLinks = AppLinks(); 
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      // If the link has the custom scheme "zoomai", then it's a valid callback
      if (uri != null && uri.scheme == "zoomai") {
        final token = uri.queryParameters['token']; // Extract JWT token from query string
        if (token != null) {
          // Save the token in Riverpod state (user is considered logged in)
          ref.read(authProvider.notifier).loginWithToken(token);
          // Navigate to the home page
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
    const zoomLoginUrl = 'https://<NGROK_LINK>.ngrok-free.app/auth/login'; 
    if (await canLaunchUrl(Uri.parse(zoomLoginUrl))) {
      await launchUrl(Uri.parse(zoomLoginUrl), mode: LaunchMode.externalApplication);
    } else {
      print("URL could not open.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access localized strings (multi-language support)
    var d = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: Utility.buildAppBar(context), // Adds a custom top app bar
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32), // Horizontal padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            children: [
              // Lock icon to indicate "authentication"
              const Icon(Icons.lock_outline, size: 72, color: Colors.blueAccent),
              const SizedBox(height: 24), // Vertical space
              
              // Welcome message using localization
              Text(
                d!.welcometext,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40), // Vertical space before button
              
              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final zoomLoginUrl = 'https://b36b-159-20-69-18.ngrok-free.app/auth/login';
                    launchUrl(Uri.parse(zoomLoginUrl), mode: LaunchMode.externalApplication);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    d.login,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
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
