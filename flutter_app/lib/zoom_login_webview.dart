import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart'; // sadece paketi değiştirdik

// Zoom login işlemini webview üzerinden yapacağım sayfa
class ZoomLoginWebView extends StatefulWidget {
  const ZoomLoginWebView({super.key});

  @override
  State<ZoomLoginWebView> createState() => _ZoomLoginWebViewState();
}

class _ZoomLoginWebViewState extends State<ZoomLoginWebView> {
  late final WebViewController _controller; // webview_flutter için controller gerekiyor

  @override
  void initState() {
    super.initState();

    // Controller'ı burada initialize ediyoruz
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Zoom login için JS açık olmalı
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // Eğer URL Zoom callback ise
            if (url.startsWith("http://localhost:8000/auth/callback")) {
              Uri uri = Uri.parse(url);
              String? code = uri.queryParameters['code'];

              if (code != null) {
                Navigator.pop(context, code); // Kodu geri döndür
              }
              return NavigationDecision.prevent; // Bu URL'yi açmaya gerek yok
            }
            return NavigationDecision.navigate; // Normalde devam etsin
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://zoom.us/oauth/authorize?response_type=code&client_id=ec9zlOHpT2yQEg2JIrRkbw&redirect_uri=http://localhost:8000/auth/callback'));
  }

  @override
  Widget build(BuildContext context) {
    // Webview ekranı
    return Scaffold(
      appBar: AppBar(title: const Text("Zoom Login")),
      body: WebViewWidget(controller: _controller), // burada Scaffold + WebViewWidget kullanıyoruz
    );
  }
}
