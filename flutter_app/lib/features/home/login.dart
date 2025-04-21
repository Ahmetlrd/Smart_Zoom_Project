// Gerekli paketleri import ediyorum
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_links/uni_links.dart'; // Deep link yakalamak için
import 'package:flutter_app/providers/auth_provider.dart'; // Giriş işlemi state yönetimi
import 'package:url_launcher/url_launcher.dart';
import 'utility.dart'; // App bar gibi yardımcı şeyleri buradan alıyorum

// Login sayfası stateful widget olarak tanımlı, çünkü deep link stream'i dinleyeceğim
class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  // Zoom'dan geri dönüş URL'sini dinlemek için stream subscription
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    // zoomai://auth-callback?token=... şeklindeki linkleri dinliyorum
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == "zoomai") {
        final token = uri.queryParameters['token'];
        if (token != null) {
          // Zoom'dan dönen JWT token'ı authProvider'a veriyorum (kullanıcıyı giriş yapmış say)
          ref.read(authProvider.notifier).loginWithToken(token);

          // Token aldıktan sonra anasayfaya yönlendiriyorum
          context.go('/home');
        }
      }
    });
  }

  @override
  void dispose() {
    // Sayfa kapanınca dinlemeyi bırakıyorum
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
    return Scaffold(
      appBar: Utility.buildAppBar(context), // Üst bar'ı yardımcı dosyadan çekiyorum
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kilit ikonlu görsel
              const Icon(Icons.lock_outline,
                  size: 72, color: Colors.blueAccent),
              const SizedBox(height: 24),
              // Başlık
              const Text(
                "WELCOME TO THE APPLICATION",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
              const SizedBox(height: 40),
              // Zoom login butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Butona basıldığında Zoom login başlatılıyor
                    final zoomLoginUrl =
                        'https://a1df-159-20-69-18.ngrok-free.app/auth/login';
                    launchUrl(Uri.parse(zoomLoginUrl),
                        mode: LaunchMode.externalApplication);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Login with Zoom",
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
