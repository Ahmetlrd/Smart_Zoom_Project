import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

// Zoom login işlemini webview üzerinden yapacağım sayfa
class ZoomLoginWebView extends StatefulWidget {
  const ZoomLoginWebView({super.key});

  @override
  State<ZoomLoginWebView> createState() => _ZoomLoginWebViewState();
}

class _ZoomLoginWebViewState extends State<ZoomLoginWebView> {
  // Webview plugin objesini oluşturuyorum
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();

    // Webview'deki URL değişimlerini dinliyorum
    flutterWebViewPlugin.onUrlChanged.listen((String url) {
      // Eğer URL Zoom'dan dönen callback URL'siyse
      if (url.startsWith("http://localhost:8000/auth/callback")) {
        // URL içinden code parametresini alıyorum
        Uri uri = Uri.parse(url);
        String? code = uri.queryParameters['code'];

        if (code != null) {
          // Webview'i kapat ve önceki sayfaya (login.dart) kodu geri döndür
          flutterWebViewPlugin.close();
          Navigator.pop(context, code); // Navigator ile geri dönerken kodu da yolluyorum
        }
      }
    });
  }

  @override
  void dispose() {
    // Sayfa kapanırken webview'i düzgün şekilde dispose ediyorum
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Zoom login ekranı URL'si (client_id ve redirect_uri dikkat!)
    const zoomAuthUrl =
        'https://zoom.us/oauth/authorize?response_type=code&client_id=ec9zlOHpT2yQEg2JIrRkbw&redirect_uri=http://localhost:8000/auth/callback';

    // Webview ekranı
    return WebviewScaffold(
      url: zoomAuthUrl,
      appBar: AppBar(title: const Text("Zoom Login")),
    );
  }
}
