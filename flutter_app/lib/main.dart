// Flutter UI framework
import 'package:flutter/material.dart';

// Import authentication provider (Riverpod based)
import 'package:flutter_app/providers/auth_provider.dart';

// Import locale (language) provider
import 'package:flutter_app/providers/locale_provider.dart';

// Flutter's built-in localization support
import 'package:flutter_localizations/flutter_localizations.dart';

// Riverpod for state management
import 'package:flutter_riverpod/flutter_riverpod.dart';

// GoRouter for page navigation
import 'package:go_router/go_router.dart';

// Routing definitions
import 'routes.dart';

// AppLinks package to listen to incoming deep links
import 'package:app_links/app_links.dart';

// Generated localization class (via flutter gen-l10n)
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
// This function listens for deep links like: zoomai://auth-callback?token=...
Future<void> handleIncomingLinks(WidgetRef ref, BuildContext context) async {
  final appLinks = AppLinks();

  // Start listening to incoming URI links
  appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null && uri.scheme == 'zoomai') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        // Save login state with token
        ref.read(authProvider.notifier).loginWithToken(token);

        // Delay the navigation slightly to make sure context/router is ready
        Future.delayed(Duration(milliseconds: 100), () {
          context.go('/home'); // Navigate to homepage
        });
      }
    }
  });
}





// Entry point of the Flutter application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp())); // Wrap with Riverpod ProviderScope
}


// Define the root widget of the app
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Once the widget is fully mounted, start listening to deep links
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleIncomingLinks(ref, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider); // Use GoRouter config
    final locale = ref.watch(localeProvider); // Current language selection

    return MaterialApp.router(
      // If locale not set, fallback to device locale
      locale: locale ?? WidgetsBinding.instance.platformDispatcher.locale,

      // Enable support for different languages
      localizationsDelegates: const [
        AppLocalizations.delegate, // Custom l10n
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Supported languages
      supportedLocales: const [
        Locale("en", ""),
        Locale("tr", ""),
        Locale("de", ""),
        Locale("fr", ""),
      ],

      // Set up the router config
      routerConfig: router,
    );
  }
}
