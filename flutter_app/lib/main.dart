// Flutter UI framework
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';

import 'dart:io'; // En üste ekle
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
import 'package:flutter_app/gen_l10n/app_localizations.dart'; // Custom utility functions (e.g., for app bars)
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 📦 Notification service
import 'package:flutter_app/services/notifications_service.dart';

// 🔑 Global navigator key (for background notification tıklama)

// 📡 Deep link listener

Future<void> handleIncomingLinks(WidgetRef ref, BuildContext context) async {
  if (!Platform.isAndroid && !Platform.isIOS) return; // Sadece mobilde dinle

  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null && uri.scheme == 'zoomai') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        ref.read(authProvider.notifier).loginWithToken(token);
        Future.delayed(const Duration(milliseconds: 100), () {
          context.go('/home');
        });
      }
    }
  });
}

// 🎯 Entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (Platform.isMacOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(); 
  }


  if (Platform.isAndroid || Platform.isIOS) {
    await NotificationService.init();
  }

  runApp(const ProviderScope(child: MyApp()));
}


class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isAndroid || Platform.isIOS) {
        handleIncomingLinks(ref, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      locale: locale ?? WidgetsBinding.instance.platformDispatcher.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("en", ""),
        Locale("tr", ""),
        Locale("de", ""),
        Locale("fr", ""),
      ],
      routerConfig: router,
    );
  }
}
