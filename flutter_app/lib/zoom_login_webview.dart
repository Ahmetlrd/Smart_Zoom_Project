import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart'; // WebView package for rendering web content

// This widget displays the Zoom login screen inside a WebView
class ZoomLoginWebView extends StatefulWidget {
  const ZoomLoginWebView({super.key});

  @override
  State<ZoomLoginWebView> createState() => _ZoomLoginWebViewState();
}

class _ZoomLoginWebViewState extends State<ZoomLoginWebView> {
  // Controller used to interact with the WebView
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the WebView controller and configure its behavior
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript (required for Zoom OAuth)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // When the user is redirected back from Zoom to your callback URL
            if (url.startsWith("http://localhost:8000/auth/callback")) {
              Uri uri = Uri.parse(url);
              String? code = uri.queryParameters['code']; // Get the authorization code from URL

              if (code != null) {
                Navigator.pop(context, code); // Return the code to the previous screen
              }

              return NavigationDecision.prevent; // Stop loading this URL in WebView
            }

            return NavigationDecision.navigate; // Continue loading other URLs normally
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://zoom.us/oauth/authorize?response_type=code&client_id=ec9zlOHpT2yQEg2JIrRkbw&redirect_uri=http://localhost:8000/auth/callback')); // Start OAuth flow
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold with WebView as the main content
    return Scaffold(
      appBar: AppBar(title: const Text("Zoom Login")), // AppBar with title
      body: WebViewWidget(controller: _controller), // Embed the WebView using the controller
    );
  }
}
