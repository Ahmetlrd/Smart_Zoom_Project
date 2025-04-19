import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class ZoomLoginWebView extends StatefulWidget {
  const ZoomLoginWebView({super.key});

  @override
  State<ZoomLoginWebView> createState() => _ZoomLoginWebViewState();
}

class _ZoomLoginWebViewState extends State<ZoomLoginWebView> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();

    flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (url.startsWith("http://localhost:8000/auth/callback")) {
        Uri uri = Uri.parse(url);
        String? code = uri.queryParameters['code'];

        if (code != null) {
          flutterWebViewPlugin.close();
          Navigator.pop(context, code); // login.dart'a döner ve kodu yollar
        }
      }
    });
  }

  @override
  void dispose() {
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const zoomAuthUrl =
        'https://zoom.us/oauth/authorize?response_type=code&client_id=ec9zlOHpT2yQEg2JIrRkbw&redirect_uri=http://localhost:8000/auth/callback';

    return WebviewScaffold(
      url: zoomAuthUrl,
      appBar: AppBar(title: const Text("Zoom Login")),
    );
  }
}
