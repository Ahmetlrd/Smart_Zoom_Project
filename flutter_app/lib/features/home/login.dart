// Gerekli paketleri import ediyorum
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart'; 
import 'package:flutter_app/providers/auth_provider.dart'; // Giriş işlemi state yönetimi
import 'package:url_launcher/url_launcher.dart';
import 'utility.dart'; // App bar gibi yardımcı şeyleri buradan alıyorum
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  StreamSubscription? _sub;
  late final AppLinks _appLinks; // 🔥 AppLinks nesnesi ekledik

  @override
  void initState() {
    super.initState();

    _appLinks = AppLinks(); // 🔥 AppLinks başlattık
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == "zoomai") {
        final token = uri.queryParameters['token'];
        if (token != null) {
          ref.read(authProvider.notifier).loginWithToken(token);
          context.go('/home');
        }
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // Butona basınca Zoom login sayfasını açıyorum (ngrok linki üzerinden backend'e gidiyor)
  void _launchZoomLogin() async {
    const zoomLoginUrl = 'https://<NGROK_LINK>.ngrok-free.app/auth/login'; 
    if (await canLaunchUrl(Uri.parse(zoomLoginUrl))) {
      await launchUrl(Uri.parse(zoomLoginUrl),
          mode: LaunchMode.externalApplication);
    } else {
      print("URL açılamadı.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var d = AppLocalizations.of(context);
    return Scaffold(
      appBar: Utility.buildAppBar(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 72, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                d!.welcometext,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final zoomLoginUrl =
                        'https://b07d-159-20-69-18.ngrok-free.app/auth/login'; 
                    launchUrl(Uri.parse(zoomLoginUrl),
                        mode: LaunchMode.externalApplication);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
